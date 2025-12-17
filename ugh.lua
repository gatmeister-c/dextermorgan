local players = game:GetService("Players")

local player = players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local playerGui = player:WaitForChild("PlayerGui")
local notificationFrame = playerGui:WaitForChild("CoreGUI"):WaitForChild("NotificationFrame")
local pauseTasks = false

local targetPlayer = "CHILLMAST3R2009_YT"

local function deathRespawn()
    local args = {
        "KMG4R904"
    }
    local result = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer(unpack(args))
    return result
end

local function isNear(part1, part2, maxDist)
    local success, result = pcall(function()
        return (part1.Position - part2.Position).Magnitude <= maxDist
    end)

    if success then
        return result
    else
        warn("isNear error:", result)
        return false
    end
end

local function getTargetHumanoidRootPart()
    local target = players:FindFirstChild(targetPlayer)
    if not target then
        print("No player found by the name of " .. targetPlayer)
        return
    end

    local targetChar = target.Character
    if not targetChar then
        print("Character not found for player " .. targetPlayer)
        return
    end

    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then
        print("No HumanoidRootPart found for player " .. targetPlayer)
        return
    end

    return targetHrp
end

local function resetChar()
    humanoid.Health = 0
end

local function fireProximityPrompts()
    for _, descendant in workspace:GetDescendants() do
        if descendant:IsA("ProximityPrompt") then
            fireproximityprompt(descendant)
        end
    end
end

player.CharacterAdded:Connect(function(character)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

notificationFrame.ChildAdded:Connect(function(child)
    if child:FindFirstChild("Frame") then
        local frame = child.Frame
        if frame:FindFirstChild("NotificationTitle") then
            local title = frame.NotificationTitle
            if title.Text == "Anti Exploit" then
                pauseTasks = true
                task.wait(20)
                pauseTasks = false
            end
        end
    end
end)

local function main()
    if player.Name == targetPlayer then
        -- MAIN ACCOUNT
        local ws = WebSocket.connect("ws://127.0.0.1:8080/")

        while task.wait() do
            fireProximityPrompts()

            for _, plr in players:GetChildren() do
                if plr == player then continue end
                local plrChar = plr.Character
                if plrChar then
                    local plrHumanoid = plrChar:WaitForChild("Humanoid")
                    local plrHrp = plrChar:WaitForChild("HumanoidRootPart")
                    if isNear(plrHrp, hrp, 5) and plrHumanoid.Health >= 100 then
                        ws:Send(plr.Name)
                    end
                end
            end
        end

    else
        -- ALT ACCOUNTS
        local ws = WebSocket.connect("ws://127.0.0.1:8080/")

        ws.OnMessage:Connect(function(message)
            if message == player.Name then
                resetChar()
            end
        end)

        while task.wait(1) do
            if not pauseTasks then
                hrp.CFrame = getTargetHumanoidRootPart().CFrame + Vector3.new(2, 1, 2)
                deathRespawn()
                task.wait(5)
            end
        end
        
    end

end

main()
