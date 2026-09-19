--!nocheck
-- Builds furnished village pieces. Never clears Terrain or wipes Workspace.
local World = {}

local function part(name, size, cf, color, parent, mat, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Wood
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function sign(adornee, text, offset, color)
	local bill = Instance.new("BillboardGui")
	bill.Name = "Sign"
	bill.Size = UDim2.fromOffset(280, 42)
	bill.StudsOffset = offset or Vector3.new(0, 8, 0)
	bill.AlwaysOnTop = true
	bill.MaxDistance = 180
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 236, 200)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = bill
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.15
	pr.MaxActivationDistance = dist or 12
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key
	pr.Parent = parent
	return pr
end

local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	local floor = part("Floor", Vector3.new(28, 1.2, 22), origin * CFrame.new(0, 0.6, 0), Color3.fromRGB(92, 68, 44), m, Enum.Material.Wood)
	m.PrimaryPart = floor
	part("WallB", Vector3.new(28, 12, 1), origin * CFrame.new(0, 6.6, 10.6), wall, m, Enum.Material.Brick)
	part("WallL", Vector3.new(1, 12, 22), origin * CFrame.new(-13.6, 6.6, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(1, 12, 22), origin * CFrame.new(13.6, 6.6, 0), wall, m, Enum.Material.Brick)
	part("WallF", Vector3.new(10, 12, 1), origin * CFrame.new(-9, 6.6, -10.6), wall, m, Enum.Material.Brick)
	part("WallF2", Vector3.new(10, 12, 1), origin * CFrame.new(9, 6.6, -10.6), wall, m, Enum.Material.Brick)
	part("DoorGap", Vector3.new(8, 9, 0.4), origin * CFrame.new(0, 4.6, -10.6), Color3.fromRGB(40, 28, 18), m, Enum.Material.Wood).CanCollide = false
	part("Roof", Vector3.new(32, 1.2, 26), origin * CFrame.new(0, 13.2, 0) * CFrame.Angles(0.12, 0, 0), roof, m, Enum.Material.Slate)
	part("Table", Vector3.new(8, 1, 4), origin * CFrame.new(-4, 2.4, 2), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("Chair", Vector3.new(2, 2.2, 2), origin * CFrame.new(-4, 2.1, -1.4), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("Bed", Vector3.new(6, 1.4, 10), origin * CFrame.new(8, 2.2, 2), Color3.fromRGB(140, 70, 70), m, Enum.Material.Fabric)
	part("Shelf", Vector3.new(8, 6, 1.2), origin * CFrame.new(-10, 5, 8), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	part("Rug", Vector3.new(10, 0.2, 8), origin * CFrame.new(0, 1.3, 0), Color3.fromRGB(110, 42, 42), m, Enum.Material.Fabric).CanCollide = false
	part("Lamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 10.4, 0), Color3.fromRGB(255, 210, 130), m, Enum.Material.Neon).CanCollide = false
	return m
end

function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "VillageBuild"
	root.Parent = workspace

	part("Plaza", Vector3.new(220, 2, 220), CFrame.new(0, 6, 0), Color3.fromRGB(118, 112, 104), root, Enum.Material.Cobblestone)
	part("WellBase", Vector3.new(8, 4, 8), CFrame.new(0, 9, 0), Color3.fromRGB(90, 90, 96), root, Enum.Material.Slate)
	local well = part("Well", Vector3.new(5, 1, 5), CFrame.new(0, 11.4, 0), Color3.fromRGB(40, 70, 90), root, Enum.Material.Glass)
	sign(well, "SQUARE  ·  well + notice board", Vector3.new(0, 8, 0))
	part("BenchA", Vector3.new(8, 1.4, 2), CFrame.new(-16, 7.6, 14), Color3.fromRGB(82, 58, 36), root, Enum.Material.Wood)
	part("BenchB", Vector3.new(8, 1.4, 2), CFrame.new(16, 7.6, 14), Color3.fromRGB(82, 58, 36), root, Enum.Material.Wood)
	local board = part("NoticeBoard", Vector3.new(10, 8, 0.6), CFrame.new(0, 12, 22), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	sign(board, "NOTICE  ·  E read task", Vector3.new(0, 6, 0), Color3.fromRGB(255, 220, 140))
	prompt(board, "NoticePrompt", "Village board", "Read task", Enum.KeyCode.E, 16)

	local chapel = Instance.new("Model")
	chapel.Name = "Chapel"
	chapel.Parent = root
	part("Nave", Vector3.new(20, 16, 28), CFrame.new(0, 15, -70), Color3.fromRGB(210, 210, 200), chapel, Enum.Material.Concrete)
	part("Tower", Vector3.new(8, 28, 8), CFrame.new(0, 28, -82), Color3.fromRGB(200, 200, 190), chapel, Enum.Material.Concrete)
	part("Bell", Vector3.new(4, 4, 4), CFrame.new(0, 43, -82), Color3.fromRGB(220, 180, 60), chapel, Enum.Material.Neon)
	part("Door", Vector3.new(6, 10, 1), CFrame.new(0, 12, -56), Color3.fromRGB(50, 32, 20), chapel, Enum.Material.Wood)
	part("Pew1", Vector3.new(12, 2, 2), CFrame.new(0, 8, -64), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	part("Pew2", Vector3.new(12, 2, 2), CFrame.new(0, 8, -68), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	local altar = part("Altar", Vector3.new(8, 2, 4), CFrame.new(0, 8.2, -80), Color3.fromRGB(180, 160, 90), chapel, Enum.Material.Marble)
	sign(altar, "CHAPEL  ·  P rebirth at 80 coins", Vector3.new(0, 8, 0), Color3.fromRGB(255, 230, 160))
	prompt(altar, "RebirthPrompt", "Chapel altar", "Rebirth", Enum.KeyCode.P, 14)

	local willow = house(root, "WillowHome", CFrame.new(-72, 7, 8), Color3.fromRGB(118, 128, 96), Color3.fromRGB(70, 92, 58))
	part("HerbBox1", Vector3.new(4, 1.2, 6), CFrame.new(-72, 8.2, -8), Color3.fromRGB(70, 110, 50), willow, Enum.Material.Grass)
	part("HerbBox2", Vector3.new(4, 1.2, 6), CFrame.new(-66, 8.2, -8), Color3.fromRGB(62, 102, 44), willow, Enum.Material.Grass)
	part("DryingRail", Vector3.new(10, 0.4, 0.4), CFrame.new(-72, 12, -4), Color3.fromRGB(160, 140, 90), willow, Enum.Material.Wood)
	local herbs = part("Herbs", Vector3.new(5, 1.4, 5), CFrame.new(-72, 8.6, -8), Color3.fromRGB(90, 160, 70), willow, Enum.Material.Grass)
	sign(herbs, "WILLOW  ·  E pick herbs", Vector3.new(0, 7, 0), Color3.fromRGB(180, 255, 170))
	prompt(herbs, "HerbPrompt", "Herb boxes", "Pick herbs", Enum.KeyCode.E, 14)

	local ash = house(root, "AshCottage", CFrame.new(72, 7, 8), Color3.fromRGB(128, 96, 70), Color3.fromRGB(96, 58, 36))
	part("Woodpile", Vector3.new(6, 3, 4), CFrame.new(72, 9, -8), Color3.fromRGB(86, 58, 34), ash, Enum.Material.Wood)
	part("Barrel", Vector3.new(3, 4, 3), CFrame.new(66, 9.2, -7), Color3.fromRGB(92, 62, 32), ash, Enum.Material.Wood)
	part("Chest", Vector3.new(4, 2.4, 3), CFrame.new(78, 8.8, 8), Color3.fromRGB(150, 110, 50), ash, Enum.Material.Wood)
	local wood = part("WoodBlock", Vector3.new(5, 2, 5), CFrame.new(72, 8.8, -8), Color3.fromRGB(110, 78, 44), ash, Enum.Material.Wood)
	sign(wood, "ASH  ·  E chop wood", Vector3.new(0, 7, 0), Color3.fromRGB(255, 210, 150))
	prompt(wood, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 14)

	local inn = house(root, "Inn", CFrame.new(0, 7, 72), Color3.fromRGB(140, 92, 64), Color3.fromRGB(150, 50, 40))
	part("InnSign", Vector3.new(10, 4, 0.5), CFrame.new(0, 16, 58), Color3.fromRGB(160, 40, 40), inn, Enum.Material.Wood)
	part("Porch", Vector3.new(16, 1, 8), CFrame.new(0, 7.6, 58), Color3.fromRGB(100, 74, 48), inn, Enum.Material.Wood)
	part("PorchLight", Vector3.new(1.4, 1.4, 1.4), CFrame.new(0, 13, 58), Color3.fromRGB(255, 200, 110), inn, Enum.Material.Neon).CanCollide = false
	part("Bar", Vector3.new(14, 2.2, 3), CFrame.new(0, 9, 76), Color3.fromRGB(90, 60, 36), inn, Enum.Material.Wood)
	part("Stool1", Vector3.new(2, 2, 2), CFrame.new(-4, 8.6, 72), Color3.fromRGB(70, 48, 28), inn, Enum.Material.Wood)
	part("Stool2", Vector3.new(2, 2, 2), CFrame.new(4, 8.6, 72), Color3.fromRGB(70, 48, 28), inn, Enum.Material.Wood)
	local kitchen = part("Kitchen", Vector3.new(6, 2, 6), CFrame.new(8, 8.8, 78), Color3.fromRGB(180, 120, 70), inn, Enum.Material.Wood)
	sign(kitchen, "INN  ·  F cook / sell meal", Vector3.new(0, 7, 0), Color3.fromRGB(255, 200, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 14)

	local stalls = Instance.new("Folder")
	stalls.Name = "PlayerStalls"
	stalls.Parent = root
	local names = { "North Stall", "East Stall", "South Stall", "West Stall" }
	local spots = {
		CFrame.new(0, 7, -36),
		CFrame.new(36, 7, 0),
		CFrame.new(0, 7, 36),
		CFrame.new(-36, 7, 0),
	end
	for i, cf in ipairs(spots) do
		local m = Instance.new("Model")
		m.Name = "Stall_" .. i
		m.Parent = stalls
		local fl = part("Floor", Vector3.new(14, 1, 14), cf, Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
		m.PrimaryPart = fl
		part("Awning", Vector3.new(16, 0.5, 16), cf * CFrame.new(0, 8, 0), Color3.fromRGB(160, 60, 50), m, Enum.Material.Fabric)
		part("Counter", Vector3.new(10, 2, 2), cf * CFrame.new(0, 1.6, -5), Color3.fromRGB(120, 86, 50), m, Enum.Material.Wood)
		local chest = part("StallChest", Vector3.new(4, 2.2, 3), cf * CFrame.new(0, 2, 3), Color3.fromRGB(190, 150, 60), m, Enum.Material.Wood)
		chest:SetAttribute("StallId", i)
		sign(fl, names[i] .. "  ·  Q bank  ·  R steal night", Vector3.new(0, 7, 0))
		prompt(chest, "BankPrompt", names[i], "Bank satchel", Enum.KeyCode.Q, 12)
		prompt(chest, "StealPrompt", names[i], "Steal", Enum.KeyCode.R, 12)
	end

	print("[Village] furnished buildings ready")
	return root
end

return World
