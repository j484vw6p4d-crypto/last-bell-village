--!nocheck
-- VILLAGE-22 polished HUD. F is fly (not cook) - cook is C.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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

local function card(size, pos, bg)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = bg
	f.BackgroundTransparency = 0.12
	f.BorderSizePixel = 0
	f.Parent = gui
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 14)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(200, 160, 80)
	s.Thickness = 1
	s.Transparency = 0.4
	s.Parent = f
	return f
end

local top = card(UDim2.fromOffset(620, 128), UDim2.new(0.5, -310, 0, 14), Color3.fromRGB(18, 14, 10))
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -140, 0, 26)
title.Position = UDim2.fromOffset(16, 10)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(232, 196, 96)
title.Text = "VILLAGE-22"
title.Parent = top

local phase = Instance.new("TextLabel")
phase.BackgroundTransparency = 1
phase.Size = UDim2.fromOffset(120, 26)
phase.Position = UDim2.new(1, -130, 0, 10)
phase.Font = Enum.Font.GothamBold
phase.TextSize = 18
phase.TextColor3 = Color3.fromRGB(120, 220, 140)
phase.Text = "DAY"
phase.Parent = top

local taskLab = Instance.new("TextLabel")
taskLab.BackgroundTransparency = 1
taskLab.Size = UDim2.new(1, -32, 0, 28)
taskLab.Position = UDim2.fromOffset(16, 42)
taskLab.Font = Enum.Font.GothamBold
taskLab.TextSize = 16
taskLab.TextXAlignment = Enum.TextXAlignment.Left
taskLab.TextColor3 = Color3.fromRGB(240, 232, 220)
taskLab.Text = "Loading..."
taskLab.Parent = top

local tipLab = Instance.new("TextLabel")
tipLab.BackgroundTransparency = 1
tipLab.Size = UDim2.new(1, -32, 0, 22)
tipLab.Position = UDim2.fromOffset(16, 74)
tipLab.Font = Enum.Font.Gotham
tipLab.TextSize = 13
tipLab.TextXAlignment = Enum.TextXAlignment.Left
tipLab.TextColor3 = Color3.fromRGB(185, 178, 168)
tipLab.Text = ""
tipLab.Parent = top

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -32, 0, 8)
barBg.Position = UDim2.fromOffset(16, 106)
barBg.BackgroundColor3 = Color3.fromRGB(40, 32, 24)
barBg.BorderSizePixel = 0
barBg.Parent = top
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(210, 150, 60)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local bag = card(UDim2.fromOffset(240, 190), UDim2.new(0, 16, 1, -210), Color3.fromRGB(18, 14, 10))
local bagLab = Instance.new("TextLabel")
bagLab.BackgroundTransparency = 1
bagLab.Size = UDim2.new(1, -18, 1, -14)
bagLab.Position = UDim2.fromOffset(10, 8)
bagLab.Font = Enum.Font.Gotham
bagLab.TextSize = 15
bagLab.TextXAlignment = Enum.TextXAlignment.Left
bagLab.TextYAlignment = Enum.TextYAlignment.Top
bagLab.TextColor3 = Color3.fromRGB(230, 220, 200)
bagLab.Text = "Satchel"
bagLab.Parent = bag

local rich = card(UDim2.fromOffset(280, 70), UDim2.new(1, -296, 1, -90), Color3.fromRGB(18, 14, 10))
local richLab = Instance.new("TextLabel")
richLab.BackgroundTransparency = 1
richLab.Size = UDim2.new(1, -16, 1, -12)
richLab.Position = UDim2.fromOffset(8, 6)
richLab.Font = Enum.Font.Gotham
richLab.TextSize = 14
richLab.TextXAlignment = Enum.TextXAlignment.Left
richLab.TextYAlignment = Enum.TextYAlignment.Top
richLab.TextColor3 = Color3.fromRGB(220, 210, 180)
richLab.Text = "Richest: -"
richLab.Parent = rich

