--!nocheck
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "VillageHud"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local top = Instance.new("TextLabel")
top.Name = "Banner"
top.Size = UDim2.new(0.5, 0, 0, 40)
top.Position = UDim2.new(0.25, 0, 0.02, 0)
top.BackgroundColor3 = Color3.fromRGB(20, 16, 12)
top.BackgroundTransparency = 0.25
top.TextColor3 = Color3.fromRGB(255, 230, 180)
top.Font = Enum.Font.GothamBold
top.TextScaled = true
top.Text = "TEST 1 · VILLAGE-20 · SANDBOX"
top.Parent = gui

local tip = Instance.new("TextLabel")
tip.Size = UDim2.new(0.4, 0, 0, 56)
tip.Position = UDim2.new(0.3, 0, 0.9, 0)
tip.BackgroundColor3 = Color3.fromRGB(20, 16, 12)
tip.BackgroundTransparency = 0.3
tip.TextColor3 = Color3.fromRGB(220, 220, 210)
tip.Font = Enum.Font.Gotham
tip.TextScaled = true
tip.Text = "Walk into the shed · F to fly · systems paused"
tip.Parent = gui

local remotes = ReplicatedStorage:WaitForChild("VillageRemotes", 10)
if remotes then
	local state = remotes:WaitForChild("State", 5)
	if state then
		state.OnClientEvent:Connect(function(data)
			if data and data.build then
				top.Text = "TEST 1 · " .. tostring(data.build) .. " · SANDBOX"
			end
			if data and data.objective then
				tip.Text = tostring(data.objective) .. " · F to fly"
			end
		end)
	end
	local notify = remotes:FindFirstChild("Notify")
	if notify then
		notify.OnClientEvent:Connect(function(msg)
			tip.Text = tostring(msg)
		end)
	end
end
