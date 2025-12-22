local players =             game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage =   game:GetService("ReplicatedStorage")

local player =              players.LocalPlayer
local char =                player.Character or player.CharacterAdded:Wait()
local hrp =                 char:WaitForChild("HumanoidRootPart")
local humanoid =            char:WaitForChild("Humanoid")
local playerGui =           player:WaitForChild("PlayerGui")
local notificationFrame =   playerGui:WaitForChild("CoreGUI"):WaitForChild("NotificationFrame")
local cashPath =            ReplicatedStorage:WaitForChild("PlayerbaseData2"):WaitForChild(player.Name):WaitForChild("Cash")
local bankPath =            playerGui:WaitForChild("CoreGUI"):WaitForChild("StatsFrame"):WaitForChild("Frame2"):WaitForChild("Frame"):WaitForChild("Container"):WaitForChild("Bank"):WaitForChild("Amt")
local atmFrame =            playerGui:WaitForChild("CoreGUI"):WaitForChild("ATMFrame"):WaitForChild("ATMFrame")
local atmWithdrawBox =      atmFrame:WaitForChild("WithdrawBox"):WaitForChild("TextBox")
local atmWithdrawButton =   atmFrame:WaitForChild("WithdrawButton"):WaitForChild("TextButton")
local pauseTasks =          false
local outsideMap =          false
local readyToReset =        false
local successfulDeaths =    0
local totalRespawns =       1
--local ws =                  WebSocket.connect("ws://127.0.0.1:8080/")
local targetPlayer =        "GracePhoenixPrism"

local function deathRespawn()
    local args = {
        "KMG4R904"
    }
    local result = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer(unpack(args))
    return result
end

local function isNear(part1, part2, maxDist)
    return (part1.Position - part2.Position).Magnitude <= maxDist
end

local function getTargetHumanoidRootPart()
    local target = players:FindFirstChild(targetPlayer)
    if not target then
        warn("No player found by the name of " .. targetPlayer)
        return
    end

    local targetChar = target.Character
    if not targetChar then
        warn("Character not found for player " .. targetPlayer)
        return
    end

    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then
        warn("No HumanoidRootPart found for player " .. targetPlayer)
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

local function pressKey(key, holdTime)
    holdTime = holdTime or 0.1
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function getCash()
    return cashPath.Value
end

local function getBank()
    local strBank = bankPath.Text
    local num = strBank:gsub("[^%d]", "")
    local value = tonumber(num)

    return value
end

local atm = {}
local atms = {}
local atmsFolder = workspace:WaitForChild("Map"):WaitForChild("ATMz")

for i, v in atmsFolder:GetChildren() do
    table.insert(atms, v)
end

function atm:find()
    local nearestAtm = nil
    local nearestDistance = math.huge
    local playerPos = hrp.Position
    
    for i, v in atms do
        local atmPos = v.MainPart.Position
        local magnitude = (playerPos - atmPos).Magnitude
        if magnitude < nearestDistance then
            nearestAtm = v
            nearestDistance = magnitude
        end
    end
    return nearestAtm
end

function atm:interact(Atm)
    local atm = Atm or atm:find()
    if not atm then 
        print("no atm")
        return 
    end

    local atmMainPart = atm.MainPart
    if not atmMainPart then
        print("no atm mainpart") 
        return 
    end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        print("no hrp") 
        return 
    end

    while true do
        if isNear(hrp, atmMainPart, 5) then 
            local prompt = atmMainPart.posA:FindFirstChild("ProximityPrompt")
            if prompt then
                task.wait(5)
                if isNear(hrp, atmMainPart, 5) then 
                    fireproximityprompt(prompt)
                    task.wait(0.5)
                    return
                end
            end
        else
            hrp.CFrame = atmMainPart.CFrame * CFrame.new(0, 0, -3)
            task.wait(1)
        end
    end
end

function atm:withdraw(amount)
    local amount = amount or math.min(getBank(), 100000 - getCash())
    if amount > 100000 - getCash() then
        amount = 100000 - getCash()
    end

    atm:interact()
    atmWithdrawBox.Text = amount
    task.wait(0.5)
    for _, connection in getconnections(atmWithdrawButton.MouseButton1Click) do
        connection:Fire()
    end
end

