--!nocheck
-- VILLAGE-04: full village layout, no empty center plaza, per-player bases.
-- Never clears Terrain or wipes Workspace.
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
	bill.Size = UDim2.fromOffset(340, 46)
	bill.StudsOffset = offset or Vector3.new(0, 7, 0)
	bill.AlwaysOnTop = true
	bill.MaxDistance = 220
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 236, 200)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextStrokeTransparency = 0.4
	t.Parent = bill
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.15
	pr.MaxActivationDistance = dist or 14
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key or Enum.KeyCode.E
	pr.Parent = parent
	return pr
end

local function lightOn(parent, offset, color, range)
	local a = Instance.new("Attachment")
	a.Position = offset or Vector3.new(0, 1.5, 0)
	a.Parent = parent
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Brightness = 1.35
	l.Range = range or 16
	l.Parent = a
end

local function lantern(parent, cf)
	part("Pole", Vector3.new(0.45, 10, 0.45), cf, Color3.fromRGB(55, 42, 30), parent, Enum.Material.Wood)
	local lamp = part("Lamp", Vector3.new(1.4, 1.5, 1.4), cf * CFrame.new(0, 5.4, 0), Color3.fromRGB(255, 200, 110), parent, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 190, 100), 20)
end

local function road(parent, size, cf)
	return part("Road", size, cf, Color3.fromRGB(105, 100, 92), parent, Enum.Material.Cobblestone)
end

