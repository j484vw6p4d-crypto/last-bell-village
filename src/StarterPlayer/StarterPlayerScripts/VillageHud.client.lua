--!nocheck
local Players = game:GetService("Players")
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

local top = card(gui, UDim2.fromOffset(460, 92), UDim2.new(0.5, -230, 0, 14), Color3.fromRGB(18, 16, 14))
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.fromOffset(10, 6)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(232, 196, 96)
title.Text = "TEST 1  ·  MILLBROOK V2"
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
taskLab.Size = UDim2.new(1, -20, 0, 22)
taskLab.Position = UDim2.fromOffset(10, 32)
taskLab.Font = Enum.Font.GothamBold
taskLab.TextSize = 16
taskLab.TextXAlignment = Enum.TextXAlignment.Left
taskLab.TextColor3 = Color3.fromRGB(230, 222, 210)
taskLab.Text = "Loading task..."
taskLab.Parent = top

local hintLab = Instance.new("TextLabel")
hintLab.BackgroundTransparency = 1
hintLab.Size = UDim2.new(1, -20, 0, 28)
hintLab.Position = UDim2.fromOffset(10, 56)
hintLab.Font = Enum.Font.Gotham
hintLab.TextSize = 14
hintLab.TextXAlignment = Enum.TextXAlignment.Left
hintLab.TextColor3 = Color3.fromRGB(190, 184, 170)
hintLab.Text = ""
hintLab.Parent = top

local bag = card(gui, UDim2.fromOffset(280, 118), UDim2.new(0, 16, 1, -138), Color3.fromRGB(16, 16, 18))
local bagLab = Instance.new("TextLabel")
bagLab.BackgroundTransparency = 1
bagLab.Size = UDim2.new(1, -16, 1, -12)
bagLab.Position = UDim2.fromOffset(8, 6)
bagLab.Font = Enum.Font.Gotham
bagLab.TextSize = 15
bagLab.TextXAlignment = Enum.TextXAlignment.Left
bagLab.TextYAlignment = Enum.TextYAlignment.Top
bagLab.TextColor3 = Color3.fromRGB(230, 220, 200)
bagLab.Text = "Satchel empty"
bagLab.Parent = bag

local keys = card(gui, UDim2.fromOffset(280, 40), UDim2.new(1, -296, 1, -54), Color3.fromRGB(16, 16, 18))
local keyLab = Instance.new("TextLabel")
keyLab.BackgroundTransparency = 1
keyLab.Size = UDim2.fromScale(1, 1)
keyLab.Font = Enum.Font.Gotham
keyLab.TextSize = 13
keyLab.TextColor3 = Color3.fromRGB(210, 200, 180)
keyLab.Text = "E talk / pick / search / ring"
keyLab.Parent = keys

local toast = Instance.new("TextLabel")
toast.BackgroundTransparency = 1
toast.Size = UDim2.fromOffset(520, 28)
toast.Position = UDim2.new(0.5, -260, 0, 114)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 16
toast.TextColor3 = Color3.fromRGB(255, 230, 140)
toast.Text = ""
toast.Parent = gui

local ending = Instance.new("Frame")
ending.Size = UDim2.fromScale(1, 1)
ending.BackgroundColor3 = Color3.fromRGB(8, 10, 8)
ending.BackgroundTransparency = 0.35
ending.Visible = false
ending.Parent = gui
local endTitle = Instance.new("TextLabel")
endTitle.BackgroundTransparency = 1
endTitle.AnchorPoint = Vector2.new(0.5, 0.5)
endTitle.Position = UDim2.new(0.5, 0, 0.4, 0)
endTitle.Size = UDim2.new(0.8, 0, 0, 48)
endTitle.Font = Enum.Font.GothamBold
endTitle.TextSize = 36
endTitle.TextColor3 = Color3.fromRGB(232, 206, 110)
endTitle.Text = "THE LAST BELL RINGS"
endTitle.Parent = ending
local endBody = Instance.new("TextLabel")
endBody.BackgroundTransparency = 1
endBody.AnchorPoint = Vector2.new(0.5, 0)
endBody.Position = UDim2.new(0.5, 0, 0.48, 0)
endBody.Size = UDim2.new(0.55, 0, 0, 80)
endBody.Font = Enum.Font.Gotham
endBody.TextSize = 18
endBody.TextWrapped = true
endBody.TextColor3 = Color3.fromRGB(230, 226, 214)
endBody.Text = "The valley hears the chapel again. Harvest can begin."
endBody.Parent = ending

local remotesFolder = ReplicatedStorage:WaitForChild("VillageRemotes", 15)
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
			title.Text = "TEST 1  ·  " .. tostring(s.build or "MILLBROOK V2")
			phase.Text = s.night and "NIGHT" or "DAY"
			phase.TextColor3 = s.night and Color3.fromRGB(140, 170, 255) or Color3.fromRGB(120, 220, 140)
			taskLab.Text = tostring(s.task or "")
			hintLab.Text = string.format("Task %s / %s   ·   %s", tostring(s.step or 1), tostring(s.total or 7), tostring(s.hint or ""))
			bagLab.Text = string.format(
				"Satchel\nReeds %d / 5\nClapper %s\nOil %s\nRope %s",
				s.reeds or 0,
				(s.clapper or 0) > 0 and "yes" or "—",
				(s.oil or 0) > 0 and "yes" or "—",
				(s.rope or 0) > 0 and "yes" or "—"
			)
			ending.Visible = s.won == true
		end)
	end
	if notify then
		notify.OnClientEvent:Connect(function(msg)
			toast.Text = tostring(msg or "")
			task.delay(2.6, function()
				if toast.Text == tostring(msg or "") then
					toast.Text = ""
				end
			end)
		end)
	end
end

bind()
