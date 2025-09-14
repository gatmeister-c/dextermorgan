if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("v.1.0.7 PC (Wave)")

local pedos = {64489098,295331237,244844600,418086275,3294804378,142989311,281593651,3717066084,455275714,46567801,25689921,1229486091,54087314,63238912,446849296,141193516,81275825,96783330,67180844,412741116,193945439,93676120,140837601,63315426,142821118,175931803,194512073,87189764,93281166,208929505,418199326,957835150,47352513,632886139,1517131734,1810535041,195538733,156152502,122209625,102045519,111250044,29706395,730176906,1424338327,9212846,48058122,955294,5046659439,5046661126,5046662686,959606619,366613818,1024216621,278097946,50801509,40397833,241063740,646366887,1434829778,25048901,155413858,151691292,10497435,513615792,55893752,55476024,136584758,16983447,3111449,271400893,94693025,5005262660,141211828,114332275,42066711,69262878,92504899,50585425,31365111,49405424,166406495,2457253857,29761878,513242595,335465171}
-- Testers and above in CRIMCORP
-- Piesaregoodforhealth, hatsunecreations

local running = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

task.spawn(function()
    local menuLoaded = false
    local menuFunc
    while task.wait(1) do

        if tostring(game.PlaceId) == "4588604953" then 
            running = false
            if not menuLoaded then
                menuLoaded = true
                menuFunc = game:GetService("RunService").Heartbeat:Connect(function()
                    ReplicatedStorage:WaitForChild("Events").Play:InvokeServer("play", "Casual", nil, 1) 
                    print("Looping")
                end) 
            end
        end

        if tostring(game.PlaceId) == "8343259840" then
            menuLoaded = false
            task.wait(10)
            local button = Players.LocalPlayer:
                        WaitForChild("PlayerGui"):
                        WaitForChild("Intro"):
                        WaitForChild("Frame"):
                        WaitForChild("ButtonsFrame"):
                        WaitForChild("PlayFrame"):
                        WaitForChild("TextButton")

            for _, connection in getconnections(button.MouseButton1Click) do
                connection:Fire()
            end
            print("Clicked Play")

            if menuFunc then
                menuFunc:Disconnect()
            end
            task.wait(5)
        end
    end
end)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local camera = workspace.Camera
local playerGui = player:WaitForChild("PlayerGui")

local allowanceTimerPath = ReplicatedStorage:
                        WaitForChild("PlayerbaseData2"):
                        WaitForChild(player.Name):
                        WaitForChild("NextAllowance")
local allowanceTimer = allowanceTimerPath.Value
local allowanceReady = false
local claimedAllowancesCount = 0

local stats = playerGui:
            WaitForChild("CoreGUI"):
            WaitForChild("StatsFrame"):
            WaitForChild("Frame2"):
            WaitForChild("Frame"):
            WaitForChild("Container")
local cashUI = stats:WaitForChild("Cash"):WaitForChild("Amt")
local bankUI = stats:WaitForChild("Bank"):WaitForChild("Amt")

local levelFrame = playerGui:
            WaitForChild("CoreGUI"):
            WaitForChild("LevelFrame")
local xpUI = levelFrame:WaitForChild("Bar"):WaitForChild("Stat")
local levelUI = levelFrame:WaitForChild("LevelBox"):WaitForChild("LevelNumber")

local fpscap = 5

-- ATMS --
local atms = {}
local atmsFolder = workspace:WaitForChild("Map"):WaitForChild("ATMz")
for i, v in atmsFolder:GetChildren() do
    table.insert(atms, v)
    for _, child in v:GetChildren() do
        if child.Name == "MainPart" then
            local part = Instance.new("Part")
            part.Size = Vector3.new(20, 1, 20)
            part.Parent = workspace
            part.Anchored = true
            part.Position = child.Position + Vector3.new(0, -14, 0)
        end
    end
end

local function getNearestAtm()
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

