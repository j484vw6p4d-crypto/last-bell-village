--!nocheck
-- VILLAGE-05: raised plateau (no underground bases), huge spaced plots, lit village + night horror props.
-- Never clears Terrain or wipes Workspace.
local World = {}

local GROUND_Y = 120 -- top of village floor

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
	p.CastShadow = true
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
	p.CastShadow = true
	p.Parent = parent
	return p
end

local function sign(adornee, text, offset, color)
	local bill = Instance.new("BillboardGui")
	bill.Name = "Sign"
	bill.Size = UDim2.fromOffset(360, 48)
	bill.StudsOffset = offset or Vector3.new(0, 8, 0)
	bill.AlwaysOnTop = true
	bill.MaxDistance = 260
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 236, 200)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextStrokeTransparency = 0.35
	t.Parent = bill
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.12
	pr.MaxActivationDistance = dist or 16
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key or Enum.KeyCode.E
	pr.Parent = parent
	return pr
end

local function lightOn(parent, offset, color, range, brightness)
	local a = Instance.new("Attachment")
	a.Position = offset or Vector3.new(0, 1.2, 0)
	a.Parent = parent
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Brightness = brightness or 1.6
	l.Range = range or 22
	l.Shadows = true
	l.Parent = a
	return l
end

local function lantern(parent, pos)
	local cf = CFrame.new(pos)
	part("Pole", Vector3.new(0.5, 12, 0.5), cf * CFrame.new(0, 6, 0), Color3.fromRGB(48, 36, 26), parent, Enum.Material.Wood)
	local lamp = part("Lamp", Vector3.new(1.6, 1.8, 1.6), cf * CFrame.new(0, 12.2, 0), Color3.fromRGB(255, 205, 120), parent, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 190, 110), 28, 2)
	return lamp
end

local function road(parent, size, x, z)
	return part("Road", size, CFrame.new(x, GROUND_Y + 0.25, z), Color3.fromRGB(92, 86, 78), parent, Enum.Material.Cobblestone)
end

