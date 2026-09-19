--!nocheck
-- VILLAGE-11: builds ON Test 1 terrain (raycast snap). No floating plateau.
-- Only replaces folder VillageBuild. Never Terrain:Clear / Workspace wipe.
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
	bill.Size = UDim2.fromOffset(340, 44)
	bill.StudsOffset = offset or Vector3.new(0, 7, 0)
	bill.AlwaysOnTop = true
	bill.MaxDistance = 240
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
	pr.HoldDuration = 0.12
	pr.MaxActivationDistance = dist or 16
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key or Enum.KeyCode.E
	pr.Parent = parent
	return pr
end

local function lightOn(parent, offset, color, range, brightness)
	local a = Instance.new("Attachment")
	a.Position = offset or Vector3.new(0, 1, 0)
	a.Parent = parent
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Brightness = brightness or 1.5
	l.Range = range or 20
	l.Shadows = true
	l.Parent = a
	return l
end

local function lantern(parent, x, y, z)
	local cf = CFrame.new(x, y, z)
	part("Pole", Vector3.new(0.45, 10, 0.45), cf * CFrame.new(0, 5, 0), Color3.fromRGB(48, 36, 26), parent, Enum.Material.Wood)
	local lamp = part("Lamp", Vector3.new(1.5, 1.6, 1.5), cf * CFrame.new(0, 10.4, 0), Color3.fromRGB(255, 205, 120), parent, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 190, 110), 24, 1.8)
end

