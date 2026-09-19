--!nocheck
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("VillageHud")
if old then old:Destroy() end

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

local top = card(UDim2.fromOffset(560, 120), UDim2.new(0.5, -280, 0, 14), Color3.fromRGB(12, 10, 14))
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -130, 0, 26)
title.Position = UDim2.fromOffset(16, 10)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(232, 196, 96)
title.Text = "TEST 1  ·  VILLAGE-15"
title.Parent = top

local phase = Instance.new("TextLabel")
phase.BackgroundTransparency = 1
phase.Size = UDim2.fromOffset(110, 26)
phase.Position = UDim2.new(1, -120, 0, 10)
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

local hintLab = Instance.new("TextLabel")
hintLab.BackgroundTransparency = 1
hintLab.Size = UDim2.new(1, -32, 0, 22)
hintLab.Position = UDim2.fromOffset(16, 74)
hintLab.Font = Enum.Font.Gotham
hintLab.TextSize = 13
hintLab.TextXAlignment = Enum.TextXAlignment.Left
hintLab.TextColor3 = Color3.fromRGB(185, 178, 168)
hintLab.Text = ""
hintLab.Parent = top

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -32, 0, 8)
barBg.Position = UDim2.fromOffset(16, 102)
barBg.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
barBg.BorderSizePixel = 0
barBg.Parent = top
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(210, 150, 60)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local bag = card(UDim2.fromOffset(220, 148), UDim2.new(0, 16, 1, -168), Color3.fromRGB(12, 12, 16))
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

local list = card(UDim2.fromOffset(300, 168), UDim2.new(1, -316, 1, -188), Color3.fromRGB(12, 12, 16))
local listLab = Instance.new("TextLabel")
listLab.BackgroundTransparency = 1
listLab.Size = UDim2.new(1, -18, 1, -14)
listLab.Position = UDim2.fromOffset(10, 8)
listLab.Font = Enum.Font.Gotham
listLab.TextSize = 14
listLab.TextXAlignment = Enum.TextXAlignment.Left
listLab.TextYAlignment = Enum.TextYAlignment.Top
listLab.TextColor3 = Color3.fromRGB(220, 214, 200)
listLab.Text = "Tasks"
listLab.Parent = list

local keys = card(UDim2.fromOffset(460, 40), UDim2.new(0.5, -230, 1, -48), Color3.fromRGB(12, 12, 16))
local keyLab = Instance.new("TextLabel")
keyLab.BackgroundTransparency = 1
keyLab.Size = UDim2.fromScale(1, 1)
keyLab.Font = Enum.Font.Gotham
keyLab.TextSize = 13
keyLab.TextColor3 = Color3.fromRGB(210, 200, 180)
keyLab.Text = "E gather   F cook   Q bank (your base)   R steal (night)   P rebirth"
keyLab.Parent = keys

local toast = Instance.new("TextLabel")
toast.BackgroundTransparency = 1
toast.Size = UDim2.fromOffset(560, 32)
toast.Position = UDim2.new(0.5, -280, 0, 146)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 17
toast.TextColor3 = Color3.fromRGB(255, 220, 140)
toast.TextTransparency = 1
toast.Text = ""
toast.Parent = gui

local function showToast(msg)
	toast.Text = tostring(msg or "")
	toast.TextTransparency = 0
	task.delay(2.5, function()
		if toast.Text == tostring(msg or "") then
			TweenService:Create(toast, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
		end
	end)
end

local remotes = ReplicatedStorage:WaitForChild("VillageRemotes", 20)
local act = remotes and remotes:WaitForChild("Act", 10)
if remotes then
	local state = remotes:WaitForChild("State", 10)
	local notify = remotes:WaitForChild("Notify", 10)
	if state then
		state.OnClientEvent:Connect(function(s)
			if type(s) ~= "table" then return end
			title.Text = "TEST 1  ·  " .. tostring(s.build or "VILLAGE-15")
			phase.Text = s.night and "NIGHT" or "DAY"
			phase.TextColor3 = s.night and Color3.fromRGB(160, 140, 255) or Color3.fromRGB(120, 220, 140)
			taskLab.Text = tostring(s.objective or "")
			hintLab.Text = string.format("%ds  ·  goal %d  ·  rebirths %d%s", s.seconds or 0, s.goal or 80, s.rebirths or 0, s.night and "  ·  something watches" or "")
			bagLab.Text = string.format("Satchel\nCoins  %d\nHerbs  %d\nWood   %d\nMeal   %s", s.coins or 0, s.herbs or 0, s.wood or 0, (s.carry or 0) > 0 and "ready" or "—")
			if type(s.checklist) == "table" then
				listLab.Text = "Tasks\n" .. table.concat(s.checklist, "\n")
			end
			TweenService:Create(barFill, TweenInfo.new(0.3), {
				Size = UDim2.fromScale(math.clamp(tonumber(s.progress) or 0, 0, 1), 1),
			}):Play()
		end)
	end
	if notify then notify.OnClientEvent:Connect(showToast) end
end

local map = {
	[Enum.KeyCode.E] = "E", [Enum.KeyCode.F] = "F", [Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.R] = "R", [Enum.KeyCode.P] = "P",
}
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	local k = map[input.KeyCode]
	if k and act then act:FireServer(k) end
end)