local function prettyHouse(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	local floor = part("Floor", Vector3.new(34, 1.4, 28), origin * CFrame.new(0, 0.7, 0), Color3.fromRGB(98, 74, 48), m, Enum.Material.WoodPlanks)
	m.PrimaryPart = floor
	-- stone foundation
	part("Foundation", Vector3.new(36, 2.2, 30), origin * CFrame.new(0, -0.4, 0), Color3.fromRGB(110, 105, 98), m, Enum.Material.Slate)
	part("WallB", Vector3.new(34, 14, 1.2), origin * CFrame.new(0, 8, 13.4), wall, m, Enum.Material.Brick)
	part("WallL", Vector3.new(1.2, 14, 28), origin * CFrame.new(-16.4, 8, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(1.2, 14, 28), origin * CFrame.new(16.4, 8, 0), wall, m, Enum.Material.Brick)
	part("WallF", Vector3.new(12, 14, 1.2), origin * CFrame.new(-11, 8, -13.4), wall, m, Enum.Material.Brick)
	part("WallF2", Vector3.new(12, 14, 1.2), origin * CFrame.new(11, 8, -13.4), wall, m, Enum.Material.Brick)
	part("Lintel", Vector3.new(10, 3.5, 1.2), origin * CFrame.new(0, 13, -13.4), wall, m, Enum.Material.Brick)
	part("Door", Vector3.new(8.5, 10.5, 0.5), origin * CFrame.new(0, 5.8, -13.4), Color3.fromRGB(42, 28, 18), m, Enum.Material.Wood)
	wedge("RoofA", Vector3.new(16, 6, 36), origin * CFrame.new(-9, 17, 0) * CFrame.Angles(0, 0, 0.06), roof, m, Enum.Material.Slate)
	wedge("RoofB", Vector3.new(16, 6, 36), origin * CFrame.new(9, 17, 0) * CFrame.Angles(0, math.pi, 0.06), roof, m, Enum.Material.Slate)
	part("Chimney", Vector3.new(3, 9, 3), origin * CFrame.new(11, 20, 7), Color3.fromRGB(88, 70, 60), m, Enum.Material.Brick)
	part("WindowL", Vector3.new(3.6, 3.6, 0.3), origin * CFrame.new(-10, 8.5, -13.9), Color3.fromRGB(170, 210, 220), m, Enum.Material.Glass)
	part("WindowR", Vector3.new(3.6, 3.6, 0.3), origin * CFrame.new(10, 8.5, -13.9), Color3.fromRGB(170, 210, 220), m, Enum.Material.Glass)
	part("WindowSideL", Vector3.new(0.3, 3.2, 3.2), origin * CFrame.new(-16.9, 8.5, 4), Color3.fromRGB(170, 210, 220), m, Enum.Material.Glass)
	part("WindowSideR", Vector3.new(0.3, 3.2, 3.2), origin * CFrame.new(16.9, 8.5, 4), Color3.fromRGB(170, 210, 220), m, Enum.Material.Glass)
	part("Rug", Vector3.new(12, 0.2, 10), origin * CFrame.new(0, 1.5, 0), Color3.fromRGB(100, 36, 36), m, Enum.Material.Fabric).CanCollide = false
	part("Table", Vector3.new(8, 1, 4), origin * CFrame.new(-6, 2.6, 2), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("ChairA", Vector3.new(2.1, 2.2, 2.1), origin * CFrame.new(-6, 2.4, -1.4), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("ChairB", Vector3.new(2.1, 2.2, 2.1), origin * CFrame.new(-3, 2.4, 2), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("Bed", Vector3.new(7, 1.5, 11), origin * CFrame.new(10, 2.4, 2), Color3.fromRGB(120, 70, 80), m, Enum.Material.Fabric)
	part("Shelf", Vector3.new(9, 6, 1.2), origin * CFrame.new(-13, 5.5, 9), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	part("Hearth", Vector3.new(5, 4, 2.2), origin * CFrame.new(11, 3.5, 11), Color3.fromRGB(70, 55, 48), m, Enum.Material.Brick)
	local fire = part("Fire", Vector3.new(2.4, 1.2, 1.2), origin * CFrame.new(11, 5.6, 11), Color3.fromRGB(255, 120, 40), m, Enum.Material.Neon)
	fire.CanCollide = false
	lightOn(fire, Vector3.new(0, 1, 0), Color3.fromRGB(255, 130, 50), 16, 1.4)
	local lamp = part("CeilingLamp", Vector3.new(1.4, 1.4, 1.4), origin * CFrame.new(0, 12.5, 0), Color3.fromRGB(255, 215, 140), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 210, 140), 18, 1.5)
	-- porch
	part("Porch", Vector3.new(14, 1, 8), origin * CFrame.new(0, 0.7, -18), Color3.fromRGB(100, 74, 48), m, Enum.Material.WoodPlanks)
	part("PorchRailL", Vector3.new(0.4, 2.4, 8), origin * CFrame.new(-6.5, 2.2, -18), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	part("PorchRailR", Vector3.new(0.4, 2.4, 8), origin * CFrame.new(6.5, 2.2, -18), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	local porchLamp = part("PorchLamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 7, -18), Color3.fromRGB(255, 200, 110), m, Enum.Material.Neon)
	porchLamp.CanCollide = false
	lightOn(porchLamp, Vector3.new(), Color3.fromRGB(255, 185, 100), 20, 1.8)
	return m, origin
end

local function buildPlayerBase(parent, index, x, z)
	local origin = CFrame.new(x, GROUND_Y, z)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	-- huge yard plate so players never sink into Test 1 terrain
	local yard = part("Yard", Vector3.new(70, 3, 64), origin * CFrame.new(0, -1.4, 0), Color3.fromRGB(72, 105, 58), m, Enum.Material.Grass)
	m.PrimaryPart = yard
	part("YardEdge", Vector3.new(72, 1.2, 66), origin * CFrame.new(0, -2.8, 0), Color3.fromRGB(95, 90, 82), m, Enum.Material.Slate)
	part("Path", Vector3.new(8, 0.4, 28), origin * CFrame.new(0, 0.25, -18), Color3.fromRGB(118, 108, 95), m, Enum.Material.Cobblestone)
	part("FenceL", Vector3.new(0.6, 4, 60), origin * CFrame.new(-34, 2, 0), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("FenceR", Vector3.new(0.6, 4, 60), origin * CFrame.new(34, 2, 0), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("FenceB", Vector3.new(70, 4, 0.6), origin * CFrame.new(0, 2, 31), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("GateL", Vector3.new(5, 4.2, 0.5), origin * CFrame.new(-5, 2.2, -31), Color3.fromRGB(65, 45, 28), m, Enum.Material.Wood)
	part("GateR", Vector3.new(5, 4.2, 0.5), origin * CFrame.new(5, 2.2, -31), Color3.fromRGB(65, 45, 28), m, Enum.Material.Wood)

	local houseOrigin = origin * CFrame.new(0, 0.2, 6)
	part("HouseFloor", Vector3.new(28, 1.3, 22), houseOrigin * CFrame.new(0, 0.65, 0), Color3.fromRGB(105, 80, 55), m, Enum.Material.WoodPlanks)
	part("HouseFound", Vector3.new(30, 2, 24), houseOrigin * CFrame.new(0, -0.5, 0), Color3.fromRGB(100, 96, 90), m, Enum.Material.Slate)
	part("HouseWallB", Vector3.new(28, 13, 1.1), houseOrigin * CFrame.new(0, 7.2, 10.5), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallL", Vector3.new(1.1, 13, 22), houseOrigin * CFrame.new(-13.5, 7.2, 0), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallR", Vector3.new(1.1, 13, 22), houseOrigin * CFrame.new(13.5, 7.2, 0), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallF", Vector3.new(9, 13, 1.1), houseOrigin * CFrame.new(-9.5, 7.2, -10.5), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallF2", Vector3.new(9, 13, 1.1), houseOrigin * CFrame.new(9.5, 7.2, -10.5), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseDoor", Vector3.new(8, 10, 0.45), houseOrigin * CFrame.new(0, 5.5, -10.5), Color3.fromRGB(50, 32, 20), m, Enum.Material.Wood)
	wedge("HouseRoofA", Vector3.new(14, 5, 26), houseOrigin * CFrame.new(-7.5, 15.5, 0) * CFrame.Angles(0, 0, 0.08), Color3.fromRGB(100, 48, 38), m, Enum.Material.Slate)
	wedge("HouseRoofB", Vector3.new(14, 5, 26), houseOrigin * CFrame.new(7.5, 15.5, 0) * CFrame.Angles(0, math.pi, 0.08), Color3.fromRGB(100, 48, 38), m, Enum.Material.Slate)
	part("HouseBed", Vector3.new(6.5, 1.4, 10), houseOrigin * CFrame.new(7, 2.2, 2), Color3.fromRGB(80, 100, 140), m, Enum.Material.Fabric)
	part("HouseTable", Vector3.new(7, 1, 3.5), houseOrigin * CFrame.new(-6, 2.2, 1), Color3.fromRGB(110, 80, 50), m, Enum.Material.Wood)
	part("HouseChest", Vector3.new(3.5, 2.4, 2.6), houseOrigin * CFrame.new(-7, 2.4, 6), Color3.fromRGB(140, 100, 50), m, Enum.Material.Wood)
	part("HouseWindowL", Vector3.new(3, 3, 0.25), houseOrigin * CFrame.new(-8.5, 7, -10.9), Color3.fromRGB(165, 205, 215), m, Enum.Material.Glass)
	part("HouseWindowR", Vector3.new(3, 3, 0.25), houseOrigin * CFrame.new(8.5, 7, -10.9), Color3.fromRGB(165, 205, 215), m, Enum.Material.Glass)
	local houseLamp = part("HouseLamp", Vector3.new(1.2, 1.2, 1.2), houseOrigin * CFrame.new(0, 11, 0), Color3.fromRGB(255, 215, 140), m, Enum.Material.Neon)
	houseLamp.CanCollide = false
	lightOn(houseLamp, Vector3.new(), Color3.fromRGB(255, 210, 140), 16, 1.5)

	-- big stall / bank in front yard
	part("Awning", Vector3.new(16, 0.5, 10), origin * CFrame.new(0, 9, -14), Color3.fromRGB(150, 45, 40), m, Enum.Material.Fabric)
	part("AwningPoleL", Vector3.new(0.55, 9, 0.55), origin * CFrame.new(-6.5, 4.5, -17), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("AwningPoleR", Vector3.new(0.55, 9, 0.55), origin * CFrame.new(6.5, 4.5, -17), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("Counter", Vector3.new(14, 1.5, 4.5), origin * CFrame.new(0, 1.9, -14), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("CrateL", Vector3.new(3, 3, 3), origin * CFrame.new(-8, 2.7, -12), Color3.fromRGB(110, 80, 48), m, Enum.Material.WoodPlanks)
	part("CrateR", Vector3.new(3, 3, 3), origin * CFrame.new(8, 2.7, -12), Color3.fromRGB(96, 70, 40), m, Enum.Material.WoodPlanks)
	local bank = part("BankPad", Vector3.new(5.5, 1.1, 4.5), origin * CFrame.new(0, 2.8, -14), Color3.fromRGB(190, 160, 70), m, Enum.Material.Metal)
	sign(bank, "YOUR BASE · Q bank / R steal", Vector3.new(0, 6, 0), Color3.fromRGB(255, 220, 140))
	prompt(bank, "BankPrompt", "Your base stall", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 14)
	local stallLamp = part("StallLamp", Vector3.new(1.3, 1.3, 1.3), origin * CFrame.new(0, 8.2, -16), Color3.fromRGB(255, 200, 110), m, Enum.Material.Neon)
	stallLamp.CanCollide = false
	lightOn(stallLamp, Vector3.new(), Color3.fromRGB(255, 190, 100), 18, 1.7)

	-- spawn ON TOP of yard, never underground
	local spawn = part("SpawnPad", Vector3.new(8, 0.6, 8), origin * CFrame.new(0, 0.45, -26), Color3.fromRGB(70, 140, 95), m, Enum.Material.Grass)
	sign(spawn, "SPAWN · BASE " .. index, Vector3.new(0, 5, 0), Color3.fromRGB(180, 255, 180))
	lantern(m, Vector3.new(x - 12, GROUND_Y, z - 20))
	lantern(m, Vector3.new(x + 12, GROUND_Y, z - 20))

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

local function horrorProp(parent, pos)
	-- distant watcher silhouette (night scare prop)
	local m = Instance.new("Model")
	m.Name = "Watcher"
	m.Parent = parent
	local torso = part("Torso", Vector3.new(2.2, 3.2, 1.2), CFrame.new(pos + Vector3.new(0, 4, 0)), Color3.fromRGB(18, 18, 22), m, Enum.Material.SmoothPlastic)
	part("Head", Vector3.new(1.6, 1.6, 1.6), CFrame.new(pos + Vector3.new(0, 6.4, 0)), Color3.fromRGB(12, 12, 16), m, Enum.Material.SmoothPlastic)
	part("EyeL", Vector3.new(0.35, 0.25, 0.2), CFrame.new(pos + Vector3.new(-0.35, 6.5, -0.8)), Color3.fromRGB(180, 30, 30), m, Enum.Material.Neon).CanCollide = false
	part("EyeR", Vector3.new(0.35, 0.25, 0.2), CFrame.new(pos + Vector3.new(0.35, 6.5, -0.8)), Color3.fromRGB(180, 30, 30), m, Enum.Material.Neon).CanCollide = false
	lightOn(torso, Vector3.new(0, 2, -1), Color3.fromRGB(120, 20, 20), 10, 0.6)
end

function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "VillageBuild"
	root.Parent = workspace

	-- Raised plateau — solves underground spawns on Test 1 terrain
	part("Plateau", Vector3.new(520, 10, 520), CFrame.new(0, GROUND_Y - 5, 0), Color3.fromRGB(78, 100, 60), root, Enum.Material.Grass)
	part("PlateauRock", Vector3.new(524, 14, 524), CFrame.new(0, GROUND_Y - 12, 0), Color3.fromRGB(95, 90, 82), root, Enum.Material.Slate)
	part("PlazaRing", Vector3.new(48, 0.5, 48), CFrame.new(0, GROUND_Y + 0.3, 0), Color3.fromRGB(115, 108, 98), root, Enum.Material.Concrete)

	-- Roads
	road(root, Vector3.new(20, 0.5, 280), 0, 0)
	road(root, Vector3.new(280, 0.5, 20), 0, 0)
	road(root, Vector3.new(16, 0.5, 120), 0, -90)
	road(root, Vector3.new(120, 0.5, 16), -90, 0)
	road(root, Vector3.new(120, 0.5, 16), 90, 0)
	road(root, Vector3.new(16, 0.5, 100), 0, 90)

	-- Market center (filled, not empty)
	part("MarketStallA", Vector3.new(10, 1.2, 5), CFrame.new(-12, GROUND_Y + 1.2, 8), Color3.fromRGB(120, 86, 52), root, Enum.Material.Wood)
	part("MarketStallB", Vector3.new(10, 1.2, 5), CFrame.new(12, GROUND_Y + 1.2, 8), Color3.fromRGB(120, 86, 52), root, Enum.Material.Wood)
	part("MarketAwningA", Vector3.new(11, 0.4, 7), CFrame.new(-12, GROUND_Y + 7, 8), Color3.fromRGB(140, 50, 40), root, Enum.Material.Fabric)
	part("MarketAwningB", Vector3.new(11, 0.4, 7), CFrame.new(12, GROUND_Y + 7, 8), Color3.fromRGB(50, 70, 120), root, Enum.Material.Fabric)
	part("CrateA", Vector3.new(3, 3, 3), CFrame.new(-8, GROUND_Y + 2.1, 12), Color3.fromRGB(110, 80, 48), root, Enum.Material.WoodPlanks)
	part("CrateB", Vector3.new(2.6, 2.6, 2.6), CFrame.new(8, GROUND_Y + 2, 12), Color3.fromRGB(96, 70, 40), root, Enum.Material.WoodPlanks)
	part("Barrel", Vector3.new(3, 4, 3), CFrame.new(0, GROUND_Y + 2.5, 14), Color3.fromRGB(92, 62, 32), root, Enum.Material.Wood)
	local board = part("NoticeBoard", Vector3.new(12, 9, 0.7), CFrame.new(0, GROUND_Y + 6, 18), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	sign(board, "MILLBROOK · cook · bank 80 · survive the night", Vector3.new(0, 7, 0), Color3.fromRGB(255, 220, 140))

	for _, pos in ipairs({
		Vector3.new(-20, GROUND_Y, -20), Vector3.new(20, GROUND_Y, -20),
		Vector3.new(-20, GROUND_Y, 20), Vector3.new(20, GROUND_Y, 20),
		Vector3.new(-40, GROUND_Y, 0), Vector3.new(40, GROUND_Y, 0),
		Vector3.new(0, GROUND_Y, -40), Vector3.new(0, GROUND_Y, 40),
	}) do
		lantern(root, pos)
	end

	-- CHAPEL north
	local chapel = Instance.new("Model")
	chapel.Name = "ChapelOfTheLastBell"
	chapel.Parent = root
	local cy = GROUND_Y
	part("Nave", Vector3.new(26, 20, 40), CFrame.new(0, cy + 11, -130), Color3.fromRGB(226, 220, 206), chapel, Enum.Material.Concrete)
	part("Tower", Vector3.new(11, 38, 11), CFrame.new(0, cy + 22, -148), Color3.fromRGB(220, 216, 204), chapel, Enum.Material.Concrete)
	part("TowerRoof", Vector3.new(13, 1.8, 13), CFrame.new(0, cy + 42, -148), Color3.fromRGB(55, 60, 68), chapel, Enum.Material.Slate)
	part("Spire", Vector3.new(2, 12, 2), CFrame.new(0, cy + 49, -148), Color3.fromRGB(212, 176, 64), chapel, Enum.Material.Metal)
	local bell = part("LastBell", Vector3.new(5, 5, 5), CFrame.new(0, cy + 36, -148), Color3.fromRGB(220, 180, 60), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(255, 210, 100), 30, 2.2)
	part("Door", Vector3.new(8, 13, 1.1), CFrame.new(0, cy + 7.5, -110), Color3.fromRGB(45, 28, 18), chapel, Enum.Material.Wood)
	for i = 0, 4 do
		part("Pew" .. i, Vector3.new(14, 2.2, 2.2), CFrame.new(0, cy + 1.8, -118 - i * 4.5), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	end
	part("Carpet", Vector3.new(4, 0.15, 32), CFrame.new(0, cy + 0.4, -128), Color3.fromRGB(110, 25, 30), chapel, Enum.Material.Fabric).CanCollide = false
	local altar = part("Altar", Vector3.new(11, 2.5, 5), CFrame.new(0, cy + 2, -146), Color3.fromRGB(185, 165, 95), chapel, Enum.Material.Marble)
	part("CandleA", Vector3.new(0.55, 1.6, 0.55), CFrame.new(-2.5, cy + 4.2, -146), Color3.fromRGB(255, 230, 160), chapel, Enum.Material.Neon)
	part("CandleB", Vector3.new(0.55, 1.6, 0.55), CFrame.new(2.5, cy + 4.2, -146), Color3.fromRGB(255, 230, 160), chapel, Enum.Material.Neon)
	-- horror red underglow at chapel
	lightOn(altar, Vector3.new(0, 1, 0), Color3.fromRGB(160, 30, 30), 18, 0.9)
	sign(altar, "CHAPEL · P rebirth at 80 coins", Vector3.new(0, 8, 0), Color3.fromRGB(255, 220, 160))
	prompt(altar, "RebirthPrompt", "Last Bell", "Rebirth", Enum.KeyCode.P, 18)

	-- WILLOW west
	local willow, wo = prettyHouse(root, "WillowHome", CFrame.new(-130, GROUND_Y, 10), Color3.fromRGB(118, 132, 100), Color3.fromRGB(65, 95, 55))
	for i = 0, 4 do
		part("HerbBox" .. i, Vector3.new(4.5, 1.4, 7), CFrame.new(-145 + i * 7, GROUND_Y + 1.3, -18), Color3.fromRGB(70 + i * 6, 120, 55), willow, Enum.Material.Grass)
	end
	local herbs = part("Herbs", Vector3.new(7, 1.6, 7), CFrame.new(-130, GROUND_Y + 1.5, -18), Color3.fromRGB(90, 165, 75), willow, Enum.Material.Grass)
	sign(herbs, "WILLOW · E gather herbs", Vector3.new(0, 7, 0), Color3.fromRGB(180, 255, 170))
	prompt(herbs, "HerbPrompt", "Herb garden", "Gather herbs", Enum.KeyCode.E, 16)

	-- ASH east
	local ash = prettyHouse(root, "AshCottage", CFrame.new(130, GROUND_Y, 10), Color3.fromRGB(132, 100, 72), Color3.fromRGB(100, 58, 36))
	part("Woodpile", Vector3.new(9, 4, 5), CFrame.new(130, GROUND_Y + 2.5, -18), Color3.fromRGB(86, 58, 34), ash, Enum.Material.Wood)
	local wood = part("WoodStation", Vector3.new(6, 2.4, 5), CFrame.new(130, GROUND_Y + 1.8, -18), Color3.fromRGB(110, 78, 48), ash, Enum.Material.WoodPlanks)
	sign(wood, "ASH · E chop wood", Vector3.new(0, 7, 0), Color3.fromRGB(255, 210, 150))
	prompt(wood, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 16)

	-- INN south
	local inn = prettyHouse(root, "LastBellInn", CFrame.new(0, GROUND_Y, 140), Color3.fromRGB(145, 95, 68), Color3.fromRGB(150, 48, 40))
	part("InnSign", Vector3.new(14, 5, 0.7), CFrame.new(0, GROUND_Y + 16, 118), Color3.fromRGB(160, 40, 40), inn, Enum.Material.Wood)
	local kitchen = part("Kitchen", Vector3.new(8, 2.4, 8), CFrame.new(10, GROUND_Y + 2.2, 155), Color3.fromRGB(185, 125, 75), inn, Enum.Material.Wood)
	part("Stove", Vector3.new(4, 2.8, 3), CFrame.new(10, GROUND_Y + 2.6, 158), Color3.fromRGB(40, 40, 45), inn, Enum.Material.Metal)
	part("Pot", Vector3.new(2.4, 2.2, 2.4), CFrame.new(10, GROUND_Y + 5, 158), Color3.fromRGB(50, 50, 55), inn, Enum.Material.Metal)
	sign(kitchen, "INN · F cook meal", Vector3.new(0, 7, 0), Color3.fromRGB(255, 200, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 16)

	-- REED SW extra herbs
	local reed = prettyHouse(root, "ReedHouse", CFrame.new(-130, GROUND_Y, -70), Color3.fromRGB(176, 156, 110), Color3.fromRGB(145, 118, 55))
	part("Dock", Vector3.new(14, 0.8, 18), CFrame.new(-130, GROUND_Y + 0.6, -95), Color3.fromRGB(118, 82, 52), reed, Enum.Material.WoodPlanks)
	local reedBonus = part("ReedHerbs", Vector3.new(6, 1.5, 6), CFrame.new(-120, GROUND_Y + 1.4, -88), Color3.fromRGB(74, 118, 52), reed, Enum.Material.Grass)
	sign(reedBonus, "REED · E extra herbs", Vector3.new(0, 7, 0), Color3.fromRGB(200, 230, 180))
	prompt(reedBonus, "HerbPrompt", "River herbs", "Gather herbs", Enum.KeyCode.E, 14)

	-- SMITHY SE extra wood
	local smithy = prettyHouse(root, "MillbrookSmithy", CFrame.new(130, GROUND_Y, -70), Color3.fromRGB(95, 80, 70), Color3.fromRGB(70, 70, 74))
	part("Forge", Vector3.new(7, 3.5, 5), CFrame.new(122, GROUND_Y + 2.5, -90), Color3.fromRGB(50, 50, 52), smithy, Enum.Material.Basalt)
	local coals = part("Coals", Vector3.new(4.5, 0.8, 2.8), CFrame.new(122, GROUND_Y + 4.6, -90), Color3.fromRGB(255, 90, 30), smithy, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(255, 120, 40), 24, 2)
	local scrap = part("ScrapWood", Vector3.new(6, 2.2, 5), CFrame.new(138, GROUND_Y + 1.8, -85), Color3.fromRGB(90, 70, 50), smithy, Enum.Material.WoodPlanks)
	sign(scrap, "SMITHY · E scrap wood", Vector3.new(0, 7, 0), Color3.fromRGB(255, 170, 90))
	prompt(scrap, "WoodPrompt", "Scrap wood", "Chop wood", Enum.KeyCode.E, 14)

	-- PLAYER BASES — far apart on the plateau
	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	local spots = {
		{ -220, 220 },
		{ 220, 220 },
		{ -220, -180 },
		{ 220, -180 },
	}
	for i, s in ipairs(spots) do
		buildPlayerBase(bases, i, s[1], s[2])
	end

	-- Horror watchers at forest edge (visible especially at night fog)
	horrorProp(root, Vector3.new(-90, GROUND_Y, -160))
	horrorProp(root, Vector3.new(90, GROUND_Y, -160))
	horrorProp(root, Vector3.new(0, GROUND_Y, 185))

	-- Fog volumes as dark mist parts (subtle)
	for i, pos in ipairs({
		Vector3.new(-60, GROUND_Y + 4, -100),
		Vector3.new(60, GROUND_Y + 4, -100),
		Vector3.new(0, GROUND_Y + 3, 160),
	}) do
		local mist = part("Mist" .. i, Vector3.new(40, 8, 40), CFrame.new(pos), Color3.fromRGB(40, 45, 55), root, Enum.Material.ForceField)
		mist.CanCollide = false
		mist.Transparency = 0.55
	end

	-- Plaza spawn fallback (on plateau)
	part("Plaza", Vector3.new(10, 0.5, 10), CFrame.new(0, GROUND_Y + 0.4, 28), Color3.fromRGB(85, 125, 90), root, Enum.Material.Grass)

	print("[Village] VILLAGE-05 raised plateau + distant bases ready @ Y=" .. GROUND_Y)
	return root
end

return World
