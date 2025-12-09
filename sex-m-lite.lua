--[[
    SHUTDOWN TEST - Find what crashes on game exit
    Each portion has cleanup code to test
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("=== SCRIPT STARTED ===")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SHUTDOWN = false

-- ============================================
-- SHUTDOWN DETECTOR (Leave this always enabled)
-- ============================================
print("Setting up shutdown detector...")

local shutdownDetected = false

-- Method 1: Detect when CoreGui starts removing
game:GetService("CoreGui").DescendantRemoving:Connect(function()
    if not shutdownDetected then
        shutdownDetected = true
        SHUTDOWN = true
        print("!!! SHUTDOWN DETECTED (CoreGui) !!!")
    end
end)

-- Method 2: Detect when player is leaving
game:GetService("LogService").MessageOut:Connect(function(message)
    if message:find("Teleport") or message:find("leaving") then
        shutdownDetected = true
        SHUTDOWN = true
        print("!!! SHUTDOWN DETECTED (LogService) !!!")
    end
end)

-- Method 3: Detect player removing
Players.PlayerRemoving:Connect(function(p)
    if p == player then
        shutdownDetected = true
        SHUTDOWN = true
        print("!!! SHUTDOWN DETECTED (PlayerRemoving) !!!")
    end
end)

print("✓ Shutdown detector ready")

-- ============================================
-- TEST 1: FPS CAP (test if this crashes on exit)
-- ============================================
print("TEST 1: FPS Cap")

local fpsThread = task.spawn(function()
    while not SHUTDOWN do
        task.wait(1)
        pcall(function() setfpscap(5) end)
    end
    print("✓ FPS thread stopped cleanly")
end)

print("✓ TEST 1 loaded")

-- ============================================
-- TEST 2: 3D RENDERING (test if this crashes on exit)
-- ============================================
print("TEST 2: 3D Rendering")

local renderingEnabled = false
pcall(function() 
    RunService:Set3dRenderingEnabled(false)
    renderingEnabled = true
    print("✓ 3D rendering disabled")
end)

-- Cleanup function for rendering
task.spawn(function()
    while not SHUTDOWN do
        task.wait(1)
    end
    
    if renderingEnabled then
        pcall(function()
            RunService:Set3dRenderingEnabled(true)
            print("✓ 3D rendering re-enabled on shutdown")
        end)
    end
end)

print("✓ TEST 2 loaded")

-- ============================================
-- TEST 3: RESPAWN LOOP (test if this crashes on exit)
-- ============================================
print("TEST 3: Respawn Loop")

local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local respawnThread = task.spawn(function()
    while not SHUTDOWN do
        task.wait(10)
        
        if SHUTDOWN then break end
        
        local shouldRespawn = false
        pcall(function()
            shouldRespawn = ReplicatedStorage.PlayerbaseData2:FindFirstChild(player.Name).CanRespawn.Value
        end)
        
        if shouldRespawn or humanoid.Health <= 15 then
            pcall(function()
                ReplicatedStorage:WaitForChild("Events"):WaitForChild("DeathRespawn"):InvokeServer("KMG4R904")
            end)
        end
    end
    print("✓ Respawn thread stopped cleanly")
end)

print("✓ TEST 3 loaded")

-- ============================================
-- TEST 4: CHARACTER REFRESH (test if this crashes on exit)
-- ============================================
print("TEST 4: Character Refresh")

local charConnection = player.CharacterAdded:Connect(function(newChar)
    if SHUTDOWN then return end
    char = newChar
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    print("✓ Character refreshed")
end)

-- Disconnect on shutdown
task.spawn(function()
    while not SHUTDOWN do task.wait(1) end
    pcall(function() charConnection:Disconnect() end)
    print("✓ Character connection disconnected")
end)

print("✓ TEST 4 loaded")

-- ============================================
-- TEST 5: MAIN LOOP (test if this crashes on exit)
-- ============================================
print("TEST 5: Main Loop")

local allowanceTimerPath = ReplicatedStorage:WaitForChild("PlayerbaseData2"):WaitForChild(player.Name):WaitForChild("NextAllowance")

local mainThread = task.spawn(function()
    local claims = 0
    
    while not SHUTDOWN do
        task.wait(5)
        
        if SHUTDOWN then break end
        
        print("Loop tick, claims:", claims, "timer:", allowanceTimerPath.Value)
        
        if claims >= 2 then
            SHUTDOWN = true
            print("Preparing to teleport...")
            task.wait(0.5)
            
            -- Re-enable rendering before teleport
            pcall(function() RunService:Set3dRenderingEnabled(true) end)
            task.wait(0.5)
            
            -- Teleport
            pcall(function()
                TeleportService:Teleport(4588604953, player)
            end)
            break
        end
        
        if allowanceTimerPath.Value == 0 then
            -- Simple claim attempt
            local atmsFolder = workspace:FindFirstChild("Map")
            if atmsFolder then
                atmsFolder = atmsFolder:FindFirstChild("ATMz")
                if atmsFolder then
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
                    
                    if nearestAtm and not SHUTDOWN then
                        hrp.CFrame = nearestAtm.MainPart.CFrame * CFrame.new(0, 0, -3)
                        task.wait(0.3)
                        
                        local prompt = nearestAtm.MainPart:FindFirstChild("posA")
                        if prompt then 
                            prompt = prompt:FindFirstChild("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt) end
                        end
                        
                        task.wait(0.5)
                        
                        -- Try to claim
                        pcall(function()
                            local playerGui = player:WaitForChild("PlayerGui")
                            local btn = playerGui:WaitForChild("CoreGUI", 1):WaitForChild("ATMFrame", 1):WaitForChild("ATMFrame", 1):WaitForChild("AllowanceFrame", 1):WaitForChild("ClaimButton", 1):WaitForChild("TextButton", 1)
                            for _, conn in pairs(getconnections(btn.MouseButton1Down)) do
                                conn:Fire()
                            end
                        end)
                        
                        task.wait(0.5)
                        
                        if allowanceTimerPath.Value > 0 then
                            claims = claims + 1
                            print("✓ Claimed! Total:", claims)
                        end
                        
                        humanoid.Health = 0
                        task.wait(10)
                    end
                end
            end
        end
    end
    print("✓ Main thread stopped cleanly")
end)

print("✓ TEST 5 loaded")

-- ============================================
-- TEST 6: ANTI-AFK (test if this crashes on exit)
-- ============================================
print("TEST 6: Anti-AFK")

local afkConnection = player.Idled:Connect(function()
    if SHUTDOWN then return end
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while not SHUTDOWN do task.wait(1) end
    pcall(function() afkConnection:Disconnect() end)
    print("✓ AFK connection disconnected")
end)

print("✓ TEST 6 loaded")

print("=== ALL TESTS LOADED ===")
print("Now leave the game and check console")
print("Note which test DOESN'T print 'stopped cleanly'")