local function buyersProtection(bool)
    local args = {
        bool,
        "ATM",
        workspace:WaitForChild("Map"):WaitForChild("ATMz"):WaitForChild("ATM"):WaitForChild("MainPart")
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("BYZERSPROTEC"):FireServer(unpack(args))
end

local allowanceButton = playerGui:
                        WaitForChild("CoreGUI"):
                        WaitForChild("ATMFrame"):
                        WaitForChild("ATMFrame"):
                        WaitForChild("AllowanceFrame"):
                        WaitForChild("ClaimButton"):
                        WaitForChild("TextButton")

local function claimAllowance()
    for i, connection in getconnections(allowanceButton.MouseButton1Down) do
        connection:Fire()
    end
end

local function focusCameraOnATM(atmMainPart)
	local lookFrom = atmMainPart.Position + Vector3.new(0, 3, 5)
	local lookTo = atmMainPart.Position

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(lookFrom, lookTo)
end

local function resetCamera()
	camera.CameraType = Enum.CameraType.Custom
end

local function interactWithATM()
    local atm = getNearestAtm()
    if not atm then return end

    local atmMainPart = atm.MainPart
    if not atmMainPart then return end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = atmMainPart.CFrame * CFrame.new(0, 0, -3)

    local prompt = atmMainPart.posA:FindFirstChild("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end

    hrp.CFrame = atmMainPart.CFrame * CFrame.new(0, 0, -3)
end

local function noclip()
    for _, v in atmsFolder:GetDescendants() do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

-- RESPAWN --
local function deathRespawn()
    local args = {
        "KMG4R904"
    }
    local result = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer(unpack(args))
    return result
end

task.spawn(function()
    while task.wait(1) do
        if game:GetService("ReplicatedStorage").PlayerbaseData2:FindFirstChild(player.Name).CanRespawn.Value == true or humanoid.Health <= 15 then
            deathRespawn()
        end
    end
end)

-- MISC --
player.CharacterAdded:Connect(function(character)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

task.spawn(function() -- Rejoin Main Menu every 2 hours (8 atm claims) to reset RAM usage
    while task.wait(30) do
        if claimedAllowancesCount >= 8 then
            TeleportService:Teleport(4588604953, player)
        end
    end
end)

task.spawn(function() -- Allowance Timer Counter
    while task.wait(1) do
        local timer = allowanceTimerPath.Value

        if timer == 0 then
            allowanceReady = true

        elseif timer <= 15 then
            humanoid.Health = 0
            task.wait(timer)

        else
            allowanceReady = false
        end

    end
end)

task.spawn(function() -- Because for some reason the loopCount >= 40 check doesnt always reset
    while task.wait(5) do
        if allowanceReady then
            task.wait(60) 
            if allowanceReady then
                humanoid.Health = 0
            end
        end
    end
end)

task.spawn(function() -- setfpscap() gets overridden sometimes
	while task.wait(1) do
        setfpscap(fpscap)
    end
end)

Players.PlayerAdded:Connect(function(player) -- Blacklist
    if table.find(pedos, player.UserId) then
        plr:Kick("A blocked user, ".. player .. ", has joined. You have been disconnected.")
    end
end)

-- HTTP Requests
local function postStats()
    local updates = {
        {
            name = player.Name,
            cash = cashUI.Text,
            bank = bankUI.Text,
            level = levelUI.Text,
            xp = xpUI.Text,
            status = "online",
            lastClaimed = os.time()
        }
    }

    local headers = {
        ["Content-Type"] = "application/json",
    }

    local success, result = pcall(function()
        return request({
            Url = "https://dash.crimillion.com/api/accounts",
            Method = "PATCH",
            Headers = headers,
            Body = HttpService:JSONEncode(updates)
        })
    end)

    if success and result.Success then
        print("Patch success:", result.Body)
    else
        warn("Patch failed:", result and result.Body or "Unknown error")
    end
end

-- MAIN --
local function main()
    if running then return end

    running = true
    local looping = false
    local atm = nil
    local count = 0
    local loopCount = 0
    
    while task.wait(1) do
        if allowanceReady and not looping then
            fpscap = 60
            local newAtm = nil
            looping = true

            repeat
                newAtm = getNearestAtm()
                interactWithATM()
                task.wait(0.1)
                claimAllowance()
                loopCount += 1
                task.wait(0.4)
            until not allowanceReady or loopCount >= 40

            looping = false
            loopCount = 0

            if loopCount >= 40 then -- if atm isnt found within 40 tries
                humanoid.Health = 0
                task.wait(15)
            else
                count += 1
                claimedAllowancesCount += 1

                if newAtm == atm then
                    if count >= 2 then
                        humanoid.Health = 0
                        task.wait(15)
                    end
                else   
                    count = 1
                end

                postStats()
                fpscap = 5
            end
        end
    end
end

RunService:Set3dRenderingEnabled(false)
main()
