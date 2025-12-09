--[[
	Simplified Anti-AFK Script
--]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

if getgenv().AntiAfkGUI then
	getgenv().AntiAfkGUI:Destroy()
end

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Create GUI
local gui = Instance.new("ScreenGui")
getgenv().AntiAfkGUI = gui
gui.Name = "AntiAFK_GUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0.1, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui
Instance.new("UICorner", frame)

-- Title
local title = Instance.new("TextLabel")
title.Text = "Anti-AFK"
title.Size = UDim2.new(1, 0, 0, 25)
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Timer label
local timerLabel = Instance.new("TextLabel")
timerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
timerLabel.Size = UDim2.new(0, 150, 0, 30)
timerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.BackgroundTransparency = 1
timerLabel.TextSize = 18
timerLabel.Text = "00:00:00"
timerLabel.Parent = frame

-- Anti-AFK
Players.LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

-- Timer using DateTime
local startTime = DateTime.now().UnixTimestamp
RunService.Heartbeat:Connect(function()
	local elapsed = DateTime.now().UnixTimestamp - startTime
	local h = math.floor(elapsed / 3600)
	local m = math.floor((elapsed % 3600) / 60)
	local s = math.floor(elapsed % 60)
	timerLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
end)