-- Snap to Test 1 terrain / existing parts (excludes VillageBuild).
local function groundY(x, z, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore or {}
	params.IgnoreWater = true
	local hit = workspace:Raycast(Vector3.new(x, 800, z), Vector3.new(0, -2000, 0), params)
	if hit then
		return hit.Position.Y
	end
	return 0
end

local function at(x, z, ignore)
	local y = groundY(x, z, ignore)
	return CFrame.new(x, y, z), y
end

local function furnitureTable(parent, cf)
	part("TableTop", Vector3.new(8, 0.45, 4.2), cf * CFrame.new(0, 2.6, 0), Color3.fromRGB(118, 82, 48), parent, Enum.Material.Wood)
	for _, o in ipairs({
		Vector3.new(-3.2, 1.2, -1.5), Vector3.new(3.2, 1.2, -1.5),
		Vector3.new(-3.2, 1.2, 1.5), Vector3.new(3.2, 1.2, 1.5),
	}) do
		part("Leg", Vector3.new(0.45, 2.4, 0.45), cf * CFrame.new(o), Color3.fromRGB(78, 52, 30), parent, Enum.Material.Wood)
	end
	part("Candle", Vector3.new(0.35, 0.9, 0.35), cf * CFrame.new(0, 3.3, 0), Color3.fromRGB(240, 230, 200), parent, Enum.Material.SmoothPlastic)
	local flame = part("CandleFlame", Vector3.new(0.25, 0.35, 0.25), cf * CFrame.new(0, 3.9, 0), Color3.fromRGB(255, 160, 60), parent, Enum.Material.Neon)
	flame.CanCollide = false
	lightOn(flame, Vector3.new(), Color3.fromRGB(255, 170, 80), 10, 0.9)
end

local function furnitureChair(parent, cf)
	part("Seat", Vector3.new(2.2, 0.35, 2.2), cf * CFrame.new(0, 1.6, 0), Color3.fromRGB(110, 74, 42), parent, Enum.Material.Wood)
	part("Back", Vector3.new(2.2, 2.4, 0.35), cf * CFrame.new(0, 2.9, 0.95), Color3.fromRGB(110, 74, 42), parent, Enum.Material.Wood)
	for _, o in ipairs({
		Vector3.new(-0.8, 0.75, -0.8), Vector3.new(0.8, 0.75, -0.8),
		Vector3.new(-0.8, 0.75, 0.8), Vector3.new(0.8, 0.75, 0.8),
	}) do
		part("CLeg", Vector3.new(0.3, 1.5, 0.3), cf * CFrame.new(o), Color3.fromRGB(72, 48, 28), parent, Enum.Material.Wood)
	end
end

local function furnitureBed(parent, cf)
	part("Frame", Vector3.new(8.5, 1.1, 12), cf * CFrame.new(0, 1.1, 0), Color3.fromRGB(72, 48, 28), parent, Enum.Material.Wood)
	part("Mattress", Vector3.new(8, 1.2, 11.2), cf * CFrame.new(0, 2.1, 0), Color3.fromRGB(210, 205, 195), parent, Enum.Material.Fabric)
	part("Blanket", Vector3.new(8, 0.45, 7), cf * CFrame.new(0, 2.85, 1.2), Color3.fromRGB(90, 70, 120), parent, Enum.Material.Fabric)
	part("Pillow", Vector3.new(7, 0.7, 2.2), cf * CFrame.new(0, 2.9, -4.2), Color3.fromRGB(235, 230, 220), parent, Enum.Material.Fabric)
	part("Headboard", Vector3.new(8.8, 4.5, 0.5), cf * CFrame.new(0, 3.5, -5.8), Color3.fromRGB(62, 40, 24), parent, Enum.Material.Wood)
end

local function furnitureShelf(parent, cf)
	part("ShelfBack", Vector3.new(7.5, 8, 0.4), cf * CFrame.new(0, 5, 0.6), Color3.fromRGB(68, 46, 28), parent, Enum.Material.Wood)
	for i = 0, 3 do
		part("Board" .. i, Vector3.new(7.2, 0.3, 1.4), cf * CFrame.new(0, 1.5 + i * 2, 0), Color3.fromRGB(92, 64, 40), parent, Enum.Material.Wood)
	end
	for i = 0, 5 do
		local hue = Color3.fromRGB(80 + i * 20, 50, 40 + i * 10)
		part("Book" .. i, Vector3.new(0.7, 1.5, 1), cf * CFrame.new(-2.5 + i * 1.1, 2.4, 0), hue, parent, Enum.Material.SmoothPlastic)
	end
end

local function furnitureFireplace(parent, cf)
	part("Mantel", Vector3.new(8, 1, 2.2), cf * CFrame.new(0, 6.2, 0), Color3.fromRGB(120, 115, 108), parent, Enum.Material.Limestone)
	part("SideL", Vector3.new(1.4, 5.5, 2), cf * CFrame.new(-3.2, 3.2, 0), Color3.fromRGB(105, 100, 95), parent, Enum.Material.Slate)
	part("SideR", Vector3.new(1.4, 5.5, 2), cf * CFrame.new(3.2, 3.2, 0), Color3.fromRGB(105, 100, 95), parent, Enum.Material.Slate)
	part("Hearth", Vector3.new(7, 0.6, 3), cf * CFrame.new(0, 0.5, 0.4), Color3.fromRGB(90, 88, 85), parent, Enum.Material.Concrete)
	local fire = part("Fire", Vector3.new(3.5, 2.2, 1.2), cf * CFrame.new(0, 2.2, 0), Color3.fromRGB(255, 110, 35), parent, Enum.Material.Neon)
	fire.CanCollide = false
	lightOn(fire, Vector3.new(0, 1, 0), Color3.fromRGB(255, 120, 40), 22, 2.2)
	part("Chimney", Vector3.new(3.2, 14, 3.2), cf * CFrame.new(0, 14, 0.2), Color3.fromRGB(95, 72, 62), parent, Enum.Material.Brick)
end

local function furnitureRug(parent, cf, color)
	part("Rug", Vector3.new(12, 0.15, 8), cf, color or Color3.fromRGB(120, 45, 45), parent, Enum.Material.Fabric)
end

local function furnitureBarrel(parent, cf)
	part("Barrel", Vector3.new(2.8, 3.2, 2.8), cf * CFrame.new(0, 1.6, 0), Color3.fromRGB(92, 62, 32), parent, Enum.Material.Wood)
	part("Ring", Vector3.new(2.95, 0.25, 2.95), cf * CFrame.new(0, 2.4, 0), Color3.fromRGB(60, 60, 65), parent, Enum.Material.Metal)
end

-- High-end Future lighting + post FX (keeps Test 1 terrain).
local function applyHighEndGraphics()
	local Lighting = game:GetService("Lighting")
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
	Lighting.Brightness = 2.4
	Lighting.Ambient = Color3.fromRGB(70, 75, 90)
	Lighting.OutdoorAmbient = Color3.fromRGB(95, 105, 120)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 180)
	Lighting.ColorShift_Bottom = Color3.fromRGB(40, 50, 70)
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.2
	Lighting.ClockTime = 16.5
	Lighting.GeographicLatitude = 35
	Lighting.ExposureCompensation = 0.15

	local function ensure(className, name)
		local old = Lighting:FindFirstChild(name)
		if old then old:Destroy() end
		local fx = Instance.new(className)
		fx.Name = name
		fx.Parent = Lighting
		return fx
	end

	local atm = ensure("Atmosphere", "VillageAtmosphere")
	atm.Density = 0.28
	atm.Offset = 0.12
	atm.Color = Color3.fromRGB(180, 195, 210)
	atm.Decay = Color3.fromRGB(120, 130, 150)
	atm.Glare = 0.25
	atm.Haze = 1.4

	local bloom = ensure("BloomEffect", "VillageBloom")
	bloom.Intensity = 0.45
	bloom.Size = 28
	bloom.Threshold = 0.9

	local rays = ensure("SunRaysEffect", "VillageSunRays")
	rays.Intensity = 0.12
	rays.Spread = 0.7

	local cc = ensure("ColorCorrectionEffect", "VillageColor")
	cc.Brightness = 0.03
	cc.Contrast = 0.12
	cc.Saturation = 0.08
	cc.TintColor = Color3.fromRGB(255, 248, 240)

	local dof = ensure("DepthOfFieldEffect", "VillageDOF")
	dof.FarIntensity = 0.18
	dof.NearIntensity = 0.05
	dof.FocusDistance = 40
	dof.InFocusRadius = 35

	print("[Village] high-end Future lighting + atmosphere applied")
