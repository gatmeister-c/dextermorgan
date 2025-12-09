if not game:IsLoaded() then
    game.Loaded:Wait()
end

local pedos = {64489098,295331237,244844600,418086275,3294804378,142989311,281593651,3717066084,455275714,46567801,25689921,1229486091,54087314,63238912,446849296,141193516,81275825,96783330,67180844,412741116,193945439,93676120,140837601,63315426,142821118,175931803,194512073,87189764,93281166,208929505,418199326,957835150,47352513,632886139,1517131734,1810535041,195538733,156152502,122209625,102045519,111250044,29706395,730176906,1424338327,9212846,48058122,955294,5046659439,5046661126,5046662686,959606619,366613818,1024216621,278097946,50801509,40397833,241063740,646366887,1434829778,25048901,155413858,151691292,10497435,513615792,55893752,55476024,136584758,16983447,3111449,271400893,94693025,5005262660,141211828,114332275,42066711,69262878,92504899,50585425,31365111,49405424,166406495,2457253857,29761878,513242595,335465171}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local running = false
local shouldStop = false

-- Cleanup on game close
game:GetService("CoreGui").DescendantRemoving:Connect(function()
    shouldStop = true
    task.wait(0.1)
    RunService:Set3dRenderingEnabled(true)
end)

-- Anti-AFK (standalone, minimal)
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Blacklist
Players.PlayerAdded:Connect(function(p)
    if table.find(pedos, p.UserId) then
        player:Kick("Blocked user joined")
    end
end)

-- Main function
local function main()
    if running or shouldStop then return end
    running = true
    
    -- Wait for everything to load
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local playerGui = player:WaitForChild("PlayerGui")
    
    local allowanceTimerPath = ReplicatedStorage:WaitForChild("PlayerbaseData2"):WaitForChild(player.Name):WaitForChild("NextAllowance")
    local claims = 0
    
    -- Set FPS cap
    pcall(function() setfpscap(5) end)
    
    -- Disable 3D rendering
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
    
    -- Character refresh
    player.CharacterAdded:Connect(function(newChar)
        if shouldStop then return end
        char = newChar
        humanoid = char:WaitForChild("Humanoid")
        hrp = char:WaitForChild("HumanoidRootPart")
    end)
    
    -- Main loop
    while not shouldStop do
        task.wait(3)
        
        if shouldStop then break end
        
        -- Rejoin after 2 claims
        if claims >= 2 then
            shouldStop = true
            pcall(function() RunService:Set3dRenderingEnabled(true) end)
            task.wait(0.5)
            TeleportService:Teleport(4588604953, player)
            break
        end
        
        -- Auto respawn if needed
        local canRespawn = pcall(function()
            return ReplicatedStorage.PlayerbaseData2:FindFirstChild(player.Name).CanRespawn.Value
        end)
        
        if canRespawn or humanoid.Health <= 15 then
            pcall(function()
                ReplicatedStorage:WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer("KMG4R904")
            end)
            task.wait(5)
            continue
        end
        
        -- Check allowance timer
        local timer = allowanceTimerPath.Value
        if timer ~= 0 then continue end
        
        -- Claim allowance
        pcall(function() setfpscap(20) end)
        
        local success = false
        for attempt = 1, 8 do
            if shouldStop then break end
            
            -- Find nearest ATM
            local atmsFolder = workspace:FindFirstChild("Map")
            if not atmsFolder then break end
            atmsFolder = atmsFolder:FindFirstChild("ATMz")
            if not atmsFolder then break end
            
            local nearestAtm = nil
            local nearestDist = math.huge
            
            for _, v in pairs(atmsFolder:GetChildren()) do
                if v:FindFirstChild("MainPart") then
                    local dist = (hrp.Position - v.MainPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestAtm = v
                        nearestDist = dist
                    end
                end
            end
            
            if not nearestAtm then break end
            
            -- Teleport and interact
            local atmPart = nearestAtm.MainPart
            hrp.CFrame = atmPart.CFrame * CFrame.new(0, 0, -3)
            task.wait(0.3)
            
            local prompt = atmPart:FindFirstChild("posA")
            if prompt then 
                prompt = prompt:FindFirstChild("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
            
            task.wait(0.4)
            
            -- Click claim button
            local button = pcall(function()
                local btn = playerGui:WaitForChild("CoreGUI", 1):WaitForChild("ATMFrame", 1):WaitForChild("ATMFrame", 1):WaitForChild("AllowanceFrame", 1):WaitForChild("ClaimButton", 1):WaitForChild("TextButton", 1)
                for _, conn in pairs(getconnections(btn.MouseButton1Down)) do
                    conn:Fire()
                end
            end)
            
            task.wait(0.5)
            
            -- Check if claimed
            if allowanceTimerPath.Value > 0 then
                success = true
                claims = claims + 1
                break
            end
        end
        
        pcall(function() setfpscap(5) end)
        
        -- Respawn after claiming
        if success then
            task.wait(2)
            humanoid.Health = 0
            task.wait(10)
        end
    end
    
    -- Final cleanup
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
end

-- Start
task.spawn(main)
