--!nocheck
local Players = game:GetService("Players")
local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("VillageHud")
if old then
	old:Destroy()
end
local gui = Instance.new("ScreenGui")
gui.Name = "VillageHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = pg
local lab = Instance.new("TextLabel")
lab.Size = UDim2.fromOffset(320, 42)
lab.Position = UDim2.new(0.5, -160, 0, 16)
lab.BackgroundColor3 = Color3.fromRGB(22, 18, 14)
lab.BackgroundTransparency = 0.15
lab.TextColor3 = Color3.fromRGB(240, 220, 180)
lab.Font = Enum.Font.GothamBold
lab.TextSize = 16
lab.Text = "TEST 1  ·  MILLBROOK V2"
lab.Parent = gui
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 10)
c.Parent = lab
