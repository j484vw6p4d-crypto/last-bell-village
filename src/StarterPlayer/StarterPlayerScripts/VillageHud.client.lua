--!nocheck
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	f.BackgroundTransparency = 0.12
	f.BorderSizePixel = 0
	f.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = f
	return f
end

local top = card(gui, UDim2.fromOffset(420, 74), UDim2.new(0.5, -210, 0, 14), Color3.fromRGB(18, 16, 14))
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.fromOffset(10, 6)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(232, 196, 96)
title.Text = "TEST 1  ·  VILLAGE-02"
title.Parent = top
local phase = Instance.new("TextLabel")
phase.BackgroundTransparency = 1
phase.Size = UDim2.fromOffset(90, 22)
phase.Position = UDim2.new(1, -100, 0, 8)
phase.Font = Enum.Font.GothamBold
phase.TextSize = 16
phase.TextColor3 = Color3.fromRGB(120, 220, 140)
phase.Text = "DAY"
phase.Parent = top
local taskLab = Instance.new("TextLabel")
taskLab.BackgroundTransparency = 1
taskLab.Size = UDim2.new(1, -20, 0, 32)
taskLab.Position = UDim2.fromOffset(10, 36)
taskLab.Font = Enum.Font.Gotham
taskLab.TextSize = 15
taskLab.TextXAlignment = Enum.TextXAlignment.Left
taskLab.TextColor3 = Color3.fromRGB(230, 222, 210)
taskLab.Text = "Walk the square"
taskLab.Parent = top

local bag = card(gui, UDim2.fromOffset(240, 110), UDim2.new(0, 16, 1, -130), Color3.fromRGB(16, 16, 18))
local bagLab = Instance.new("TextLabel")
bagLab.BackgroundTransparency = 1
bagLab.Size = UDim2.new(1, -16, 1, -12)
bagLab.Position = UDim2.fromOffset(8, 6)
bagLab.Font = Enum.Font.Gotham
bagLab.TextSize = 16
bagLab.TextXAlignment = Enum.TextXAlignment.Left
bagLab.TextYAlignment = Enum.TextYAlignment.Top
bagLab.TextColor3 = Color3.fromRGB(230, 220, 200)
bagLab.Text = "0 coins"
bagLab.Parent = bag

local keys = card(gui, UDim2.fromOffset(360, 40), UDim2.new(1, -376, 1, -54), Color3.fromRGB(16, 16, 18))
local keyLab = Instance.new("TextLabel")
keyLab.BackgroundTransparency = 1
keyLab.Size = UDim2.fromScale(1, 1)
keyLab.Font = Enum.Font.Gotham
keyLab.TextSize = 13
keyLab.TextColor3 = Color3.fromRGB(210, 200, 180)
keyLab.Text = "E gather   F cook   Q bank   R steal   P rebirth"
keyLab.Parent = keys

local toast = Instance.new("TextLabel")
toast.BackgroundTransparency = 1
toast.Size = UDim2.fromOffset(420, 28)
toast.Position = UDim2.new(0.5, -210, 0, 96)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 16
toast.TextColor3 = Color3.fromRGB(255, 230, 140)
toast.Text = ""
toast.Parent = gui

local remotesFolder = ReplicatedStorage:WaitForChild("VillageRemotes", 15)
local function bind()
	if not remotesFolder then
		return
	end
	local state = remotesFolder:WaitForChild("State", 10)
	local notify = remotesFolder:WaitForChild("Notify", 10)
	local act = remotesFolder:WaitForChild("Act", 10)
	if state then
		state.OnClientEvent:Connect(function(s)
			if type(s) ~= "table" then
				return
			end
			title.Text = "TEST 1  ·  " .. tostring(s.build or "VILLAGE")
			phase.Text = s.night and "NIGHT" or "DAY"
			phase.TextColor3 = s.night and Color3.fromRGB(140, 170, 255) or Color3.fromRGB(120, 220, 140)
			taskLab.Text = tostring(s.task or "")
			bagLab.Text = string.format(
				"%d coins\nHerbs %d  Wood %d  Meals %d\nStall #%s  Rebirths %d\n%s  %ds",
				s.coins or 0,
				s.herbs or 0,
				s.wood or 0,
				s.meals or 0,
				tostring(s.stallId or "-"),
				s.rebirths or 0,
				s.night and "Steal is ON" or "Steal is OFF",
				s.seconds or 0
			)
		end)
	end
	if notify then
		notify.OnClientEvent:Connect(function(msg)
			toast.Text = tostring(msg or "")
			task.delay(2.4, function()
				if toast.Text == tostring(msg or "") then
					toast.Text = ""
				end
			end)
		end)
	end
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or not act then
			return
		end
		local map = {
			[Enum.KeyCode.E] = "gather",
			[Enum.KeyCode.F] = "cook",
			[Enum.KeyCode.Q] = "bank",
			[Enum.KeyCode.R] = "steal",
			[Enum.KeyCode.P] = "rebirth",
		}
		local kind = map[input.KeyCode]
		if kind then
			act:FireServer(kind)
		end
	end)
end

bind()
