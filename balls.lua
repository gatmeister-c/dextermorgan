--[[
	WRITTEN BY THE ONE AND ONLY CLANKA MODEL 5019023EC3
--]]

-- Wait until the game and player are fully loaded
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- Destroy any existing GUI if re-executed
if getgenv().AntiAfkGUI then
	getgenv().AntiAfkGUI:Destroy()
end

-- Main setup
getgenv().AntiAfkGUI = Instance.new("ScreenGui")
local gui = getgenv().AntiAfkGUI
gui.Name = "AntiAFK_GUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Frame setup
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 225, 0, 95)
frame.Position = UDim2.new(0.1, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui
Instance.new("UICorner", frame)

-- Title
local title = Instance.new("TextLabel")
title.Parent = frame
title.Text = "Anti-AFK v2"
title.Size = UDim2.new(1, 0, 0, 20)
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Size = UDim2.new(0, 25, 0, 20)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Ping + FPS + Timer labels
local pingLabel = Instance.new("TextLabel", frame)
pingLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
pingLabel.Size = UDim2.new(0, 100, 0, 20)
pingLabel.TextColor3 = Color3.new(1, 1, 1)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: --"

local fpsLabel = Instance.new("TextLabel", frame)
fpsLabel.Position = UDim2.new(0.55, 0, 0.35, 0)
fpsLabel.Size = UDim2.new(0, 100, 0, 20)
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"

local timerLabel = Instance.new("TextLabel", frame)
timerLabel.Position = UDim2.new(0.35, 0, 0.7, 0)
timerLabel.Size = UDim2.new(0, 80, 0, 20)
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00:00:00"

-- Line
local line = Instance.new("Frame", frame)
line.Size = UDim2.new(1, 0, 0, 2)
line.Position = UDim2.new(0, 0, 0.25, 0)
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", line)

-- Status label
local status = Instance.new("TextLabel", frame)
status.Text = "Anti-AFK Active"
status.Position = UDim2.new(0.1, 0, 0.85, 0)
status.Size = UDim2.new(0.8, 0, 0, 15)
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.TextSize = 14

-- Make draggable
local dragging = false
local dragStart, startPos
local UserInputService = game:GetService("UserInputService")

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game.Players.LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

-- FPS counter
task.spawn(function()
	local RunService = game:GetService("RunService")
	local lastTime = tick()
	RunService.RenderStepped:Connect(function()
		local now = tick()
		local fps = math.floor(1 / math.max(now - lastTime, 0.0001))
		lastTime = now
		fpsLabel.Text = "FPS: " .. fps
	end)
end)

-- Ping updater
task.spawn(function()
	local Stats = game:GetService("Stats")
	while gui.Parent do
		task.wait(1)
		local pingStat = Stats:FindFirstChild("PerformanceStats") and Stats.PerformanceStats:FindFirstChild("Ping")
		if pingStat then
			pingLabel.Text = "Ping: " .. math.floor(pingStat:GetValue())
		end
	end
end)

-- Timer
task.spawn(function()
	local h, m, s = 0, 0, 0
	while gui.Parent do
		task.wait(1)
		s += 1
		if s >= 60 then s, m = 0, m + 1 end
		if m >= 60 then m, h = 0, h + 1 end
		timerLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
	end
end)