end

local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent

	-- Large cottage: ~48 x 36 footprint, tall walls, porch, loft feel
	local floor = part("Floor", Vector3.new(48, 1.4, 36), origin * CFrame.new(0, 0.8, 0), Color3.fromRGB(105, 78, 50), m, Enum.Material.WoodPlanks)
	m.PrimaryPart = floor
	part("Foundation", Vector3.new(50, 2.2, 38), origin * CFrame.new(0, -0.4, 0), Color3.fromRGB(108, 102, 95), m, Enum.Material.Limestone)
	part("WallB", Vector3.new(48, 16, 1.2), origin * CFrame.new(0, 9, 17.5), wall, m, Enum.Material.Brick)
	part("WallL", Vector3.new(1.2, 16, 36), origin * CFrame.new(-23.5, 9, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(1.2, 16, 36), origin * CFrame.new(23.5, 9, 0), wall, m, Enum.Material.Brick)
	part("WallF", Vector3.new(16, 16, 1.2), origin * CFrame.new(-15, 9, -17.5), wall, m, Enum.Material.Brick)
	part("WallF2", Vector3.new(16, 16, 1.2), origin * CFrame.new(15, 9, -17.5), wall, m, Enum.Material.Brick)
	part("Lintel", Vector3.new(14, 4, 1.2), origin * CFrame.new(0, 14, -17.5), wall, m, Enum.Material.Brick)
	part("Door", Vector3.new(10, 12, 0.5), origin * CFrame.new(0, 7, -17.5), Color3.fromRGB(42, 28, 18), m, Enum.Material.Wood)
	-- Interior divider (living / bedroom)
	part("Divider", Vector3.new(1, 14, 20), origin * CFrame.new(4, 8, 4), wall, m, Enum.Material.Brick)
	part("InnerDoor", Vector3.new(0.4, 9, 6), origin * CFrame.new(4, 5.2, -4), Color3.fromRGB(55, 36, 22), m, Enum.Material.Wood)
	wedge("RoofA", Vector3.new(24, 8, 44), origin * CFrame.new(-12.5, 20, 0) * CFrame.Angles(0, 0, 0.05), roof, m, Enum.Material.Slate)
	wedge("RoofB", Vector3.new(24, 8, 44), origin * CFrame.new(12.5, 20, 0) * CFrame.Angles(0, math.pi, 0.05), roof, m, Enum.Material.Slate)
	part("RoofRidge", Vector3.new(2, 1.2, 42), origin * CFrame.new(0, 23.5, 0), Color3.fromRGB(55, 50, 48), m, Enum.Material.Metal)

	-- Windows with frames
	for _, wx in ipairs({-18, -10, 10, 18}) do
		part("WinGlass", Vector3.new(4, 4.5, 0.25), origin * CFrame.new(wx, 9, -17.9), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
		part("WinFrame", Vector3.new(4.6, 5.1, 0.4), origin * CFrame.new(wx, 9, -17.7), Color3.fromRGB(60, 40, 25), m, Enum.Material.Wood)
	end
	for _, wz in ipairs({-10, 0, 10}) do
		part("SideWin", Vector3.new(0.25, 4, 3.5), origin * CFrame.new(-24, 9, wz), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
		part("SideWinR", Vector3.new(0.25, 4, 3.5), origin * CFrame.new(24, 9, wz), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
	end

	-- Porch
	part("Porch", Vector3.new(22, 1, 10), origin * CFrame.new(0, 0.6, -24), Color3.fromRGB(100, 74, 48), m, Enum.Material.WoodPlanks)
	part("PorchRail", Vector3.new(22, 1.2, 0.35), origin * CFrame.new(0, 2, -28.5), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("ColL", Vector3.new(1.2, 12, 1.2), origin * CFrame.new(-9, 7, -28), Color3.fromRGB(80, 58, 36), m, Enum.Material.Wood)
	part("ColR", Vector3.new(1.2, 12, 1.2), origin * CFrame.new(9, 7, -28), Color3.fromRGB(80, 58, 36), m, Enum.Material.Wood)
	wedge("PorchRoof", Vector3.new(12, 3, 14), origin * CFrame.new(0, 14, -24) * CFrame.Angles(0.15, 0, 0), roof, m, Enum.Material.Slate)

	-- Living room furniture (left / front)
	furnitureRug(m, origin * CFrame.new(-10, 1.55, -2), Color3.fromRGB(110, 40, 45))
	furnitureTable(m, origin * CFrame.new(-10, 0.8, -2))
	furnitureChair(m, origin * CFrame.new(-14, 0.8, -4))
	furnitureChair(m, origin * CFrame.new(-6, 0.8, -4))
	furnitureChair(m, origin * CFrame.new(-14, 0.8, 1) * CFrame.Angles(0, math.pi, 0))
	furnitureChair(m, origin * CFrame.new(-6, 0.8, 1) * CFrame.Angles(0, math.pi, 0))
	furnitureFireplace(m, origin * CFrame.new(-10, 0.8, 14))
	furnitureShelf(m, origin * CFrame.new(-20, 0.8, 6) * CFrame.Angles(0, math.pi / 2, 0))
	furnitureBarrel(m, origin * CFrame.new(-18, 0.8, -10))
	furnitureBarrel(m, origin * CFrame.new(-15, 0.8, -10))

	-- Bedroom (right side)
	furnitureBed(m, origin * CFrame.new(14, 0.8, 6))
	furnitureRug(m, origin * CFrame.new(14, 1.55, -6), Color3.fromRGB(50, 70, 110))
	part("Nightstand", Vector3.new(2.5, 2.2, 2.5), origin * CFrame.new(20, 1.9, 0), Color3.fromRGB(88, 60, 36), m, Enum.Material.Wood)
	local bedLamp = part("BedLamp", Vector3.new(0.8, 0.8, 0.8), origin * CFrame.new(20, 3.5, 0), Color3.fromRGB(255, 220, 150), m, Enum.Material.Neon)
	bedLamp.CanCollide = false
	lightOn(bedLamp, Vector3.new(), Color3.fromRGB(255, 210, 140), 12, 1.1)
	part("Wardrobe", Vector3.new(6, 10, 2.5), origin * CFrame.new(20, 6, 14), Color3.fromRGB(70, 48, 30), m, Enum.Material.Wood)
	part("WardrobeDoor", Vector3.new(2.6, 8, 0.3), origin * CFrame.new(18.5, 5.5, 12.6), Color3.fromRGB(85, 58, 35), m, Enum.Material.Wood)

	-- Ceiling beams + chandelier
	for i = -2, 2 do
		part("Beam" .. i, Vector3.new(44, 0.8, 0.8), origin * CFrame.new(0, 15.5, i * 5), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	end
	local chand = part("Chandelier", Vector3.new(2.5, 1.2, 2.5), origin * CFrame.new(-8, 14.5, -2), Color3.fromRGB(180, 150, 70), m, Enum.Material.Metal)
	chand.CanCollide = false
	lightOn(chand, Vector3.new(), Color3.fromRGB(255, 200, 120), 28, 2.4)
	local porchLamp = part("PorchLamp", Vector3.new(1.4, 1.4, 1.4), origin * CFrame.new(0, 8, -26), Color3.fromRGB(255, 200, 110), m, Enum.Material.Neon)
	porchLamp.CanCollide = false
	lightOn(porchLamp, Vector3.new(), Color3.fromRGB(255, 185, 100), 22, 1.8)

	return m
end

local function buildBase(parent, index, x, z, ignore)
	local origin, gy = at(x, z, ignore)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	-- Large player estate yard
	local yard = part("Yard", Vector3.new(90, 1.2, 80), origin * CFrame.new(0, 0.6, 0), Color3.fromRGB(72, 110, 58), m, Enum.Material.Grass)
	m.PrimaryPart = yard
	part("Path", Vector3.new(9, 0.4, 34), origin * CFrame.new(0, 1.3, -18), Color3.fromRGB(118, 108, 95), m, Enum.Material.Cobblestone)
	part("FenceL", Vector3.new(0.6, 4, 78), origin * CFrame.new(-44, 2.8, 0), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("FenceR", Vector3.new(0.6, 4, 78), origin * CFrame.new(44, 2.8, 0), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("FenceB", Vector3.new(90, 4, 0.6), origin * CFrame.new(0, 2.8, 38), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("GateL", Vector3.new(10, 4, 0.6), origin * CFrame.new(-10, 2.8, -38), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("GateR", Vector3.new(10, 4, 0.6), origin * CFrame.new(10, 2.8, -38), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)

	local houseOrigin = origin * CFrame.new(0, 1.2, 8)
	-- Big player house shell
	part("HouseFloor", Vector3.new(40, 1.3, 30), houseOrigin * CFrame.new(0, 0.65, 0), Color3.fromRGB(108, 82, 55), m, Enum.Material.WoodPlanks)
	part("HouseFound", Vector3.new(42, 2, 32), houseOrigin * CFrame.new(0, -0.5, 0), Color3.fromRGB(100, 96, 90), m, Enum.Material.Limestone)
	local wallC = Color3.fromRGB(168, 138, 108)
	part("HouseWallB", Vector3.new(40, 15, 1.2), houseOrigin * CFrame.new(0, 8.2, 14.6), wallC, m, Enum.Material.Brick)
	part("HouseWallL", Vector3.new(1.2, 15, 30), houseOrigin * CFrame.new(-19.6, 8.2, 0), wallC, m, Enum.Material.Brick)
	part("HouseWallR", Vector3.new(1.2, 15, 30), houseOrigin * CFrame.new(19.6, 8.2, 0), wallC, m, Enum.Material.Brick)
	part("HouseWallF", Vector3.new(13, 15, 1.2), houseOrigin * CFrame.new(-12.5, 8.2, -14.6), wallC, m, Enum.Material.Brick)
	part("HouseWallF2", Vector3.new(13, 15, 1.2), houseOrigin * CFrame.new(12.5, 8.2, -14.6), wallC, m, Enum.Material.Brick)
	part("HouseDoor", Vector3.new(10, 11, 0.5), houseOrigin * CFrame.new(0, 6.2, -14.6), Color3.fromRGB(48, 30, 18), m, Enum.Material.Wood)
	wedge("HouseRoofA", Vector3.new(20, 7, 36), houseOrigin * CFrame.new(-10.5, 18, 0) * CFrame.Angles(0, 0, 0.06), Color3.fromRGB(95, 45, 38), m, Enum.Material.Slate)
	wedge("HouseRoofB", Vector3.new(20, 7, 36), houseOrigin * CFrame.new(10.5, 18, 0) * CFrame.Angles(0, math.pi, 0.06), Color3.fromRGB(95, 45, 38), m, Enum.Material.Slate)
	for _, wx in ipairs({-12, 12}) do
		part("HWin", Vector3.new(3.5, 4, 0.25), houseOrigin * CFrame.new(wx, 8, -15), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
	end

	-- Furnished interior
	furnitureRug(m, houseOrigin * CFrame.new(-8, 1.4, -2), Color3.fromRGB(100, 40, 50))
	furnitureTable(m, houseOrigin * CFrame.new(-8, 0.7, -2))
	furnitureChair(m, houseOrigin * CFrame.new(-12, 0.7, -4))
	furnitureChair(m, houseOrigin * CFrame.new(-4, 0.7, -4))
	furnitureFireplace(m, houseOrigin * CFrame.new(-8, 0.7, 11))
	furnitureBed(m, houseOrigin * CFrame.new(10, 0.7, 4))
	furnitureShelf(m, houseOrigin * CFrame.new(16, 0.7, -6) * CFrame.Angles(0, -math.pi / 2, 0))
	furnitureBarrel(m, houseOrigin * CFrame.new(-15, 0.7, 8))
	local hLamp = part("HouseLamp", Vector3.new(1.6, 1.6, 1.6), houseOrigin * CFrame.new(-6, 13, -2), Color3.fromRGB(255, 215, 140), m, Enum.Material.Neon)
	hLamp.CanCollide = false
	lightOn(hLamp, Vector3.new(), Color3.fromRGB(255, 205, 130), 26, 2.2)

	-- Market stall in front
	part("Awning", Vector3.new(18, 0.45, 10), origin * CFrame.new(0, 9, -16), Color3.fromRGB(150, 45, 40), m, Enum.Material.Fabric)
	part("AwningPoleL", Vector3.new(0.55, 8.5, 0.55), origin * CFrame.new(-7, 4.8, -18), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("AwningPoleR", Vector3.new(0.55, 8.5, 0.55), origin * CFrame.new(7, 4.8, -18), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("Counter", Vector3.new(14, 1.4, 4.5), origin * CFrame.new(0, 2.1, -16), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	local bank = part("BankPad", Vector3.new(5.5, 1, 4), origin * CFrame.new(0, 3, -16), Color3.fromRGB(190, 160, 70), m, Enum.Material.Metal)
	sign(bank, "YOUR BASE · Q bank / R steal", Vector3.new(0, 5.5, 0), Color3.fromRGB(255, 220, 140))
	prompt(bank, "BankPrompt", "Your base stall", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 14)
	local stallLamp = part("StallLamp", Vector3.new(1.3, 1.3, 1.3), origin * CFrame.new(0, 8.2, -18), Color3.fromRGB(255, 200, 110), m, Enum.Material.Neon)
	stallLamp.CanCollide = false
	lightOn(stallLamp, Vector3.new(), Color3.fromRGB(255, 190, 100), 18, 1.7)

	local spawn = part("SpawnPad", Vector3.new(8, 0.5, 8), origin * CFrame.new(0, 1.4, -30), Color3.fromRGB(70, 140, 95), m, Enum.Material.Grass)
	sign(spawn, "SPAWN · BASE " .. index, Vector3.new(0, 4.5, 0), Color3.fromRGB(180, 255, 180))
	lantern(m, x - 14, gy, z - 22)
	lantern(m, x + 14, gy, z - 22)
	lantern(m, x - 14, gy, z + 20)
	lantern(m, x + 14, gy, z + 20)

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

local function watcher(parent, x, z, ignore)
	local origin, gy = at(x, z, ignore)
	local torso = part("Watcher", Vector3.new(2, 3, 1.1), origin * CFrame.new(0, 4, 0), Color3.fromRGB(16, 16, 20), parent, Enum.Material.SmoothPlastic)
	part("Head", Vector3.new(1.5, 1.5, 1.5), origin * CFrame.new(0, 6.3, 0), Color3.fromRGB(10, 10, 14), parent, Enum.Material.SmoothPlastic)
	part("EyeL", Vector3.new(0.3, 0.22, 0.2), origin * CFrame.new(-0.35, 6.4, -0.75), Color3.fromRGB(180, 30, 30), parent, Enum.Material.Neon).CanCollide = false
	part("EyeR", Vector3.new(0.3, 0.22, 0.2), origin * CFrame.new(0.35, 6.4, -0.75), Color3.fromRGB(180, 30, 30), parent, Enum.Material.Neon).CanCollide = false
	lightOn(torso, Vector3.new(0, 2, -1), Color3.fromRGB(120, 20, 20), 9, 0.55)
end


-- Wipe leftover Test 1 construction / prototype props across the play area.
-- Keeps Terrain, characters, cameras. Does not Terrain:Clear.
local function isCharacterModel(model)
	return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end

-- Destroy every place prop. Keep Terrain, Camera, characters.
-- Also specifically kill Baseplate / huge flat grey slabs (the grey area in Test 1).
local function clearAllPlaceJunk()
	local destroyed = 0

	local function kill(inst)
		if inst and inst.Parent then
			inst:Destroy()
			destroyed += 1
		end
	end

	-- Pass 1: top-level Workspace children
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Terrain") or child.Name == "Terrain" then
			-- keep hills
		elseif child:IsA("Camera") then
			-- keep
		elseif child.Name == "VillageBuild" then
			kill(child)
		elseif child:IsA("Model") and isCharacterModel(child) then
			-- keep player
		else
			kill(child)
		end
	end

	-- Pass 2: leftovers + any huge flat slab / Baseplate that survived nesting
	local leftovers = {}
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Terrain") or inst:IsA("Camera") then
			-- keep
		elseif inst:IsA("Model") then
			if not isCharacterModel(inst) then
				table.insert(leftovers, inst)
			end
		elseif inst:IsA("BasePart") then
			local parentModel = inst:FindFirstAncestorOfClass("Model")
			if isCharacterModel(parentModel) then
				-- keep
			else
				local n = string.lower(inst.Name)
				local hugeFlat = inst.Size.X >= 60 and inst.Size.Z >= 60 and inst.Size.Y <= 8
				local namedPlate = string.find(n, "baseplate", 1, true)
					or string.find(n, "spawnlocation", 1, true)
					or n == "baseplate"
					or n == "ground"
					or n == "plate"
				if hugeFlat or namedPlate then
					table.insert(leftovers, inst)
				else
					table.insert(leftovers, inst)
				end
			end
		elseif (inst:IsA("Folder") or inst:IsA("Configuration")) and inst.Parent == workspace then
			table.insert(leftovers, inst)
		end
	end
	table.sort(leftovers, function(a, b)
		return #(a:GetFullName()) > #(b:GetFullName())
	end)
	for _, inst in ipairs(leftovers) do
		kill(inst)
	end

	print("[Village] NUCLEAR junk wipe destroyed:", destroyed)
	return destroyed
end

-- Far, separated base spots on the hills (not clustered at the village heart).
local function pickBaseSpots()
	local rng = Random.new(20260919)
	local spots = {}
	local tries = 0
	while #spots < 4 and tries < 400 do
		tries += 1
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(240, 420)
		local x = math.cos(angle) * dist
		local z = math.sin(angle) * dist
		local farFromHub = math.abs(x) >= 120 or math.abs(z) >= 120
		if not farFromHub then
			-- too close to village heart
		else
			local ok = true
			for _, s in ipairs(spots) do
				local dx = s[1] - x
				local dz = s[2] - z
				if math.sqrt(dx * dx + dz * dz) < 280 then
					ok = false
					break
				end
			end
			if ok then
				table.insert(spots, { x, z })
			end
		end
	end
	if #spots < 4 then
		spots = {
			{ 320, 80 },
			{ -300, 140 },
			{ 260, -280 },
			{ -240, -300 },
		}
	end
	return spots
end


function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end

	-- Wipe the grey construction sandbox in the middle of Test 1
	clearAllPlaceJunk()
	applyHighEndGraphics()

	local root = Instance.new("Folder")
	root.Name = "VillageBuild"
	root.Parent = workspace
	local ignore = { root }

	-- Center: a real lived-in village house (not a construction pad)
	local hub, hubY = at(0, 0, ignore)
	local centerHome = house(root, "MillerHouse", hub, Color3.fromRGB(168, 140, 110), Color3.fromRGB(95, 55, 40))
	-- Garden / porch life so the center feels alive
	part("GardenBedL", Vector3.new(8, 1, 3), hub * CFrame.new(-14, 1.1, 12), Color3.fromRGB(70, 110, 55), root, Enum.Material.Grass)
	part("GardenBedR", Vector3.new(8, 1, 3), hub * CFrame.new(14, 1.1, 12), Color3.fromRGB(70, 110, 55), root, Enum.Material.Grass)
	part("FlowerA", Vector3.new(1.2, 1.6, 1.2), hub * CFrame.new(-14, 2.2, 12), Color3.fromRGB(220, 80, 120), root, Enum.Material.SmoothPlastic)
	part("FlowerB", Vector3.new(1.2, 1.6, 1.2), hub * CFrame.new(14, 2.2, 12), Color3.fromRGB(240, 200, 60), root, Enum.Material.SmoothPlastic)
	part("WellRing", Vector3.new(6, 2.2, 6), hub * CFrame.new(0, 1.5, 22), Color3.fromRGB(120, 120, 125), root, Enum.Material.Slate)
	part("WellWater", Vector3.new(4, 0.4, 4), hub * CFrame.new(0, 2.4, 22), Color3.fromRGB(60, 110, 160), root, Enum.Material.Glass)
	part("Bench", Vector3.new(7, 1.2, 2.2), hub * CFrame.new(12, 1.4, 20), Color3.fromRGB(100, 74, 48), root, Enum.Material.Wood)
	local board = part("NoticeBoard", Vector3.new(10, 8, 0.6), hub * CFrame.new(-16, 5, 20), Color3.fromRGB(70, 48, 28), root, Enum.Material.Wood)
	sign(board, "MILLBROOK · cook · bank 80 · survive the night", Vector3.new(0, 6, 0), Color3.fromRGB(255, 220, 140))
	sign(board, "MILLER HOUSE · village heart", Vector3.new(0, -5, 0), Color3.fromRGB(200, 230, 255))
	lantern(root, -18, hubY, -8)
	lantern(root, 18, hubY, -8)
	lantern(root, -10, hubY, 26)
	lantern(root, 10, hubY, 26)

	-- Short roads from hub (on terrain height near center)
	for _, xz in ipairs({
		{0, -40, 12, 0.5, 50}, {0, 40, 12, 0.5, 50},
		{-40, 0, 50, 0.5, 12}, {40, 0, 50, 0.5, 12},
	}) do
		local cf = select(1, at(xz[1], xz[2], ignore))
		part("Road", Vector3.new(xz[3], xz[4], xz[5]), cf * CFrame.new(0, 0.3, 0), Color3.fromRGB(92, 86, 78), root, Enum.Material.Cobblestone)
	end

	-- Shared buildings around center (ground-snapped)
	local chapelCF = select(1, at(0, -70, ignore))
	local chapel = Instance.new("Model")
	chapel.Name = "ChapelOfTheLastBell"
	chapel.Parent = root
	part("Nave", Vector3.new(22, 16, 32), chapelCF * CFrame.new(0, 9, -8), Color3.fromRGB(226, 220, 206), chapel, Enum.Material.Concrete)
	part("Tower", Vector3.new(9, 28, 9), chapelCF * CFrame.new(0, 16, -22), Color3.fromRGB(220, 216, 204), chapel, Enum.Material.Concrete)
	part("TowerRoof", Vector3.new(11, 1.5, 11), chapelCF * CFrame.new(0, 31, -22), Color3.fromRGB(55, 60, 68), chapel, Enum.Material.Slate)
	local bell = part("LastBell", Vector3.new(4, 4, 4), chapelCF * CFrame.new(0, 26, -22), Color3.fromRGB(220, 180, 60), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(255, 210, 100), 26, 2)
	part("Door", Vector3.new(7, 11, 1), chapelCF * CFrame.new(0, 6, 8), Color3.fromRGB(45, 28, 18), chapel, Enum.Material.Wood)
	for i = 0, 3 do
		part("Pew" .. i, Vector3.new(12, 2, 2), chapelCF * CFrame.new(0, 1.6, -i * 4), Color3.fromRGB(90, 60, 40), chapel, Enum.Material.Wood)
	end
	local altar = part("Altar", Vector3.new(9, 2.2, 4), chapelCF * CFrame.new(0, 1.8, -20), Color3.fromRGB(185, 165, 95), chapel, Enum.Material.Marble)
	lightOn(altar, Vector3.new(0, 1, 0), Color3.fromRGB(160, 30, 30), 16, 0.85)
	sign(altar, "CHAPEL · P rebirth at 80 coins", Vector3.new(0, 7, 0), Color3.fromRGB(255, 220, 160))
	prompt(altar, "RebirthPrompt", "Last Bell", "Rebirth", Enum.KeyCode.P, 16)

	local willowCF = select(1, at(-55, 10, ignore))
	local willow = house(root, "WillowHome", willowCF, Color3.fromRGB(118, 132, 100), Color3.fromRGB(65, 95, 55))
	local herbs = part("Herbs", Vector3.new(6, 1.4, 6), willowCF * CFrame.new(0, 1.4, -16), Color3.fromRGB(90, 165, 75), willow, Enum.Material.Grass)
	sign(herbs, "WILLOW · E gather herbs", Vector3.new(0, 6, 0), Color3.fromRGB(180, 255, 170))
	prompt(herbs, "HerbPrompt", "Herb garden", "Gather herbs", Enum.KeyCode.E, 15)

	local ashCF = select(1, at(55, 10, ignore))
	local ash = house(root, "AshCottage", ashCF, Color3.fromRGB(132, 100, 72), Color3.fromRGB(100, 58, 36))
	local wood = part("WoodStation", Vector3.new(5.5, 2.2, 4.5), ashCF * CFrame.new(0, 1.6, -16), Color3.fromRGB(110, 78, 48), ash, Enum.Material.WoodPlanks)
	sign(wood, "ASH · E chop wood", Vector3.new(0, 6, 0), Color3.fromRGB(255, 210, 150))
	prompt(wood, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 15)

	local innCF = select(1, at(0, 60, ignore))
	local inn = house(root, "LastBellInn", innCF, Color3.fromRGB(145, 95, 68), Color3.fromRGB(150, 48, 40))
	local kitchen = part("Kitchen", Vector3.new(7, 2.2, 7), innCF * CFrame.new(8, 2, 12), Color3.fromRGB(185, 125, 75), inn, Enum.Material.Wood)
	part("Stove", Vector3.new(3.5, 2.5, 2.5), innCF * CFrame.new(8, 2.4, 14), Color3.fromRGB(40, 40, 45), inn, Enum.Material.Metal)
	sign(kitchen, "INN · F cook meal", Vector3.new(0, 6, 0), Color3.fromRGB(255, 200, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 15)

	local reedCF = select(1, at(-50, -35, ignore))
	local reed = house(root, "ReedHouse", reedCF, Color3.fromRGB(176, 156, 110), Color3.fromRGB(145, 118, 55))
	local reedHerbs = part("ReedHerbs", Vector3.new(5, 1.3, 5), reedCF * CFrame.new(8, 1.3, -14), Color3.fromRGB(74, 118, 52), reed, Enum.Material.Grass)
	sign(reedHerbs, "REED · E extra herbs", Vector3.new(0, 6, 0), Color3.fromRGB(200, 230, 180))
	prompt(reedHerbs, "HerbPrompt", "River herbs", "Gather herbs", Enum.KeyCode.E, 14)

	local smithCF = select(1, at(50, -35, ignore))
	local smithy = house(root, "MillbrookSmithy", smithCF, Color3.fromRGB(95, 80, 70), Color3.fromRGB(70, 70, 74))
	local coals = part("Coals", Vector3.new(4, 0.7, 2.5), smithCF * CFrame.new(-6, 2.2, -14), Color3.fromRGB(255, 90, 30), smithy, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(255, 120, 40), 20, 1.8)
	local scrap = part("ScrapWood", Vector3.new(5, 2, 4), smithCF * CFrame.new(8, 1.6, -14), Color3.fromRGB(90, 70, 50), smithy, Enum.Material.WoodPlanks)
	sign(scrap, "SMITHY · E scrap wood", Vector3.new(0, 6, 0), Color3.fromRGB(255, 170, 90))
	prompt(scrap, "WoodPrompt", "Scrap wood", "Chop wood", Enum.KeyCode.E, 14)

	-- Player bases far apart on random hill spots (real ground snap)
	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	local spots = pickBaseSpots()
	for i, s in ipairs(spots) do
		print(string.format("[Village] Base %d at (%.0f, %.0f)", i, s[1], s[2]))
		buildBase(bases, i, s[1], s[2], ignore)
	end

	-- Horror props off the paths
	watcher(root, -30, -95, ignore)
	watcher(root, 30, -95, ignore)
	watcher(root, 0, 95, ignore)

	-- Small dirt path only (no big grey pad)
	part("FrontPath", Vector3.new(4, 0.25, 10), hub * CFrame.new(0, 0.35, 12), Color3.fromRGB(92, 78, 58), root, Enum.Material.Ground)

	print(string.format("[Village] VILLAGE-11 on Test 1 ground (hubY=%.1f)", hubY))
	return root
end

return World
