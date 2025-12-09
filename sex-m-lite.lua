if not game:IsLoaded() then
    game.Loaded:Wait()
end

local pedos = {64489098,295331237,244844600,418086275,3294804378,142989311,281593651,3717066084,455275714,46567801,25689921,1229486091,54087314,63238912,446849296,141193516,81275825,96783330,67180844,412741116,193945439,93676120,140837601,63315426,142821118,175931803,194512073,87189764,93281166,208929505,418199326,957835150,47352513,632886139,1517131734,1810535041,195538733,156152502,122209625,102045519,111250044,29706395,730176906,1424338327,9212846,48058122,955294,5046659439,5046661126,5046662686,959606619,366613818,1024216621,278097946,50801509,40397833,241063740,646366887,1434829778,25048901,155413858,151691292,10497435,513615792,55893752,55476024,136584758,16983447,3111449,271400893,94693025,5005262660,141211828,114332275,42066711,69262878,92504899,50585425,31365111,49405424,166406495,2457253857,29761878,513242595,335465171}

local running = false
local connections = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")

local allowanceTimerPath = ReplicatedStorage:WaitForChild("PlayerbaseData2"):WaitForChild(player.Name):WaitForChild("NextAllowance")
local claimedAllowancesCount = 0

-- Cleanup function
local function cleanup()
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    connections = {}
    RunService:Set3dRenderingEnabled(true)
end

-- Menu handler (simplified)
table.insert(connections, game:GetService("RunService").Heartbeat:Connect(function()
    if tostring(game.PlaceId) == "4588604953" and not running then
        pcall(function()
            ReplicatedStorage:WaitForChild("Events").Play:InvokeServer("play", "M-Casual", nil, 1)
        end)
    end
end))

-- ATM functions
local function getNearestAtm()
    local atmsFolder = workspace:WaitForChild("Map"):WaitForChild("ATMz")
    local nearestAtm = nil
    local nearestDistance = math.huge
    
    for _, v in pairs(atmsFolder:GetChildren()) do
        local distance = (hrp.Position - v.MainPart.Position).Magnitude
        if distance < nearestDistance then
            nearestAtm = v
            nearestDistance = distance
        end
    end
    return nearestAtm
end

local function claimAllowance()
    pcall(function()
        local allowanceButton = playerGui:WaitForChild("CoreGUI"):WaitForChild("ATMFrame"):WaitForChild("ATMFrame"):WaitForChild("AllowanceFrame"):WaitForChild("ClaimButton"):WaitForChild("TextButton")
        for _, connection in pairs(getconnections(allowanceButton.MouseButton1Down)) do
            connection:Fire()
        end
    end)
end

local function interactWithATM()
    local atm = getNearestAtm()
    if not atm then return false end
    
    local atmMainPart = atm.MainPart
    if not atmMainPart then return false end
    
    hrp.CFrame = atmMainPart.CFrame * CFrame.new(0, 0, -3)
    task.wait(0.2)
    
    local prompt = atmMainPart.posA:FindFirstChild("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
    
    return true
end

local function deathRespawn()
    pcall(function()
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer("KMG4R904")
    end)
end

-- Character refresh handler
table.insert(connections, player.CharacterAdded:Connect(function(character)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end))

-- Blacklist check
table.insert(connections, Players.PlayerAdded:Connect(function(newPlayer)
    if table.find(pedos, newPlayer.UserId) then
        player:Kick("A blocked user has joined.")
    end
end))

-- Main loop (consolidated)
local function main()
    if running then return end
    running = true
    
    setfpscap(5)
    RunService:Set3dRenderingEnabled(false)
    
    while task.wait(2) do
        local timer = allowanceTimerPath.Value
        
        -- Rejoin after 2 claims
        if claimedAllowancesCount >= 2 then
            cleanup()
            TeleportService:Teleport(4588604953, player)
            break
        end
        
        -- Handle low health or respawn ready
        if humanoid.Health <= 15 or ReplicatedStorage.PlayerbaseData2:FindFirstChild(player.Name).CanRespawn.Value then
            deathRespawn()
            task.wait(3)
        end
        
        -- Claim allowance when ready
        if timer == 0 then
            setfpscap(30)
            
            for attempt = 1, 10 do
                if interactWithATM() then
                    task.wait(0.3)
                    claimAllowance()
                    task.wait(0.5)
                    
                    if allowanceTimerPath.Value > 0 then
                        claimedAllowancesCount += 1
                        break
                    end
                end
                task.wait(0.5)
            end
            
            setfpscap(5)
            humanoid.Health = 0
            task.wait(5)
        end
    end
end

-- Start
task.spawn(main)

-- Anti-AFK (simplified)
task.spawn(function()
    while task.wait(120) do
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
end)
