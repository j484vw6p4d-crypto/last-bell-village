--!nocheck
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("VillageHud")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "VillageHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = pg

local function card(parent, size, pos, bg)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = bg
	f.BackgroundTransparency = 0.08
	f.BorderSizePixel = 0
	f.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = f
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(212, 176, 96)
	stroke.Thickness = 1
	stroke.Transparency = 0.55
	stroke.Parent = f
	return f
end

local top = card(gui, UDim2.fromOffset(520, 100), UDim2.new(0.5, -260, 0, 16), Color3.fromRGB(16, 14, 12))
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -120, 0, 26)
title.Position = UDim2.fromOffset(14, 8)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(232, 196, 96)
title.Text = "TEST 1  ·  VILLAGE-03"
title.Parent = top

local phase = Instance.new("TextLabel")
phase.BackgroundTransparency = 1
phase.Size = UDim2.fromOffset(100, 26)
phase.Position = UDim2.new(1, -110, 0, 8)
phase.Font = Enum.Font.GothamBold
phase.TextSize = 18
phase.TextColor3 = Color3.fromRGB(120, 220, 140)
phase.Text = "DAY"
phase.Parent = top

local taskLab = Instance.new("TextLabel")
taskLab.BackgroundTransparency = 1
taskLab.Size = UDim2.new(1, -28, 0, 24)
taskLab.Position = UDim2.fromOffset(14, 38)
taskLab.Font = Enum.Font.GothamBold
taskLab.TextSize = 16
taskLab.TextXAlignment = Enum.TextXAlignment.Left
taskLab.TextColor3 = Color3.fromRGB(235, 228, 214)
taskLab.Text = "Loading..."
taskLab.Parent = top

local hintLab = Instance.new("TextLabel")
hintLab.BackgroundTransparency = 1
hintLab.Size = UDim2.new(1, -28, 0, 24)
hintLab.Position = UDim2.fromOffset(14, 66)
hintLab.Font = Enum.Font.Gotham
hintLab.TextSize = 14
hintLab.TextXAlignment = Enum.TextXAlignment.Left
hintLab.TextColor3 = Color3.fromRGB(190, 184, 170)
hintLab.Text = ""
hintLab.Parent = top

local bag = card(gui, UDim2.fromOffset(250, 150), UDim2.new(0, 18, 1, -172), Color3.fromRGB(14, 14, 16))
local bagLab = Instance.new("TextLabel")
bagLab.BackgroundTransparency = 1
bagLab.Size = UDim2.new(1, -20, 1, -16)
bagLab.Position = UDim2.fromOffset(10, 8)
bagLab.Font = Enum.Font.Gotham
bagLab.TextSize = 15
bagLab.TextXAlignment = Enum.TextXAlignment.Left
bagLab.TextYAlignment = Enum.TextYAlignment.Top
bagLab.TextColor3 = Color3.fromRGB(230, 220, 200)
bagLab.Text = "Satchel"
bagLab.Parent = bag

local keys = card(gui, UDim2.fromOffset(360, 42), UDim2.new(1, -378, 1, -58), Color3.fromRGB(14, 14, 16))
local keyLab = Instance.new("TextLabel")
keyLab.BackgroundTransparency = 1
keyLab.Size = UDim2.fromScale(1, 1)
keyLab.Font = Enum.Font.Gotham
keyLab.TextSize = 13
keyLab.TextColor3 = Color3.fromRGB(210, 200, 180)
keyLab.Text = "E gather   F cook   Q bank   R steal (night)   P rebirth"
keyLab.Parent = keys

local toast = Instance.new("TextLabel")
toast.BackgroundTransparency = 1
toast.Size = UDim2.fromOffset(560, 30)
toast.Position = UDim2.new(0.5, -280, 0, 128)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 17
toast.TextColor3 = Color3.fromRGB(255, 230, 140)
toast.Text = ""
toast.Parent = gui

local remotesFolder = ReplicatedStorage:WaitForChild("VillageRemotes", 20)
local actRemote = remotesFolder and remotesFolder:WaitForChild("Act", 10)

local function bind()
	if not remotesFolder then
		return
	end
	local state = remotesFolder:WaitForChild("State", 10)
	local notify = remotesFolder:WaitForChild("Notify", 10)
	if state then
		state.OnClientEvent:Connect(function(s)
			if type(s) ~= "table" then
				return
			end
			title.Text = "TEST 1  ·  " .. tostring(s.build or "VILLAGE-03")
			phase.Text = s.night and "NIGHT" or "DAY"
			phase.TextColor3 = s.night and Color3.fromRGB(140, 170, 255) or Color3.fromRGB(120, 220, 140)
			taskLab.Text = tostring(s.objective or "")
			hintLab.Text = string.format("%ds left  ·  goal %d coins  ·  rebirths %d", s.seconds or 0, s.goal or 80, s.rebirths or 0)
			bagLab.Text = string.format(
				"Satchel\nCoins  %d\nHerbs  %d\nWood   %d\nMeal   %s\nStall  %d",
				s.coins or 0,
				s.herbs or 0,
				s.wood or 0,
				(s.carry or 0) > 0 and "ready" or "—",
				s.stock or 0
			)
		end)
	end
	if notify then
		notify.OnClientEvent:Connect(function(msg)
			toast.Text = tostring(msg or "")
			task.delay(2.8, function()
				if toast.Text == tostring(msg or "") then
					toast.Text = ""
				end
			end)
		end)
	end
end

bind()

local map = {
	[Enum.KeyCode.E] = "E",
	[Enum.KeyCode.F] = "F",
	[Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.R] = "R",
	[Enum.KeyCode.P] = "P",
}

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	local kind = map[input.KeyCode]
	if kind and actRemote then
		actRemote:FireServer(kind)
	end
end)