local keys = card(UDim2.fromOffset(560, 40), UDim2.new(0.5, -280, 1, -48), Color3.fromRGB(18, 14, 10))
local keyLab = Instance.new("TextLabel")
keyLab.BackgroundTransparency = 1
keyLab.Size = UDim2.fromScale(1, 1)
keyLab.Font = Enum.Font.Gotham
keyLab.TextSize = 13
keyLab.TextColor3 = Color3.fromRGB(210, 200, 180)
keyLab.Text = "E gather   C cook   Q bank   R steal   B upgrade   |   F fly"
keyLab.Parent = keys

local toast = Instance.new("TextLabel")
toast.BackgroundTransparency = 1
toast.Size = UDim2.fromOffset(620, 32)
toast.Position = UDim2.new(0.5, -310, 0, 152)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 17
toast.TextColor3 = Color3.fromRGB(255, 220, 140)
toast.TextTransparency = 1
toast.Text = ""
toast.Parent = gui

local bankFlash = Instance.new("TextLabel")
bankFlash.BackgroundTransparency = 1
bankFlash.Size = UDim2.fromOffset(400, 70)
bankFlash.Position = UDim2.new(0.5, -200, 0.35, 0)
bankFlash.Font = Enum.Font.GothamBold
bankFlash.TextSize = 48
bankFlash.TextColor3 = Color3.fromRGB(255, 220, 80)
bankFlash.TextStrokeTransparency = 0.4
bankFlash.TextTransparency = 1
bankFlash.Text = "BANKED!"
bankFlash.Parent = gui

local function showToast(msg)
	toast.Text = tostring(msg or "")
	toast.TextTransparency = 0
	task.delay(2.5, function()
		if toast.Text == tostring(msg or "") then
			TweenService:Create(toast, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
		end
	end)
end

local function flashBanked()
	bankFlash.TextTransparency = 0
	bankFlash.TextStrokeTransparency = 0.3
	TweenService:Create(bankFlash, TweenInfo.new(1.1), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

local remotes = ReplicatedStorage:WaitForChild("VillageRemotes", 20)
local act = remotes and remotes:WaitForChild("Act", 10)
if remotes then
	local state = remotes:WaitForChild("State", 10)
	local notify = remotes:WaitForChild("Notify", 10)
	local fx = remotes:WaitForChild("FX", 10)
	if state then
		state.OnClientEvent:Connect(function(s)
			if type(s) ~= "table" then
				return
			end
			title.Text = tostring(s.build or "VILLAGE-22")
			phase.Text = s.night and "NIGHT" or "DAY"
			phase.TextColor3 = s.night and Color3.fromRGB(160, 140, 255) or Color3.fromRGB(120, 220, 140)
			taskLab.Text = tostring(s.objective or "")
			tipLab.Text = tostring(s.tip or "")
			bagLab.Text = string.format(
				"Satchel\nCoins   %d\nHerbs   %d\nWood    %d\nCarry   %s\nStock   %d\nCottage T%d/%d",
				s.coins or 0,
				s.herbs or 0,
				s.wood or 0,
				(s.carry or 0) > 0 and "meal" or "-",
				s.stock or 0,
				s.upgradeTier or 0,
				s.maxUpgrade or 3
			)
			richLab.Text = string.format("Richest\n%s - %d coins", tostring(s.richName or "-"), s.richCoins or 0)
			TweenService:Create(barFill, TweenInfo.new(0.3), {
				Size = UDim2.fromScale(math.clamp(tonumber(s.progress) or 0, 0, 1), 1),
			}):Play()
		end)
	end
	if notify then
		notify.OnClientEvent:Connect(function(msg)
			showToast(msg)
			if type(msg) == "string" and string.find(string.upper(msg), "BANKED", 1, true) then
				flashBanked()
			end
		end)
	end
	if fx then
		fx.OnClientEvent:Connect(function(payload)
			local kind = type(payload) == "table" and payload.kind or payload
			if kind == "banked" then
				flashBanked()
			end
		end)
	end
end

-- Do NOT bind F here (Fly.client owns F). Cook is C.
local map = {
	[Enum.KeyCode.E] = "E",
	[Enum.KeyCode.C] = "C",
	[Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.R] = "R",
	[Enum.KeyCode.B] = "B",
}
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	local k = map[input.KeyCode]
	if k and act then
		act:FireServer(k)
	end
end)

print("[Village] VillageHud ready VILLAGE-22")