local function houseShell(parent, name, origin, wall, roof)
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
	wedge("RoofA", Vector3.new(14, 5, 32), origin * CFrame.new(-8, 15.2, 0) * CFrame.Angles(0, 0, 0.05), roof, m, Enum.Material.Slate)
	wedge("RoofB", Vector3.new(14, 5, 32), origin * CFrame.new(8, 15.2, 0) * CFrame.Angles(0, math.pi, 0.05), roof, m, Enum.Material.Slate)
	part("Chimney", Vector3.new(2.6, 7, 2.6), origin * CFrame.new(10, 17, 6), Color3.fromRGB(90, 70, 60), m, Enum.Material.Brick)
	part("WindowL", Vector3.new(3.2, 3.2, 0.3), origin * CFrame.new(-8.5, 7.5, -11.9), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("WindowR", Vector3.new(3.2, 3.2, 0.3), origin * CFrame.new(8.5, 7.5, -11.9), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("Rug", Vector3.new(10, 0.2, 8), origin * CFrame.new(0, 1.3, 0), Color3.fromRGB(110, 42, 42), m, Enum.Material.Fabric).CanCollide = false
	local lamp = part("Lamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 11.5, 0), Color3.fromRGB(255, 210, 130), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 210, 130), 14)
	return m, origin
end

local function furnishRoom(m, origin)
	part("Table", Vector3.new(7, 1, 3.5), origin * CFrame.new(-5, 2.4, 2), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("ChairA", Vector3.new(2, 2.1, 2), origin * CFrame.new(-5, 2.2, -1.2), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("ChairB", Vector3.new(2, 2.1, 2), origin * CFrame.new(-2.5, 2.2, 2), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("Bed", Vector3.new(6, 1.4, 10), origin * CFrame.new(9, 2.2, 2), Color3.fromRGB(140, 70, 70), m, Enum.Material.Fabric)
	part("Pillow", Vector3.new(2.8, 0.6, 2.2), origin * CFrame.new(9, 3.1, 5.5), Color3.fromRGB(220, 210, 190), m, Enum.Material.Fabric)
	part("Shelf", Vector3.new(8, 5.5, 1.1), origin * CFrame.new(-11, 5, 8), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	part("Crate", Vector3.new(2.3, 2.3, 2.3), origin * CFrame.new(11, 2.4, -6), Color3.fromRGB(110, 80, 48), m, Enum.Material.WoodPlanks)
	part("Hearth", Vector3.new(4.5, 3.5, 2), origin * CFrame.new(10, 3.2, 10), Color3.fromRGB(70, 55, 48), m, Enum.Material.Brick)
	local fire = part("Fire", Vector3.new(2.2, 1.1, 1.1), origin * CFrame.new(10, 5, 10), Color3.fromRGB(255, 120, 40), m, Enum.Material.Neon)
	fire.CanCollide = false
	lightOn(fire, Vector3.new(0, 1, 0), Color3.fromRGB(255, 130, 50), 12)
end

local function buildPlayerBase(parent, index, origin)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	local pad = part("Yard", Vector3.new(36, 1, 32), origin * CFrame.new(0, 0.5, 0), Color3.fromRGB(88, 110, 62), m, Enum.Material.Grass)
	m.PrimaryPart = pad
	part("Path", Vector3.new(6, 0.35, 14), origin * CFrame.new(0, 1.05, -12), Color3.fromRGB(120, 110, 95), m, Enum.Material.Cobblestone)
	part("FenceL", Vector3.new(0.5, 3, 30), origin * CFrame.new(-17.5, 2.5, 0), Color3.fromRGB(90, 70, 45), m, Enum.Material.Wood)
	part("FenceR", Vector3.new(0.5, 3, 30), origin * CFrame.new(17.5, 2.5, 0), Color3.fromRGB(90, 70, 45), m, Enum.Material.Wood)
	part("FenceB", Vector3.new(36, 3, 0.5), origin * CFrame.new(0, 2.5, 15.5), Color3.fromRGB(90, 70, 45), m, Enum.Material.Wood)
	part("GateL", Vector3.new(4, 3.2, 0.4), origin * CFrame.new(-4, 2.6, -15.5), Color3.fromRGB(70, 50, 30), m, Enum.Material.Wood)
	part("GateR", Vector3.new(4, 3.2, 0.4), origin * CFrame.new(4, 2.6, -15.5), Color3.fromRGB(70, 50, 30), m, Enum.Material.Wood)

	local houseOrigin = origin * CFrame.new(0, 1, 4)
	part("HouseFloor", Vector3.new(22, 1.1, 18), houseOrigin * CFrame.new(0, 0.55, 0), Color3.fromRGB(100, 78, 52), m, Enum.Material.WoodPlanks)
	part("HouseWallB", Vector3.new(22, 11, 1), houseOrigin * CFrame.new(0, 6, 8.6), Color3.fromRGB(150, 120, 90), m, Enum.Material.Brick)
	part("HouseWallL", Vector3.new(1, 11, 18), houseOrigin * CFrame.new(-10.6, 6, 0), Color3.fromRGB(150, 120, 90), m, Enum.Material.Brick)
	part("HouseWallR", Vector3.new(1, 11, 18), houseOrigin * CFrame.new(10.6, 6, 0), Color3.fromRGB(150, 120, 90), m, Enum.Material.Brick)
	part("HouseWallF", Vector3.new(7, 11, 1), houseOrigin * CFrame.new(-7.5, 6, -8.6), Color3.fromRGB(150, 120, 90), m, Enum.Material.Brick)
	part("HouseWallF2", Vector3.new(7, 11, 1), houseOrigin * CFrame.new(7.5, 6, -8.6), Color3.fromRGB(150, 120, 90), m, Enum.Material.Brick)
	part("HouseDoor", Vector3.new(6.5, 8.5, 0.4), houseOrigin * CFrame.new(0, 4.7, -8.6), Color3.fromRGB(55, 35, 22), m, Enum.Material.Wood)
	wedge("HouseRoofA", Vector3.new(11, 4, 22), houseOrigin * CFrame.new(-6, 13, 0) * CFrame.Angles(0, 0, 0.08), Color3.fromRGB(110, 55, 40), m, Enum.Material.Slate)
	wedge("HouseRoofB", Vector3.new(11, 4, 22), houseOrigin * CFrame.new(6, 13, 0) * CFrame.Angles(0, math.pi, 0.08), Color3.fromRGB(110, 55, 40), m, Enum.Material.Slate)
	part("HouseBed", Vector3.new(5.5, 1.3, 9), houseOrigin * CFrame.new(6, 2, 2), Color3.fromRGB(90, 110, 150), m, Enum.Material.Fabric)
	part("HouseTable", Vector3.new(6, 1, 3), houseOrigin * CFrame.new(-5, 2.2, 1), Color3.fromRGB(110, 80, 50), m, Enum.Material.Wood)
	part("HouseChest", Vector3.new(3.2, 2.2, 2.4), houseOrigin * CFrame.new(-6, 2.3, 5), Color3.fromRGB(140, 100, 50), m, Enum.Material.Wood)
	part("HouseWindowL", Vector3.new(2.8, 2.8, 0.25), houseOrigin * CFrame.new(-7, 6.5, -8.85), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("HouseWindowR", Vector3.new(2.8, 2.8, 0.25), houseOrigin * CFrame.new(7, 6.5, -8.85), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	local houseLamp = part("HouseLamp", Vector3.new(1, 1, 1), houseOrigin * CFrame.new(0, 9.5, 0), Color3.fromRGB(255, 210, 130), m, Enum.Material.Neon)
	houseLamp.CanCollide = false
	lightOn(houseLamp, Vector3.new(), Color3.fromRGB(255, 210, 130), 12)

	-- personal bank / stall pad in front yard
	part("Awning", Vector3.new(10, 0.4, 6), origin * CFrame.new(0, 7, -10), Color3.fromRGB(160, 50, 40), m, Enum.Material.Fabric)
	part("AwningPoleL", Vector3.new(0.45, 7, 0.45), origin * CFrame.new(-4.2, 4, -12), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("AwningPoleR", Vector3.new(0.45, 7, 0.45), origin * CFrame.new(4.2, 4, -12), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("Counter", Vector3.new(9, 1.3, 3.5), origin * CFrame.new(0, 1.8, -10), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	local bank = part("BankPad", Vector3.new(4, 1, 3.5), origin * CFrame.new(0, 2.6, -10), Color3.fromRGB(180, 150, 70), m, Enum.Material.Metal)
	sign(bank, "BASE " .. index .. " · Q bank / R steal", Vector3.new(0, 5.5, 0), Color3.fromRGB(255, 220, 140))
	prompt(bank, "BankPrompt", "Your base stall", "Bank meal", Enum.KeyCode.Q, 12)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 12)

	local spawn = part("SpawnPad", Vector3.new(5, 0.4, 5), origin * CFrame.new(0, 1.2, -18), Color3.fromRGB(70, 130, 90), m, Enum.Material.Grass)
	sign(spawn, "YOUR BASE", Vector3.new(0, 4, 0), Color3.fromRGB(180, 255, 180))

	local owner = Instance.new("IntValue")
	owner.Name = "OwnerUserId"
	owner.Value = 0
	owner.Parent = m
	local stock = Instance.new("IntValue")
	stock.Name = "Stock"
	stock.Value = 0
	stock.Parent = m
	local ownerName = Instance.new("StringValue")
	ownerName.Name = "OwnerName"
	ownerName.Value = "Open"
	ownerName.Parent = m

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

	-- NO giant empty center plaza. Crossroads only + market strip.
	road(root, Vector3.new(18, 0.5, 160), CFrame.new(0, 7.15, 0))
	road(root, Vector3.new(160, 0.5, 18), CFrame.new(0, 7.15, 0))
	road(root, Vector3.new(14, 0.5, 90), CFrame.new(0, 7.15, -70))
	road(root, Vector3.new(90, 0.5, 14), CFrame.new(-70, 7.15, 0))
	road(root, Vector3.new(90, 0.5, 14), CFrame.new(70, 7.15, 0))
	road(root, Vector3.new(14, 0.5, 70), CFrame.new(0, 7.15, 70))

	-- Small market node (not a void plaza)
	part("MarketPad", Vector3.new(28, 0.55, 28), CFrame.new(0, 7.2, 0), Color3.fromRGB(118, 108, 95), root, Enum.Material.Concrete)
	part("MarketCrateA", Vector3.new(3, 3, 3), CFrame.new(-8, 8.7, 6), Color3.fromRGB(110, 80, 48), root, Enum.Material.WoodPlanks)
	part("MarketCrateB", Vector3.new(2.6, 2.6, 2.6), CFrame.new(-5, 8.5, 8), Color3.fromRGB(96, 70, 40), root, Enum.Material.WoodPlanks)
	part("MarketBarrel", Vector3.new(3, 3.8, 3), CFrame.new(7, 9, 6), Color3.fromRGB(92, 62, 32), root, Enum.Material.Wood)
	local board = part("NoticeBoard", Vector3.new(10, 8, 0.6), CFrame.new(0, 11.5, 10), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	sign(board, "GOAL · cook · bank 80 · rebirth at chapel", Vector3.new(0, 6, 0), Color3.fromRGB(255, 220, 140))
	lantern(root, CFrame.new(-12, 12, -12))
	lantern(root, CFrame.new(12, 12, -12))
	lantern(root, CFrame.new(-12, 12, 12))
	lantern(root, CFrame.new(12, 12, 12))

	-- CHAPEL (north)
	local chapel = Instance.new("Model")
	chapel.Name = "ChapelOfTheLastBell"
	chapel.Parent = root
	part("Nave", Vector3.new(22, 17, 34), CFrame.new(0, 15.5, -95), Color3.fromRGB(226, 220, 206), chapel, Enum.Material.Concrete)
	part("Tower", Vector3.new(9, 32, 9), CFrame.new(0, 30, -110), Color3.fromRGB(220, 216, 204), chapel, Enum.Material.Concrete)
	part("TowerRoof", Vector3.new(11, 1.5, 11), CFrame.new(0, 47, -110), Color3.fromRGB(62, 68, 74), chapel, Enum.Material.Slate)
	part("Spire", Vector3.new(1.7, 9, 1.7), CFrame.new(0, 52.5, -110), Color3.fromRGB(212, 176, 64), chapel, Enum.Material.Metal)
	local bell = part("LastBell", Vector3.new(4.2, 4.2, 4.2), CFrame.new(0, 43, -110), Color3.fromRGB(220, 180, 60), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(255, 220, 120), 24)
	part("Door", Vector3.new(6.5, 11, 1), CFrame.new(0, 12.5, -78), Color3.fromRGB(50, 32, 20), chapel, Enum.Material.Wood)
	for i = 0, 3 do
		part("Pew" .. i, Vector3.new(12, 2.1, 2.1), CFrame.new(0, 8.1, -86 - i * 4), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	end
	part("Carpet", Vector3.new(3.5, 0.15, 26), CFrame.new(0, 7.4, -92), Color3.fromRGB(120, 30, 30), chapel, Enum.Material.Fabric).CanCollide = false
	local altar = part("Altar", Vector3.new(9, 2.2, 4.5), CFrame.new(0, 8.3, -108), Color3.fromRGB(180, 160, 90), chapel, Enum.Material.Marble)
	part("CandleA", Vector3.new(0.5, 1.4, 0.5), CFrame.new(-2, 10, -108), Color3.fromRGB(255, 230, 160), chapel, Enum.Material.Neon)
	part("CandleB", Vector3.new(0.5, 1.4, 0.5), CFrame.new(2, 10, -108), Color3.fromRGB(255, 230, 160), chapel, Enum.Material.Neon)
	sign(altar, "CHAPEL · P rebirth at 80 coins", Vector3.new(0, 8, 0), Color3.fromRGB(255, 230, 160))
	prompt(altar, "RebirthPrompt", "Last Bell", "Rebirth", Enum.KeyCode.P, 16)

	-- WILLOW (west) herbs
	local willow, wo = houseShell(root, "WillowHome", CFrame.new(-95, 7, 10), Color3.fromRGB(118, 128, 96), Color3.fromRGB(70, 92, 58))
	furnishRoom(willow, wo)
	for i = 0, 3 do
		part("HerbBox" .. i, Vector3.new(4.2, 1.3, 6.5), CFrame.new(-104 + i * 6, 8.3, -8), Color3.fromRGB(70 + i * 8, 115, 50), willow, Enum.Material.Grass)
	end
	part("DryingRail", Vector3.new(12, 0.4, 0.4), CFrame.new(-95, 12.5, -2), Color3.fromRGB(160, 140, 90), willow, Enum.Material.Wood)
	local herbs = part("Herbs", Vector3.new(6, 1.5, 6), CFrame.new(-95, 8.7, -8), Color3.fromRGB(90, 160, 70), willow, Enum.Material.Grass)
	sign(herbs, "WILLOW · E gather herbs", Vector3.new(0, 6.5, 0), Color3.fromRGB(180, 255, 170))
	prompt(herbs, "HerbPrompt", "Herb garden", "Gather herbs", Enum.KeyCode.E, 14)

	-- ASH (east) wood
	local ash, ao = houseShell(root, "AshCottage", CFrame.new(95, 7, 10), Color3.fromRGB(128, 96, 70), Color3.fromRGB(96, 58, 36))
	furnishRoom(ash, ao)
	part("Woodpile", Vector3.new(7, 3.4, 4.5), CFrame.new(95, 9.3, -10), Color3.fromRGB(86, 58, 34), ash, Enum.Material.Wood)
	part("ChopBlock", Vector3.new(2.8, 1.8, 2.8), CFrame.new(102, 8.4, -8), Color3.fromRGB(70, 50, 35), ash, Enum.Material.Wood)
	part("Barrel", Vector3.new(3.2, 4.2, 3.2), CFrame.new(88, 9.4, -8), Color3.fromRGB(92, 62, 32), ash, Enum.Material.Wood)
	local wood = part("WoodStation", Vector3.new(5, 2.2, 4), CFrame.new(95, 8.6, -10), Color3.fromRGB(110, 78, 48), ash, Enum.Material.WoodPlanks)
	sign(wood, "ASH · E chop wood", Vector3.new(0, 6.5, 0), Color3.fromRGB(255, 210, 150))
	prompt(wood, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 14)

	-- INN (south) cook
	local inn, io = houseShell(root, "LastBellInn", CFrame.new(0, 7, 100), Color3.fromRGB(140, 92, 64), Color3.fromRGB(150, 50, 40))
	furnishRoom(inn, io)
	part("InnSign", Vector3.new(12, 4.5, 0.6), CFrame.new(0, 17, 84), Color3.fromRGB(160, 40, 40), inn, Enum.Material.Wood)
	part("Porch", Vector3.new(18, 1, 9), CFrame.new(0, 7.7, 84), Color3.fromRGB(100, 74, 48), inn, Enum.Material.WoodPlanks)
	local porchLight = part("PorchLight", Vector3.new(1.5, 1.5, 1.5), CFrame.new(0, 13.5, 84), Color3.fromRGB(255, 200, 110), inn, Enum.Material.Neon)
	porchLight.CanCollide = false
	lightOn(porchLight, Vector3.new(), Color3.fromRGB(255, 180, 90), 18)
	part("Bar", Vector3.new(16, 2.4, 3.2), CFrame.new(0, 9.1, 108), Color3.fromRGB(90, 60, 36), inn, Enum.Material.Wood)
	for i = -2, 2 do
		part("Stool" .. i, Vector3.new(2, 2.1, 2), CFrame.new(i * 3, 8.7, 104), Color3.fromRGB(70, 48, 28), inn, Enum.Material.Wood)
	end
	local kitchen = part("Kitchen", Vector3.new(7, 2.2, 7), CFrame.new(8, 8.9, 110), Color3.fromRGB(180, 120, 70), inn, Enum.Material.Wood)
	part("Stove", Vector3.new(3.5, 2.5, 2.5), CFrame.new(8, 9.4, 112), Color3.fromRGB(40, 40, 45), inn, Enum.Material.Metal)
	part("Pot", Vector3.new(2.2, 2, 2.2), CFrame.new(8, 11.5, 112), Color3.fromRGB(50, 50, 55), inn, Enum.Material.Metal)
	sign(kitchen, "INN · F cook meal", Vector3.new(0, 6.5, 0), Color3.fromRGB(255, 200, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 14)

	-- REED DOCK (southwest) extra herbs
	local reed, ro = houseShell(root, "ReedHouse", CFrame.new(-95, 7, -55), Color3.fromRGB(176, 156, 110), Color3.fromRGB(150, 122, 58))
	furnishRoom(reed, ro)
	part("Dock", Vector3.new(12, 0.7, 14), CFrame.new(-95, 7.5, -75), Color3.fromRGB(118, 82, 52), reed, Enum.Material.WoodPlanks)
	for i = 0, 4 do
		part("ReedRack" .. i, Vector3.new(0.4, 4.2, 0.4), CFrame.new(-82 + i * 2.2, 9.4, -68), Color3.fromRGB(70, 48, 28), reed, Enum.Material.Wood)
		part("ReedBundle" .. i, Vector3.new(0.7, 3.4, 0.7), CFrame.new(-82 + i * 2.2, 9.6, -67.4), Color3.fromRGB(74, 118, 52), reed, Enum.Material.Grass)
	end
	local reedBonus = part("ReedHerbs", Vector3.new(5, 1.4, 5), CFrame.new(-88, 8.6, -70), Color3.fromRGB(74, 118, 52), reed, Enum.Material.Grass)
	sign(reedBonus, "REED DOCK · E extra herbs", Vector3.new(0, 6.5, 0), Color3.fromRGB(200, 230, 180))
	prompt(reedBonus, "HerbPrompt", "River herbs", "Gather herbs", Enum.KeyCode.E, 12)

	-- SMITHY (southeast) extra wood
	local smithy, so = houseShell(root, "MillbrookSmithy", CFrame.new(95, 7, -55), Color3.fromRGB(92, 78, 68), Color3.fromRGB(70, 70, 72))
	furnishRoom(smithy, so)
	part("LeanRoof", Vector3.new(18, 0.7, 13), CFrame.new(95, 14.5, -72), Color3.fromRGB(70, 70, 72), smithy, Enum.Material.Metal)
	part("Forge", Vector3.new(6.5, 3.2, 4.5), CFrame.new(88, 9.2, -70), Color3.fromRGB(50, 50, 52), smithy, Enum.Material.Basalt)
	local coals = part("Coals", Vector3.new(4.2, 0.7, 2.6), CFrame.new(88, 11.1, -70), Color3.fromRGB(255, 90, 30), smithy, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(255, 120, 40), 20)
	part("Anvil", Vector3.new(3.2, 1.5, 1.8), CFrame.new(102, 8.4, -70), Color3.fromRGB(40, 40, 44), smithy, Enum.Material.Metal)
	local scrap = part("ScrapWood", Vector3.new(5, 2, 4), CFrame.new(102, 8.6, -64), Color3.fromRGB(90, 70, 50), smithy, Enum.Material.WoodPlanks)
	sign(scrap, "SMITHY · E scrap wood", Vector3.new(0, 6.5, 0), Color3.fromRGB(255, 170, 90))
	prompt(scrap, "WoodPrompt", "Scrap wood", "Chop wood", Enum.KeyCode.E, 14)

	-- PLAYER BASES (4 corners near roads — each joiner gets one)
	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	local spots = {
		CFrame.new(-55, 7, 55) * CFrame.Angles(0, math.rad(45), 0),
		CFrame.new(55, 7, 55) * CFrame.Angles(0, math.rad(-45), 0),
		CFrame.new(-55, 7, -35) * CFrame.Angles(0, math.rad(135), 0),
		CFrame.new(55, 7, -35) * CFrame.Angles(0, math.rad(-135), 0),
	}
	for i, cf in ipairs(spots) do
		buildPlayerBase(bases, i, cf)
	end

	-- SpawnGuide (first-join fallback near market)
	part("Plaza", Vector3.new(8, 0.4, 8), CFrame.new(0, 7.4, 18), Color3.fromRGB(90, 120, 90), root, Enum.Material.Grass)

	print("[Village] VILLAGE-04 full village + player bases ready")
	return root
end

return World