local outsidePart = Instance.new("Part"); outsidePart.Anchored = true; outsidePart.CanCollide = false; outsidePart.Transparency = 1; outsidePart.Position = Vector3.new(-4712, -150, -904); outsidePart.Parent = game:GetService("Workspace");
local function teleportOutsideMap()
	print("Attempting teleport outside map")

    local attempt = 0
	while task.wait() do
        if not hrp then player.CharacterAdded:Wait() end
		if pauseTasks then continue end

        while true do
            if not isNear(hrp, outsidePart, 5) then
                hrp.CFrame = outsidePart.CFrame
                task.wait(0.5)
            else
                task.wait(6)
                break
            end
        end

        if pauseTasks then continue end

		pressKey(Enum.KeyCode.W)
		task.wait(1)

		if isNear(hrp, outsidePart, 5) then
			print("Teleport successful")
			outsideMap = true
			return
		end

        attempt += 1
		print("Attempt failed, retrying:", attempt)
		task.wait(2)
	end
	print("Failed to teleport outside map")
end

player.CharacterAdded:Connect(function(character)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

task.spawn(function()
    while task.wait(0.1) do
        local canRespawn = game:GetService("ReplicatedStorage").PlayerbaseData2:FindFirstChild(player.Name).CanRespawn.Value
        if canRespawn then
            totalRespawns += 1
            print("Respawning")
            deathRespawn()
        end
    end
end)

--[[
        notificationFrame.ChildAdded:Connect(function(child)
            if child:FindFirstChild("Frame") then
                local frame = child.Frame
                if frame:FindFirstChild("NotificationTitle") then
                    local title = frame.NotificationTitle
                    if title.Text == "Anti Exploit" then
                        pauseTasks = true
                        task.wait(10)
                        pauseTasks = false
                    end
                end
            end
        end)
]]

local function main()
    if player.Name == targetPlayer then
        -- MAIN ACCOUNT --
        teleportOutsideMap()
        repeat
            task.wait()
        until outsideMap == true
        print("Teleported outside of map successfully")

        while task.wait(0.1) do
            fireProximityPrompts()

            for _, plr in players:GetChildren() do
                if plr == player then continue end
                local plrChar = plr.Character
                if plrChar then
                    local plrHumanoid = plrChar:WaitForChild("Humanoid")
                    local plrHrp = plrChar:WaitForChild("HumanoidRootPart")
                    if isNear(plrHrp, hrp, 8) and plrHumanoid.Health >= 100 then
                        task.wait(0.1)
                        if isNear(plrHrp, hrp, 8) and plrHumanoid.Health >= 100 then
                            ws:Send(plr.Name)
                            hrp.CFrame = outsidePart.CFrame
                        end
                    end
                end
            end
        end

    else
        -- ALT ACCOUNTS --
        ws.OnMessage:Connect(function(message)
            if message == player.Name then
                if readyToReset then
                    resetChar()
                    readyToReset = false
                end
            end
        end)

        while true do
            if cashPath.Value <= 5000 then
                atm:withdraw()
            end

            local startTime = os.clock()
            local attempt = 0
            while task.wait() do
                if pauseTasks then continue end
                repeat
                    wait()
                until humanoid.Health > 30

                if not hrp then
                    player.CharacterAdded:Wait()
                    hrp = player.Character:WaitForChild("HumanoidRootPart")
                end

                while true do
                    if not isNear(hrp, getTargetHumanoidRootPart(), 8) then
                        hrp.CFrame = outsidePart.CFrame + Vector3.new(0, 6, 0)
                        task.wait(1)
                    else
                        task.wait(6)
                        break
                    end
                end

                if pauseTasks then continue end

                pressKey(Enum.KeyCode.W)
                task.wait(1)

                if isNear(hrp, getTargetHumanoidRootPart(), 8) then
                    print("Teleport successful")
                    readyToReset = true
                    successfulDeaths += 1
                    local currentTime = os.clock()
                    local elapsed = math.round(currentTime - startTime)
                    ws:Send("From " .. player.Name .. ": Took " .. elapsed .. "s to get ready, " .. successfulDeaths .. "/" .. totalRespawns .. " successful.")
                    break
                end

                attempt += 1
                print("Attempt failed, retrying:", attempt)
                task.wait(2)
            end
        end
    end
end

main()
