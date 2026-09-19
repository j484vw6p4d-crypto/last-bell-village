--!nocheck
-- Builds furnished Millbrook pieces. Never clears Terrain or wipes Workspace.
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
	bill.Size = UDim2.fromOffset(300, 40)
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
	t.TextStrokeTransparency = 0.5
	t.Parent = bill
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.25
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
	l.Brightness = 1.3
	l.Range = range or 16
	l.Parent = a
end

local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	local floor = part("Floor", Vector3.new(28, 1.2, 22), origin * CFrame.new(0, 0.6, 0), Color3.fromRGB(92, 68, 44), m, Enum.Material.WoodPlanks)
	m.PrimaryPart = floor
	part("WallB", Vector3.new(28, 12, 1), origin * CFrame.new(0, 6.6, 10.6), wall, m, Enum.Material.Brick)
	part("WallL", Vector3.new(1, 12, 22), origin * CFrame.new(-13.6, 6.6, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(1, 12, 22), origin * CFrame.new(13.6, 6.6, 0), wall, m, Enum.Material.Brick)
	part("WallF", Vector3.new(10, 12, 1), origin * CFrame.new(-9, 6.6, -10.6), wall, m, Enum.Material.Brick)
	part("WallF2", Vector3.new(10, 12, 1), origin * CFrame.new(9, 6.6, -10.6), wall, m, Enum.Material.Brick)
	part("Door", Vector3.new(8, 9, 0.4), origin * CFrame.new(0, 4.6, -10.6), Color3.fromRGB(40, 28, 18), m, Enum.Material.Wood)
	part("Roof", Vector3.new(32, 1.2, 26), origin * CFrame.new(0, 13.2, 0) * CFrame.Angles(0.12, 0, 0), roof, m, Enum.Material.Slate)
	part("Chimney", Vector3.new(2.4, 6, 2.4), origin * CFrame.new(10, 16, 6), Color3.fromRGB(90, 70, 60), m, Enum.Material.Brick)
	part("WindowL", Vector3.new(3, 3, 0.3), origin * CFrame.new(-8, 7, -10.85), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("WindowR", Vector3.new(3, 3, 0.3), origin * CFrame.new(8, 7, -10.85), Color3.fromRGB(160, 200, 210), m, Enum.Material.Glass)
	part("Table", Vector3.new(8, 1, 4), origin * CFrame.new(-4, 2.4, 2), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("Chair", Vector3.new(2, 2.2, 2), origin * CFrame.new(-4, 2.1, -1.4), Color3.fromRGB(78, 54, 34), m, Enum.Material.Wood)
	part("Bed", Vector3.new(6, 1.4, 10), origin * CFrame.new(8, 2.2, 2), Color3.fromRGB(140, 70, 70), m, Enum.Material.Fabric)
	part("Shelf", Vector3.new(8, 6, 1.2), origin * CFrame.new(-10, 5, 8), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	part("CrateA", Vector3.new(2.4, 2.4, 2.4), origin * CFrame.new(10, 2.4, -6), Color3.fromRGB(110, 80, 48), m, Enum.Material.WoodPlanks)
	part("CrateB", Vector3.new(2.2, 2.2, 2.2), origin * CFrame.new(12, 2.3, -4), Color3.fromRGB(96, 70, 40), m, Enum.Material.WoodPlanks)
	part("Rug", Vector3.new(10, 0.2, 8), origin * CFrame.new(0, 1.3, 0), Color3.fromRGB(110, 42, 42), m, Enum.Material.Fabric).CanCollide = false
	local lamp = part("Lamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 10.4, 0), Color3.fromRGB(255, 210, 130), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 210, 130), 14)
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
	part("WellPostA", Vector3.new(0.6, 8, 0.6), CFrame.new(-3, 14, 0), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	part("WellPostB", Vector3.new(0.6, 8, 0.6), CFrame.new(3, 14, 0), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	part("WellRoof", Vector3.new(9, 0.5, 9), CFrame.new(0, 18, 0), Color3.fromRGB(118, 82, 52), root, Enum.Material.Wood)
	sign(well, "MILLBROOK SQUARE", Vector3.new(0, 10, 0))
	part("BenchA", Vector3.new(8, 1.4, 2), CFrame.new(-16, 7.6, 14), Color3.fromRGB(82, 58, 36), root, Enum.Material.Wood)
	part("BenchB", Vector3.new(8, 1.4, 2), CFrame.new(16, 7.6, 14), Color3.fromRGB(82, 58, 36), root, Enum.Material.Wood)
	part("CrateStack", Vector3.new(3, 3, 3), CFrame.new(-22, 8.4, -10), Color3.fromRGB(110, 80, 48), root, Enum.Material.WoodPlanks)
	local board = part("NoticeBoard", Vector3.new(10, 8, 0.6), CFrame.new(0, 12, 22), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	sign(board, "MAYOR ALDEN  ·  E hear the task", Vector3.new(0, 6, 0), Color3.fromRGB(255, 220, 140))
	prompt(board, "SquarePrompt", "Mayor Alden", "Hear the task", Enum.KeyCode.E, 16)

	local chapel = Instance.new("Model")
	chapel.Name = "ChapelOfTheLastBell"
	chapel.Parent = root
	part("Nave", Vector3.new(20, 16, 28), CFrame.new(0, 15, -70), Color3.fromRGB(226, 220, 206), chapel, Enum.Material.Concrete)
	part("Tower", Vector3.new(8, 28, 8), CFrame.new(0, 28, -82), Color3.fromRGB(220, 216, 204), chapel, Enum.Material.Concrete)
	part("TowerRoof", Vector3.new(10, 1.4, 10), CFrame.new(0, 43, -82), Color3.fromRGB(62, 68, 74), chapel, Enum.Material.Slate)
	part("Spire", Vector3.new(1.6, 8, 1.6), CFrame.new(0, 48, -82), Color3.fromRGB(212, 176, 64), chapel, Enum.Material.Metal)
	local bell = part("LastBell", Vector3.new(4, 4, 4), CFrame.new(0, 40, -82), Color3.fromRGB(220, 180, 60), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(255, 220, 120), 22)
	part("Door", Vector3.new(6, 10, 1), CFrame.new(0, 12, -56), Color3.fromRGB(50, 32, 20), chapel, Enum.Material.Wood)
	part("Pew1", Vector3.new(12, 2, 2), CFrame.new(0, 8, -64), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	part("Pew2", Vector3.new(12, 2, 2), CFrame.new(0, 8, -68), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	part("Pew3", Vector3.new(12, 2, 2), CFrame.new(0, 8, -72), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	part("Path", Vector3.new(6, 0.4, 22), CFrame.new(0, 7.2, -48), Color3.fromRGB(128, 124, 118), chapel, Enum.Material.Cobblestone)
	local altar = part("Altar", Vector3.new(8, 2, 4), CFrame.new(0, 8.2, -80), Color3.fromRGB(180, 160, 90), chapel, Enum.Material.Marble)
	sign(altar, "CHAPEL OF THE LAST BELL", Vector3.new(0, 8, 0), Color3.fromRGB(255, 230, 160))
	prompt(altar, "ChapelPrompt", "Last Bell", "Assemble and ring", Enum.KeyCode.E, 16)

	local willow = house(root, "WillowHome", CFrame.new(-72, 7, 8), Color3.fromRGB(118, 128, 96), Color3.fromRGB(70, 92, 58))
	part("HerbBox1", Vector3.new(4, 1.2, 6), CFrame.new(-72, 8.2, -8), Color3.fromRGB(70, 110, 50), willow, Enum.Material.Grass)
	part("HerbBox2", Vector3.new(4, 1.2, 6), CFrame.new(-66, 8.2, -8), Color3.fromRGB(62, 102, 44), willow, Enum.Material.Grass)
	part("HerbBox3", Vector3.new(4, 1.2, 6), CFrame.new(-78, 8.2, -8), Color3.fromRGB(80, 120, 55), willow, Enum.Material.Grass)
	part("DryingRail", Vector3.new(10, 0.4, 0.4), CFrame.new(-72, 12, -4), Color3.fromRGB(160, 140, 90), willow, Enum.Material.Wood)
	local herbs = part("Herbs", Vector3.new(5, 1.4, 5), CFrame.new(-72, 8.6, -8), Color3.fromRGB(90, 160, 70), willow, Enum.Material.Grass)
	sign(herbs, "WILLOW HOME  ·  E ask Willow", Vector3.new(0, 7, 0), Color3.fromRGB(180, 255, 170))
	prompt(herbs, "WillowPrompt", "Willow the Herbalist", "Ask for blessing oil", Enum.KeyCode.E, 14)

	local ash = house(root, "AshCottage", CFrame.new(72, 7, 8), Color3.fromRGB(128, 96, 70), Color3.fromRGB(96, 58, 36))
	part("Woodpile", Vector3.new(6, 3, 4), CFrame.new(72, 9, -8), Color3.fromRGB(86, 58, 34), ash, Enum.Material.Wood)
	part("Barrel", Vector3.new(3, 4, 3), CFrame.new(66, 9.2, -7), Color3.fromRGB(92, 62, 32), ash, Enum.Material.Wood)
	local chest = part("LoftChest", Vector3.new(4, 2.4, 3), CFrame.new(78, 8.8, 8), Color3.fromRGB(150, 110, 50), ash, Enum.Material.Wood)
	part("ChestLid", Vector3.new(4, 0.3, 3), CFrame.new(78, 10.15, 8), Color3.fromRGB(120, 84, 36), ash, Enum.Material.Wood)
	sign(chest, "ASH COTTAGE  ·  E search loft", Vector3.new(0, 7, 0), Color3.fromRGB(255, 210, 150))
	prompt(chest, "AshPrompt", "Old Bram's loft chest", "Search for the rope", Enum.KeyCode.E, 14)

	local inn = house(root, "LastBellInn", CFrame.new(0, 7, 72), Color3.fromRGB(140, 92, 64), Color3.fromRGB(150, 50, 40))
	part("InnSign", Vector3.new(10, 4, 0.5), CFrame.new(0, 16, 58), Color3.fromRGB(160, 40, 40), inn, Enum.Material.Wood)
	part("Porch", Vector3.new(16, 1, 8), CFrame.new(0, 7.6, 58), Color3.fromRGB(100, 74, 48), inn, Enum.Material.WoodPlanks)
	local porchLight = part("PorchLight", Vector3.new(1.4, 1.4, 1.4), CFrame.new(0, 13, 58), Color3.fromRGB(255, 200, 110), inn, Enum.Material.Neon)
	porchLight.CanCollide = false
	lightOn(porchLight, Vector3.new(), Color3.fromRGB(255, 180, 90), 16)
	part("Bar", Vector3.new(14, 2.2, 3), CFrame.new(0, 9, 76), Color3.fromRGB(90, 60, 36), inn, Enum.Material.Wood)
	part("Stool1", Vector3.new(2, 2, 2), CFrame.new(-4, 8.6, 72), Color3.fromRGB(70, 48, 28), inn, Enum.Material.Wood)
	part("Stool2", Vector3.new(2, 2, 2), CFrame.new(4, 8.6, 72), Color3.fromRGB(70, 48, 28), inn, Enum.Material.Wood)
	local kitchen = part("Kitchen", Vector3.new(6, 2, 6), CFrame.new(8, 8.8, 78), Color3.fromRGB(180, 120, 70), inn, Enum.Material.Wood)
	sign(kitchen, "LAST BELL INN  ·  E talk to Mira", Vector3.new(0, 7, 0), Color3.fromRGB(255, 200, 140))
	prompt(kitchen, "InnPrompt", "Mira the Innkeeper", "Ask about the bell", Enum.KeyCode.E, 14)

	local reedHome = house(root, "ReedHouse", CFrame.new(-72, 7, -48), Color3.fromRGB(176, 156, 110), Color3.fromRGB(150, 122, 58))
	part("Dock", Vector3.new(10, 0.6, 12), CFrame.new(-72, 7.4, -66), Color3.fromRGB(118, 82, 52), reedHome, Enum.Material.WoodPlanks)
	for i = 0, 3 do
		part("ReedRack" .. i, Vector3.new(0.4, 4, 0.4), CFrame.new(-58 + i * 2, 9.2, -58), Color3.fromRGB(70, 48, 28), reedHome, Enum.Material.Wood)
		part("ReedBundle" .. i, Vector3.new(0.6, 3.2, 0.6), CFrame.new(-58 + i * 2, 9.4, -57.4), Color3.fromRGB(74, 118, 52), reedHome, Enum.Material.Grass)
	end
	local reedFolder = Instance.new("Folder")
	reedFolder.Name = "RiverReeds"
	reedFolder.Parent = root
	local reedSpots = {
		Vector3.new(-64, 8.6, -62),
		Vector3.new(-68, 8.6, -70),
		Vector3.new(-76, 8.6, -66),
		Vector3.new(-80, 8.6, -58),
		Vector3.new(-60, 8.6, -54),
	end
	for i, pos in ipairs(reedSpots) do
		local reed = part("RiverReed_" .. i, Vector3.new(0.7, 3.4, 0.7), CFrame.new(pos), Color3.fromRGB(74, 118, 52), reedFolder, Enum.Material.Grass)
		reed.CanCollide = false
		prompt(reed, "ReedPrompt", "River reed", "Pick reed", Enum.KeyCode.E, 12)
	end
	sign(reedHome.PrimaryPart, "REED HOUSE  ·  E cut 5 reeds", Vector3.new(0, 12, 0), Color3.fromRGB(200, 230, 180))

	local smithy = house(root, "MillbrookSmithy", CFrame.new(72, 7, -48), Color3.fromRGB(92, 78, 68), Color3.fromRGB(70, 70, 72))
	part("LeanRoof", Vector3.new(16, 0.6, 12), CFrame.new(72, 14, -62), Color3.fromRGB(70, 70, 72), smithy, Enum.Material.Metal)
	part("Forge", Vector3.new(6, 3, 4), CFrame.new(68, 9, -60), Color3.fromRGB(50, 50, 52), smithy, Enum.Material.Basalt)
	local coals = part("Coals", Vector3.new(4, 0.6, 2.4), CFrame.new(68, 10.8, -60), Color3.fromRGB(255, 90, 30), smithy, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(255, 120, 40), 18)
	part("Anvil", Vector3.new(3, 1.4, 1.6), CFrame.new(76, 8.4, -60), Color3.fromRGB(40, 40, 44), smithy, Enum.Material.Metal)
	part("WeaponRack", Vector3.new(6, 5, 0.4), CFrame.new(80, 10, -52), Color3.fromRGB(70, 48, 28), smithy, Enum.Material.Wood)
	local anvilTalk = part("SmithStation", Vector3.new(4, 2, 4), CFrame.new(76, 8.6, -60), Color3.fromRGB(50, 50, 54), smithy, Enum.Material.Metal)
	sign(anvilTalk, "MILLBROOK SMITHY  ·  E forge clapper", Vector3.new(0, 7, 0), Color3.fromRGB(255, 170, 90))
	prompt(anvilTalk, "SmithyPrompt", "Smith Rowan", "Forge the clapper", Enum.KeyCode.E, 14)

	print("[Village] Millbrook furnished buildings ready")
	return root
end

return World
