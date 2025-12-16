local players = game:GetService("Players")

local player = players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")

local targetPlayer = "USERNAME TO TELEPORT TO"
local safeTeleport = false
local teleportAllowed = true

playerGui.ChildAdded:Connect(function(child)
    if child.Name == "Anti-Exploit" then
        teleportAllowed = true
        safeTeleport = true
        task.wait(3)
        teleportAllowed = false
        safeTeleport = false
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
end

local function deathRespawn()
    local args = {
        "KMG4R904"
    }
    local result = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer(unpack(args))
    return result
end

task.spawn(function()
    while task.wait(1) do
        if game:GetService("ReplicatedStorage").PlayerbaseData2:FindFirstChild(player.Name).CanRespawn.Value == true then
            deathRespawn()
        end
    end
end)

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

local function teleportToTarget(targetHrp)
    if isNear(hrp, targetHrp, 5) then
        print("Already near target")
        return
    end

    hrp.CFrame = targetHrp.CFrame + Vector3.new(2, 0, 2)
end

player.CharacterAdded:Connect(function(character)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)
