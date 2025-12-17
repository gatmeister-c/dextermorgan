local players = game:GetService("Players")

local player = players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")

local targetPlayer = "USERNAME TO TELEPORT TO"
local teleportAllowed = true

playerGui.ChildAdded:Connect(function(child)
    if child.Name == "Anti-Exploit" then
        teleportAllowed = true
        task.wait(3)
        teleportAllowed = false
        task.wait(30)
        teleportAllowed = true
    end
end)

local function dropCash()
    local args = {
        500
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DCZSH"):InvokeServer(unpack(args))
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
local function teleportTo(part, target, offset)
    while true do
        if offset then
            part.CFrame = target.CFrame + Vector3.new(2, 0, 2)
        else
            part.CFrame = target.CFrame
        end

        task.wait(3)

        if isNear(part, target, 5) then
            return
        end
    end
end

player.CharacterAdded:Connect(function(character)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

local function fireProximityPrompts()
    for _, descendant in workspace:GetDescendants() do
        if descendant:IsA("ProximityPrompt") then
            fireproximityprompt(descendant)
        end
    end
end

local function teleportOutsideMap()
    target = Vector3.new()
    teleportTo(hrp, target, 5)
end

local function main()
    if player.Name == targetPlayer then
        teleportOutsideMap()

        while task.wait(0.1) do
            fireProximityPrompts()
        end
        
    else
        while true do
            if teleportAllowed then
                local targetHrp = getTargetHumanoidRootPart()
                teleportTo(hrp, targetHrp, true)
                resetChar()

                teleportAllowed = false
                task.wait(10)
                teleportAllowed = true
            end
            task.wait(1)
        end
    end
end
