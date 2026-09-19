--!nocheck
-- VILLAGE-03 map. Never clears Terrain or wipes Workspace.
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

local function wedge(name, size, cf, color, parent, mat)
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Slate
	p.Anchored = true
	p.Parent = parent
	return p
end

local function sign(adornee, text, offset, color)
	local bill = Instance.new("BillboardGui")
	bill.Name = "Sign"
	bill.Size = UDim2.fromOffset(320, 44)
	bill.StudsOffset = offset or Vector3.new(0, 8, 0)
	bill.AlwaysOnTop = true
	bill.MaxDistance = 200
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 236, 200)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextStrokeTransparency = 0.45
	t.Parent = bill
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.2
	pr.MaxActivationDistance = dist or 14
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key or Enum.KeyCode.E
	pr.Parent = parent
	return pr
end

local function lightOn(parent, offset, color, range)
	local a = Instance.new("Attachment")
	a.Position = offset or Vector3.new(0, 2, 0)
	a.Parent = parent
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Brightness = 1.35
	l.Range = range or 16
	l.Parent = a
end

local function lantern(parent, cf)
	local pole = part("LanternPole", Vector3.new(0.5, 10, 0.5), cf, Color3.fromRGB(55, 42, 30), parent, Enum.Material.Wood)
	local lamp = part("Lantern", Vector3.new(1.4, 1.6, 1.4), cf * CFrame.new(0, 5.4, 0), Color3.fromRGB(255, 200, 110), parent, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 190, 100), 20)
	return pole
end

local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	local floor = part("Floor", Vector3.new(30, 1.2, 24), origin * CFrame.new(0, 0.6, 0), Color3.fromRGB(92, 68, 44), m, Enum.Material.WoodPlanks)
	m.PrimaryPart = floor
	part("WallB", Vector3.new(30, 13, 1), origin * CFrame.new(0, 7.1, 11.6), wall, m, Enum.Material.Brick)
	part("WallL", Vector3.new(1, 13, 24), origin * CFrame.new(-14.6, 7.1, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(1, 13, 24), origin * CFrame.new(14.6, 7.1, 0), wall, m, Enum.Material.Brick)
	part("WallF", Vector3.new(11, 13, 1), origin * CFrame.new(-9.5, 7.1, -11.6), wall, m, Enum.Material.Brick)
	part("WallF2", Vector3.new(11, 13, 1), origin * CFrame.new(9.5, 7.1, -11.6), wall, m, Enum.Material.Brick)
	part("Lintel", Vector3.new(8, 3, 1), origin * CFrame.new(0, 11.6, -11.6), wall, m, Enum.Material.Brick)
	part("Door", Vector3.new(7.5, 9.5, 0.4), origin * CFrame.new(0, 5.2, -11.6), Color3.fromRGB(40, 28, 18), m, Enum.Material.Wood)
	wedge("RoofA", Vector3.new(14, 5, 34), origin * CFrame.new(-8, 15.5, 0) * CFrame.Angles(0, 0, 0.05), roof, m, Enum.Material.Slate)
	wedge("RoofB", Vector3.new(14, 5, 34), origin * CFrame.new(8, 15.5, 0) * CFrame.Angles(0, math.pi, 0.05), roof, m, Enum.Material.Slate)
	part("Chimney", Vector3.new(2.6, 7, 2.6), origin * CFrame.new(10, 17.5, 6), Color3.fromRGB(90, 70, 60), m, Enum.Material.Brick)
	part("WindowL", Vector3.new(3.2, 3.2, 0.3), origin * CFrame.new(-8.5, 7.5, -11.9), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("WindowR", Vector3.new(3.2, 3.2, 0.3), origin * CFrame.new(8.5, 7.5, -11.9), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("Table", Vector3.new(8, 1, 4), origin * CFrame.new(-5, 2.5, 2), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("ChairA", Vector3.new(2, 2.2, 2), origin * CFrame.new(-5, 2.2, -1.6), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("ChairB", Vector3.new(2, 2.2, 2), origin * CFrame.new(-2, 2.2, 2), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("Bed", Vector3.new(6.5, 1.5, 11), origin * CFrame.new(9, 2.3, 2), Color3.fromRGB(140, 70, 70), m, Enum.Material.Fabric)
	part("Pillow", Vector3.new(3, 0.7, 2.4), origin * CFrame.new(9, 3.3, 6), Color3.fromRGB(220, 210, 190), m, Enum.Material.Fabric)
	part("Shelf", Vector3.new(9, 6.5, 1.2), origin * CFrame.new(-11, 5.5, 8), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	part("Jar1", Vector3.new(1, 1.4, 1), origin * CFrame.new(-11, 9.4, 8), Color3.fromRGB(90, 140, 110), m, Enum.Material.Glass)
	part("Jar2", Vector3.new(1, 1.2, 1), origin * CFrame.new(-9, 9.3, 8), Color3.fromRGB(140, 100, 70), m, Enum.Material.Glass)
	part("CrateA", Vector3.new(2.4, 2.4, 2.4), origin * CFrame.new(11, 2.5, -6), Color3.fromRGB(110, 80, 48), m, Enum.Material.WoodPlanks)
	part("CrateB", Vector3.new(2.2, 2.2, 2.2), origin * CFrame.new(13, 2.4, -4), Color3.fromRGB(96, 70, 40), m, Enum.Material.WoodPlanks)
	part("Rug", Vector3.new(11, 0.2, 9), origin * CFrame.new(0, 1.35, 0), Color3.fromRGB(110, 42, 42), m, Enum.Material.Fabric).CanCollide = false
	local lamp = part("Lamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 11, 0), Color3.fromRGB(255, 210, 130), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 210, 130), 15)
	part("Hearth", Vector3.new(5, 4, 2), origin * CFrame.new(10, 3.5, 10), Color3.fromRGB(70, 55, 48), m, Enum.Material.Brick)
	local fire = part("Fire", Vector3.new(2.4, 1.2, 1.2), origin * CFrame.new(10, 5.4, 10), Color3.fromRGB(255, 120, 40), m, Enum.Material.Neon)
	fire.CanCollide = false
	lightOn(fire, Vector3.new(0, 1, 0), Color3.fromRGB(255, 130, 50), 12)
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

	part("Plaza", Vector3.new(240, 2, 240), CFrame.new(0, 6, 0), Color3.fromRGB(118, 112, 104), root, Enum.Material.Cobblestone)
	part("PlazaRing", Vector3.new(70, 0.4, 70), CFrame.new(0, 7.15, 0), Color3.fromRGB(132, 126, 118), root, Enum.Material.Concrete)
	part("WellBase", Vector3.new(9, 4.5, 9), CFrame.new(0, 9.2, 0), Color3.fromRGB(90, 90, 96), root, Enum.Material.Slate)
	local well = part("Well", Vector3.new(5.5, 1, 5.5), CFrame.new(0, 11.6, 0), Color3.fromRGB(40, 70, 90), root, Enum.Material.Glass)
	part("WellPostA", Vector3.new(0.6, 9, 0.6), CFrame.new(-3.4, 14.5, 0), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	part("WellPostB", Vector3.new(0.6, 9, 0.6), CFrame.new(3.4, 14.5, 0), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	part("WellRoof", Vector3.new(10, 0.5, 10), CFrame.new(0, 19, 0), Color3.fromRGB(118, 82, 52), root, Enum.Material.Wood)
	part("WellBucket", Vector3.new(1.6, 1.8, 1.6), CFrame.new(0, 13.2, 0), Color3.fromRGB(70, 55, 40), root, Enum.Material.Wood)
	sign(well, "MILLBROOK SQUARE", Vector3.new(0, 11, 0))
	part("BenchA", Vector3.new(9, 1.5, 2.2), CFrame.new(-18, 7.7, 16), Color3.fromRGB(82, 58, 36), root, Enum.Material.Wood)
	part("BenchB", Vector3.new(9, 1.5, 2.2), CFrame.new(18, 7.7, 16), Color3.fromRGB(82, 58, 36), root, Enum.Material.Wood)
	part("FlowerBedA", Vector3.new(8, 0.8, 3), CFrame.new(-28, 7.5, 8), Color3.fromRGB(70, 110, 50), root, Enum.Material.Grass)
	part("FlowerBedB", Vector3.new(8, 0.8, 3), CFrame.new(28, 7.5, 8), Color3.fromRGB(70, 110, 50), root, Enum.Material.Grass)
	lantern(root, CFrame.new(-26, 12, -20))
	lantern(root, CFrame.new(26, 12, -20))
	lantern(root, CFrame.new(-26, 12, 28))
	lantern(root, CFrame.new(26, 12, 28))

	local board = part("NoticeBoard", Vector3.new(11, 8.5, 0.7), CFrame.new(0, 12.2, 26), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	sign(board, "GOAL  ·  cook meals · bank 80 · rebirth", Vector3.new(0, 6.5, 0), Color3.fromRGB(255, 220, 140))

	-- Chapel
	local chapel = Instance.new("Model")
	chapel.Name = "ChapelOfTheLastBell"
	chapel.Parent = root
	part("Nave", Vector3.new(22, 17, 32), CFrame.new(0, 15.5, -74), Color3.fromRGB(226, 220, 206), chapel, Enum.Material.Concrete)
	part("Tower", Vector3.new(9, 30, 9), CFrame.new(0, 29, -88), Color3.fromRGB(220, 216, 204), chapel, Enum.Material.Concrete)
	part("TowerRoof", Vector3.new(11, 1.5, 11), CFrame.new(0, 45, -88), Color3.fromRGB(62, 68, 74), chapel, Enum.Material.Slate)
	part("Spire", Vector3.new(1.7, 9, 1.7), CFrame.new(0, 50.5, -88), Color3.fromRGB(212, 176, 64), chapel, Enum.Material.Metal)
	local bell = part("LastBell", Vector3.new(4.2, 4.2, 4.2), CFrame.new(0, 41.5, -88), Color3.fromRGB(220, 180, 60), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(255, 220, 120), 24)
	part("Door", Vector3.new(6.5, 11, 1), CFrame.new(0, 12.5, -58), Color3.fromRGB(50, 32, 20), chapel, Enum.Material.Wood)
	for i = 0, 3 do
		part("Pew" .. i, Vector3.new(13, 2.1, 2.1), CFrame.new(0, 8.1, -64 - i * 4), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	end
	part("Path", Vector3.new(7, 0.4, 26), CFrame.new(0, 7.2, -48), Color3.fromRGB(128, 124, 118), chapel, Enum.Material.Cobblestone)
	local altar = part("Altar", Vector3.new(9, 2.2, 4.5), CFrame.new(0, 8.3, -86), Color3.fromRGB(180, 160, 90), chapel, Enum.Material.Marble)
	part("CandleA", Vector3.new(0.5, 1.4, 0.5), CFrame.new(-2, 10, -86), Color3.fromRGB(255, 230, 160), chapel, Enum.Material.Neon)
	part("CandleB", Vector3.new(0.5, 1.4, 0.5), CFrame.new(2, 10, -86), Color3.fromRGB(255, 230, 160), chapel, Enum.Material.Neon)
	sign(altar, "CHAPEL  ·  P rebirth at 80 coins", Vector3.new(0, 8, 0), Color3.fromRGB(255, 230, 160))
	prompt(altar, "RebirthPrompt", "Last Bell", "Rebirth", Enum.KeyCode.P, 16)

	-- Willow (herbs)
	local willow = house(root, "WillowHome", CFrame.new(-78, 7, 10), Color3.fromRGB(118, 128, 96), Color3.fromRGB(70, 92, 58))
	for i = 0, 2 do
		part("HerbBox" .. i, Vector3.new(4.2, 1.3, 6.5), CFrame.new(-78 + i * 7 - 7, 8.3, -10), Color3.fromRGB(70 + i * 8, 110, 50), willow, Enum.Material.Grass)
	end
	part("DryingRail", Vector3.new(12, 0.4, 0.4), CFrame.new(-78, 12.5, -4), Color3.fromRGB(160, 140, 90), willow, Enum.Material.Wood)
	part("HerbBundleA", Vector3.new(0.8, 2.4, 0.8), CFrame.new(-82, 11.2, -4), Color3.fromRGB(90, 150, 70), willow, Enum.Material.Grass)
	part("HerbBundleB", Vector3.new(0.8, 2.4, 0.8), CFrame.new(-74, 11.2, -4), Color3.fromRGB(90, 150, 70), willow, Enum.Material.Grass)
	local herbs = part("Herbs", Vector3.new(6, 1.5, 6), CFrame.new(-78, 8.7, -10), Color3.fromRGB(90, 160, 70), willow, Enum.Material.Grass)
	sign(herbs, "WILLOW HOME  ·  E gather herbs", Vector3.new(0, 7, 0), Color3.fromRGB(180, 255, 170))
	prompt(herbs, "HerbPrompt", "Herb garden", "Gather herbs", Enum.KeyCode.E, 14)

	-- Ash (wood)
	local ash = house(root, "AshCottage", CFrame.new(78, 7, 10), Color3.fromRGB(128, 96, 70), Color3.fromRGB(96, 58, 36))
	part("Woodpile", Vector3.new(7, 3.4, 4.5), CFrame.new(78, 9.3, -10), Color3.fromRGB(86, 58, 34), ash, Enum.Material.Wood)
	part("LogA", Vector3.new(5, 1.2, 1.2), CFrame.new(74, 8.2, -8), Color3.fromRGB(96, 66, 40), ash, Enum.Material.Wood)
	part("LogB", Vector3.new(5, 1.2, 1.2), CFrame.new(82, 8.2, -8), Color3.fromRGB(96, 66, 40), ash, Enum.Material.Wood)
	part("Barrel", Vector3.new(3.2, 4.2, 3.2), CFrame.new(70, 9.4, -8), Color3.fromRGB(92, 62, 32), ash, Enum.Material.Wood)
	part("AxeBlock", Vector3.new(2.5, 1.5, 2.5), CFrame.new(84, 8.3, -6), Color3.fromRGB(70, 50, 35), ash, Enum.Material.Wood)
	local wood = part("WoodStation", Vector3.new(5, 2.2, 4), CFrame.new(78, 8.6, -10), Color3.fromRGB(110, 78, 48), ash, Enum.Material.WoodPlanks)
	sign(wood, "ASH COTTAGE  ·  E chop wood", Vector3.new(0, 7, 0), Color3.fromRGB(255, 210, 150))
	prompt(wood, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 14)

	-- Inn (cook)
	local inn = house(root, "LastBellInn", CFrame.new(0, 7, 82), Color3.fromRGB(140, 92, 64), Color3.fromRGB(150, 50, 40))
	part("InnSign", Vector3.new(12, 4.5, 0.6), CFrame.new(0, 17, 66), Color3.fromRGB(160, 40, 40), inn, Enum.Material.Wood)
	part("Porch", Vector3.new(18, 1, 9), CFrame.new(0, 7.7, 66), Color3.fromRGB(100, 74, 48), inn, Enum.Material.WoodPlanks)
	local porchLight = part("PorchLight", Vector3.new(1.5, 1.5, 1.5), CFrame.new(0, 13.5, 66), Color3.fromRGB(255, 200, 110), inn, Enum.Material.Neon)
	porchLight.CanCollide = false
	lightOn(porchLight, Vector3.new(), Color3.fromRGB(255, 180, 90), 18)
	part("Bar", Vector3.new(16, 2.4, 3.2), CFrame.new(0, 9.1, 88), Color3.fromRGB(90, 60, 36), inn, Enum.Material.Wood)
	for i = -2, 2 do
		part("Stool" .. i, Vector3.new(2, 2.1, 2), CFrame.new(i * 3, 8.7, 84), Color3.fromRGB(70, 48, 28), inn, Enum.Material.Wood)
	end
	part("KitchenShelf", Vector3.new(8, 5, 1.2), CFrame.new(10, 11, 92), Color3.fromRGB(80, 55, 35), inn, Enum.Material.Wood)
	local kitchen = part("Kitchen", Vector3.new(7, 2.2, 7), CFrame.new(8, 8.9, 90), Color3.fromRGB(180, 120, 70), inn, Enum.Material.Wood)
	part("Pot", Vector3.new(2.2, 2, 2.2), CFrame.new(8, 10.5, 90), Color3.fromRGB(50, 50, 55), inn, Enum.Material.Metal)
	local stew = part("Stew", Vector3.new(1.6, 0.4, 1.6), CFrame.new(8, 11.4, 90), Color3.fromRGB(180, 90, 40), inn, Enum.Material.Neon)
	stew.CanCollide = false
	sign(kitchen, "LAST BELL INN  ·  F cook meal", Vector3.new(0, 7, 0), Color3.fromRGB(255, 200, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 14)

	-- Reed house (flavor + bonus herbs)
	local reedHome = house(root, "ReedHouse", CFrame.new(-78, 7, -52), Color3.fromRGB(176, 156, 110), Color3.fromRGB(150, 122, 58))
	part("Dock", Vector3.new(12, 0.7, 14), CFrame.new(-78, 7.5, -72), Color3.fromRGB(118, 82, 52), reedHome, Enum.Material.WoodPlanks)
	for i = 0, 4 do
		part("ReedRack" .. i, Vector3.new(0.4, 4.2, 0.4), CFrame.new(-64 + i * 2.2, 9.4, -62), Color3.fromRGB(70, 48, 28), reedHome, Enum.Material.Wood)
		part("ReedBundle" .. i, Vector3.new(0.7, 3.4, 0.7), CFrame.new(-64 + i * 2.2, 9.6, -61.4), Color3.fromRGB(74, 118, 52), reedHome, Enum.Material.Grass)
	end
	local reedBonus = part("ReedHerbs", Vector3.new(5, 1.4, 5), CFrame.new(-70, 8.6, -66), Color3.fromRGB(74, 118, 52), reedHome, Enum.Material.Grass)
	sign(reedBonus, "REED DOCK  ·  E extra herbs", Vector3.new(0, 7, 0), Color3.fromRGB(200, 230, 180))
	prompt(reedBonus, "HerbPrompt", "River herbs", "Gather herbs", Enum.KeyCode.E, 12)

	-- Smithy (flavor + bonus wood)
	local smithy = house(root, "MillbrookSmithy", CFrame.new(78, 7, -52), Color3.fromRGB(92, 78, 68), Color3.fromRGB(70, 70, 72))
	part("LeanRoof", Vector3.new(18, 0.7, 13), CFrame.new(78, 14.5, -68), Color3.fromRGB(70, 70, 72), smithy, Enum.Material.Metal)
	part("Forge", Vector3.new(6.5, 3.2, 4.5), CFrame.new(72, 9.2, -66), Color3.fromRGB(50, 50, 52), smithy, Enum.Material.Basalt)
	local coals = part("Coals", Vector3.new(4.2, 0.7, 2.6), CFrame.new(72, 11.1, -66), Color3.fromRGB(255, 90, 30), smithy, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(255, 120, 40), 20)
	part("Anvil", Vector3.new(3.2, 1.5, 1.8), CFrame.new(84, 8.5, -66), Color3.fromRGB(40, 40, 44), smithy, Enum.Material.Metal)
	part("WeaponRack", Vector3.new(7, 5.5, 0.5), CFrame.new(88, 10.5, -56), Color3.fromRGB(70, 48, 28), smithy, Enum.Material.Wood)
	local scrap = part("ScrapWood", Vector3.new(5, 2, 4), CFrame.new(84, 8.6, -62), Color3.fromRGB(90, 70, 50), smithy, Enum.Material.WoodPlanks)
	sign(scrap, "SMITHY YARD  ·  E scrap wood", Vector3.new(0, 7, 0), Color3.fromRGB(255, 170, 90))
	prompt(scrap, "WoodPrompt", "Scrap wood", "Chop wood", Enum.KeyCode.E, 14)

	-- Player stalls
	local stalls = Instance.new("Folder")
	stalls.Name = "Stalls"
	stalls.Parent = root
	local stallSpots = {
		CFrame.new(-42, 7, 42),
		CFrame.new(-18, 7, 48),
		CFrame.new(18, 7, 48),
		CFrame.new(42, 7, 42),
	}
	for i, cf in ipairs(stallSpots) do
		local m = Instance.new("Model")
		m.Name = "Stall" .. i
		m.Parent = stalls
		local base = part("Counter", Vector3.new(12, 1.4, 6), cf * CFrame.new(0, 1.2, 0), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
		m.PrimaryPart = base
		part("Roof", Vector3.new(14, 0.6, 8), cf * CFrame.new(0, 8, 0), Color3.fromRGB(150, 50, 40), m, Enum.Material.Fabric)
		part("PostL", Vector3.new(0.6, 8, 0.6), cf * CFrame.new(-5.5, 4.5, -2.5), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
		part("PostR", Vector3.new(0.6, 8, 0.6), cf * CFrame.new(5.5, 4.5, -2.5), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
		part("Crate", Vector3.new(2.5, 2.5, 2.5), cf * CFrame.new(-3, 2.8, 1), Color3.fromRGB(110, 80, 48), m, Enum.Material.WoodPlanks)
		part("Basket", Vector3.new(2.2, 1.4, 2.2), cf * CFrame.new(3, 2.4, 1), Color3.fromRGB(160, 120, 70), m, Enum.Material.Wood)
		local bank = part("BankPad", Vector3.new(4, 1, 4), cf * CFrame.new(0, 2.1, 0), Color3.fromRGB(180, 150, 70), m, Enum.Material.Metal)
		sign(bank, "STALL " .. i .. "  ·  Q bank / R steal", Vector3.new(0, 6, 0), Color3.fromRGB(255, 220, 140))
		prompt(bank, "BankPrompt", "Your stall", "Bank meal", Enum.KeyCode.Q, 12)
		prompt(bank, "StealPrompt", "Rival stall", "Steal meal", Enum.KeyCode.R, 12)
		local owner = Instance.new("IntValue")
		owner.Name = "OwnerUserId"
		owner.Value = 0
		owner.Parent = m
		local stock = Instance.new("IntValue")
		stock.Name = "Stock"
		stock.Value = 0
		stock.Parent = m
	end

	print("[Village] VILLAGE-03 Millbrook economy map ready")
	return root
end

return World
