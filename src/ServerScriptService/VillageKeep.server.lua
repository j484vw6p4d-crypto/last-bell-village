--!nocheck
print("[Village] V2 starting — no Terrain:Clear")

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

pcall(function()
	workspace.StreamingEnabled = false
end)

local FLOOR_Y = 2
local PLAZA = 108

local function keep(inst)
	if inst:IsA("Camera") or inst:IsA("Terrain") then
		return true
	end
	if inst.Name == "Village" then
		return true
	end
	if Players:GetPlayerFromCharacter(inst) then
		return true
	end
	return false
end

local function inPlaza(p: Vector3)
	return math.abs(p.X) < PLAZA and math.abs(p.Z) < PLAZA
end

-- Remove the middle maintenance blockout only. Mountains are Terrain and stay.
for _, child in ipairs(workspace:GetChildren()) do
	if keep(child) then
		continue
	end
	local hit = false
	if child:IsA("BasePart") and inPlaza(child.Position) then
		hit = true
	else
		for _, d in ipairs(child:GetDescendants()) do
			if d:IsA("BasePart") and inPlaza(d.Position) then
				hit = true
				break
			end
		end
	end
	if hit then
		pcall(function()
			child:Destroy()
		end)
	end
end

local old = workspace:FindFirstChild("Village")
if old then
	old:Destroy()
end

local village = Instance.new("Folder")
village.Name = "Village"
village.Parent = workspace

local function part(name, size, cf, color, parent, mat)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Wood
	p.Anchored = true
	p.CanCollide = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function wedge(name, size, cf, color, parent, mat)
	local w = Instance.new("WedgePart")
	w.Name = name
	w.Size = size
	w.CFrame = cf
	w.Color = color
	w.Material = mat or Enum.Material.Slate
	w.Anchored = true
	w.CanCollide = true
	w.Parent = parent
	return w
end

local function glow(p, range, bright, color)
	local l = Instance.new("PointLight")
	l.Range = range
	l.Brightness = bright
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Parent = p
end

local function sign(adornee, text, offset, color)
	local bill = Instance.new("BillboardGui")
	bill.Name = "Sign"
	bill.Size = UDim2.fromOffset(280, 40)
	bill.StudsOffset = offset
	bill.AlwaysOnTop = true
	bill.MaxDistance = 160
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 236, 200)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = bill
end

-- plaza + roads (covers leftover pads if a few survive)
part("Plaza", Vector3.new(200, 2, 200), CFrame.new(0, FLOOR_Y, 0), Color3.fromRGB(118, 112, 104), village, Enum.Material.Cobblestone)
part("GreenRing", Vector3.new(196, 0.4, 196), CFrame.new(0, FLOOR_Y + 1.15, 0), Color3.fromRGB(72, 98, 58), village, Enum.Material.Grass).CanCollide = false
part("RoadN", Vector3.new(16, 0.5, 180), CFrame.new(0, FLOOR_Y + 1.2, 0), Color3.fromRGB(92, 86, 78), village, Enum.Material.Cobblestone)
part("RoadE", Vector3.new(180, 0.5, 16), CFrame.new(0, FLOOR_Y + 1.2, 0), Color3.fromRGB(92, 86, 78), village, Enum.Material.Cobblestone)
part("Square", Vector3.new(42, 0.55, 42), CFrame.new(0, FLOOR_Y + 1.25, 0), Color3.fromRGB(132, 124, 112), village, Enum.Material.Cobblestone)

local well = part("Well", Vector3.new(8, 4, 8), CFrame.new(0, FLOOR_Y + 3.4, 0), Color3.fromRGB(96, 96, 100), village, Enum.Material.Slate)
part("WellWater", Vector3.new(5.2, 0.6, 5.2), CFrame.new(0, FLOOR_Y + 4.4, 0), Color3.fromRGB(40, 90, 130), village, Enum.Material.Glass)
part("WellRoof", Vector3.new(10, 0.6, 10), CFrame.new(0, FLOOR_Y + 9.2, 0), Color3.fromRGB(96, 52, 36), village, Enum.Material.Wood)
part("WellPostL", Vector3.new(0.7, 6, 0.7), CFrame.new(-3.4, FLOOR_Y + 6.4, 0), Color3.fromRGB(70, 48, 30), village, Enum.Material.Wood)
part("WellPostR", Vector3.new(0.7, 6, 0.7), CFrame.new(3.4, FLOOR_Y + 6.4, 0), Color3.fromRGB(70, 48, 30), village, Enum.Material.Wood)
sign(well, "MILLBROOK SQUARE", Vector3.new(0, 8, 0), Color3.fromRGB(255, 230, 170))

local function lamp(pos)
	local post = part("LampPost", Vector3.new(0.7, 10, 0.7), CFrame.new(pos.X, FLOOR_Y + 6.2, pos.Z), Color3.fromRGB(48, 44, 40), village, Enum.Material.Metal)
	local head = part("Lamp", Vector3.new(1.6, 1.6, 1.6), CFrame.new(pos.X, FLOOR_Y + 11.4, pos.Z), Color3.fromRGB(255, 210, 130), village, Enum.Material.Neon)
	head.CanCollide = false
	glow(head, 28, 1.4)
	return post
end

for _, p in ipairs({
	Vector3.new(18, 0, 18),
	Vector3.new(-18, 0, 18),
	Vector3.new(18, 0, -18),
	Vector3.new(-18, 0, -18),
	Vector3.new(55, 0, 8),
	Vector3.new(-55, 0, 8),
	Vector3.new(8, 0, 55),
	Vector3.new(8, 0, -55),
}) do
	lamp(p)
end

local function fenceRun(x0, z0, x1, z1)
	local a = Vector3.new(x0, FLOOR_Y + 2.6, z0)
	local b = Vector3.new(x1, FLOOR_Y + 2.6, z1)
	local mid = (a + b) * 0.5
	local len = (b - a).Magnitude
	part("Fence", Vector3.new(math.max(len, 0.6), 2.2, 0.4), CFrame.lookAt(mid, b), Color3.fromRGB(78, 56, 36), village, Enum.Material.Wood)
end

fenceRun(-90, -90, 90, -90)
fenceRun(-90, 90, 90, 90)
fenceRun(-90, -90, -90, 90)
fenceRun(90, -90, 90, 90)

local function planter(pos)
	part("Box", Vector3.new(6, 1.2, 6), CFrame.new(pos.X, FLOOR_Y + 1.9, pos.Z), Color3.fromRGB(86, 58, 34), village, Enum.Material.Wood)
	part("Flowers", Vector3.new(5.2, 1.4, 5.2), CFrame.new(pos.X, FLOOR_Y + 3.1, pos.Z), Color3.fromRGB(170, 70, 90), village, Enum.Material.Grass).CanCollide = false
end

planter(Vector3.new(22, 0, -8))
planter(Vector3.new(-22, 0, -8))
planter(Vector3.new(22, 0, 8))
planter(Vector3.new(-22, 0, 8))

local function tree(pos)
	part("Trunk", Vector3.new(2.2, 10, 2.2), CFrame.new(pos.X, FLOOR_Y + 6.2, pos.Z), Color3.fromRGB(72, 50, 32), village, Enum.Material.Wood)
	part("Canopy", Vector3.new(10, 8, 10), CFrame.new(pos.X, FLOOR_Y + 13, pos.Z), Color3.fromRGB(46, 92, 48), village, Enum.Material.Grass)
end

for _, t in ipairs({
	Vector3.new(-78, 0, -40),
	Vector3.new(-78, 0, 40),
	Vector3.new(78, 0, -40),
	Vector3.new(78, 0, 40),
	Vector3.new(-40, 0, -78),
	Vector3.new(40, 0, -78),
	Vector3.new(-40, 0, 78),
	Vector3.new(40, 0, 78),
}) do
	tree(t)
end

local function furnitureCottage(model, look)
	part("Table", Vector3.new(6, 1.2, 4), look * CFrame.new(0, 2.4, 1), Color3.fromRGB(120, 84, 52), model, Enum.Material.Wood)
	part("ChairA", Vector3.new(1.6, 2.2, 1.6), look * CFrame.new(-2.2, 2.4, -2.2), Color3.fromRGB(96, 68, 42), model, Enum.Material.Wood)
	part("ChairB", Vector3.new(1.6, 2.2, 1.6), look * CFrame.new(2.2, 2.4, -2.2), Color3.fromRGB(96, 68, 42), model, Enum.Material.Wood)
	part("Bed", Vector3.new(6.4, 1.4, 3.4), look * CFrame.new(-6.4, 2.1, 4.2), Color3.fromRGB(150, 70, 70), model, Enum.Material.Fabric)
	part("Pillow", Vector3.new(2.2, 0.6, 2.4), look * CFrame.new(-7.8, 2.9, 4.2), Color3.fromRGB(230, 220, 210), model, Enum.Material.Fabric)
	local hearth = part("Hearth", Vector3.new(4, 4.4, 1.4), look * CFrame.new(6.5, 3.6, 6.6), Color3.fromRGB(70, 70, 74), model, Enum.Material.Brick)
	local fire = part("Fire", Vector3.new(2.2, 2.2, 0.6), look * CFrame.new(6.5, 3.2, 5.8), Color3.fromRGB(255, 140, 50), model, Enum.Material.Neon)
	fire.CanCollide = false
	glow(fire, 16, 1.1, Color3.fromRGB(255, 150, 70))
	part("Shelf", Vector3.new(8, 0.4, 1.2), look * CFrame.new(0, 7.4, 6.4), Color3.fromRGB(88, 60, 38), model, Enum.Material.Wood)
	return hearth
end

local function house(name, pos, yaw, size, wall, roofCol, plaster)
	local look = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
	look = CFrame.new(look.Position, look.Position + Vector3.new(-math.sin(yaw), 0, -math.cos(yaw)))
	look = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = village
	local sx, sz = size.X, size.Z
	local fl = part("Floor", Vector3.new(sx, 1.2, sz), look * CFrame.new(0, FLOOR_Y + 1.7, 0), Color3.fromRGB(92, 64, 42), m, Enum.Material.Wood)
	m.PrimaryPart = fl
	-- walls with a door gap on +Z (front)
	part("WallL", Vector3.new(0.8, 11, sz), look * CFrame.new(-sx / 2 + 0.4, FLOOR_Y + 7.2, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(0.8, 11, sz), look * CFrame.new(sx / 2 - 0.4, FLOOR_Y + 7.2, 0), wall, m, Enum.Material.Brick)
	part("WallBack", Vector3.new(sx, 11, 0.8), look * CFrame.new(0, FLOOR_Y + 7.2, -sz / 2 + 0.4), wall, m, Enum.Material.Brick)
	part("WallFrontL", Vector3.new(sx * 0.38, 11, 0.8), look * CFrame.new(-sx * 0.31, FLOOR_Y + 7.2, sz / 2 - 0.4), wall, m, Enum.Material.Brick)
	part("WallFrontR", Vector3.new(sx * 0.38, 11, 0.8), look * CFrame.new(sx * 0.31, FLOOR_Y + 7.2, sz / 2 - 0.4), wall, m, Enum.Material.Brick)
	part("Lintel", Vector3.new(sx * 0.28, 3.2, 0.8), look * CFrame.new(0, FLOOR_Y + 11, sz / 2 - 0.4), wall, m, Enum.Material.Brick)
	part("Plaster", Vector3.new(sx - 1.6, 8, sz - 1.6), look * CFrame.new(0, FLOOR_Y + 6.4, 0), plaster, m, Enum.Material.SmoothPlastic).CanCollide = false
	part("RoofA", Vector3.new(sx + 3, 1.2, sz + 3), look * CFrame.new(0, FLOOR_Y + 13.6, 0) * CFrame.Angles(0.18, 0, 0), roofCol, m, Enum.Material.Slate)
	wedge("GableL", Vector3.new(sz + 1, 5, sx * 0.2), look * CFrame.new(-sx * 0.4, FLOOR_Y + 16, 0) * CFrame.Angles(0, math.pi / 2, 0), roofCol, m, Enum.Material.Slate)
	wedge("GableR", Vector3.new(sz + 1, 5, sx * 0.2), look * CFrame.new(sx * 0.4, FLOOR_Y + 16, 0) * CFrame.Angles(0, -math.pi / 2, 0), roofCol, m, Enum.Material.Slate)
	local winL = part("WindowL", Vector3.new(3.2, 3.2, 0.3), look * CFrame.new(-sx * 0.28, FLOOR_Y + 7.6, sz / 2 + 0.1), Color3.fromRGB(160, 210, 230), m, Enum.Material.Glass)
	winL.Transparency = 0.35
	winL.CanCollide = false
	local winR = part("WindowR", Vector3.new(3.2, 3.2, 0.3), look * CFrame.new(sx * 0.28, FLOOR_Y + 7.6, sz / 2 + 0.1), Color3.fromRGB(160, 210, 230), m, Enum.Material.Glass)
	winR.Transparency = 0.35
	winR.CanCollide = false
	furnitureCottage(m, look * CFrame.new(0, FLOOR_Y, 0))
	sign(fl, name, Vector3.new(0, 16, 0))
	return m
end

house("Ash Cottage", Vector3.new(-52, 0, -42), math.rad(40), Vector3.new(26, 0, 20), Color3.fromRGB(150, 118, 92), Color3.fromRGB(128, 58, 42), Color3.fromRGB(214, 200, 176))
house("Reed House", Vector3.new(54, 0, -40), math.rad(-40), Vector3.new(24, 0, 18), Color3.fromRGB(112, 92, 78), Color3.fromRGB(62, 70, 78), Color3.fromRGB(206, 198, 186))
house("Willow Home", Vector3.new(-50, 0, 46), math.rad(140), Vector3.new(24, 0, 18), Color3.fromRGB(138, 104, 80), Color3.fromRGB(118, 54, 40), Color3.fromRGB(220, 208, 184))

-- Inn
do
	local look = CFrame.new(Vector3.new(0, 0, 58)) * CFrame.Angles(0, math.pi, 0)
	local m = Instance.new("Model")
	m.Name = "The Last Bell Inn"
	m.Parent = village
	local fl = part("Floor", Vector3.new(36, 1.4, 24), look * CFrame.new(0, FLOOR_Y + 1.8, 0), Color3.fromRGB(86, 58, 36), m, Enum.Material.Wood)
	m.PrimaryPart = fl
	part("WallL", Vector3.new(0.9, 14, 24), look * CFrame.new(-17.5, FLOOR_Y + 8.6, 0), Color3.fromRGB(120, 78, 52), m, Enum.Material.Brick)
	part("WallR", Vector3.new(0.9, 14, 24), look * CFrame.new(17.5, FLOOR_Y + 8.6, 0), Color3.fromRGB(120, 78, 52), m, Enum.Material.Brick)
	part("WallBack", Vector3.new(36, 14, 0.9), look * CFrame.new(0, FLOOR_Y + 8.6, -11.5), Color3.fromRGB(120, 78, 52), m, Enum.Material.Brick)
	part("WallFL", Vector3.new(13, 14, 0.9), look * CFrame.new(-11.5, FLOOR_Y + 8.6, 11.5), Color3.fromRGB(120, 78, 52), m, Enum.Material.Brick)
	part("WallFR", Vector3.new(13, 14, 0.9), look * CFrame.new(11.5, FLOOR_Y + 8.6, 11.5), Color3.fromRGB(120, 78, 52), m, Enum.Material.Brick)
	part("Lintel", Vector3.new(10, 4, 0.9), look * CFrame.new(0, FLOOR_Y + 13.4, 11.5), Color3.fromRGB(120, 78, 52), m, Enum.Material.Brick)
	part("Roof", Vector3.new(40, 1.4, 28), look * CFrame.new(0, FLOOR_Y + 16.6, 0) * CFrame.Angles(0.1, 0, 0), Color3.fromRGB(86, 40, 32), m, Enum.Material.Slate)
	part("Bar", Vector3.new(18, 3.2, 2.4), look * CFrame.new(0, FLOOR_Y + 3.6, -6), Color3.fromRGB(110, 74, 44), m, Enum.Material.Wood)
	for i = -2, 2 do
		part("Stool" .. i, Vector3.new(1.6, 2.2, 1.6), look * CFrame.new(i * 3.2, FLOOR_Y + 3.2, -3.2), Color3.fromRGB(78, 52, 32), m, Enum.Material.Wood)
	end
	part("Hearth", Vector3.new(6, 6, 1.6), look * CFrame.new(-12, FLOOR_Y + 5.2, -9), Color3.fromRGB(70, 68, 72), m, Enum.Material.Brick)
	local fire = part("Fire", Vector3.new(3.4, 3, 0.6), look * CFrame.new(-12, FLOOR_Y + 4.6, -8), Color3.fromRGB(255, 130, 40), m, Enum.Material.Neon)
	fire.CanCollide = false
	glow(fire, 22, 1.5, Color3.fromRGB(255, 140, 60))
	part("Table1", Vector3.new(7, 1.2, 4), look * CFrame.new(10, FLOOR_Y + 3.2, 2), Color3.fromRGB(118, 82, 50), m, Enum.Material.Wood)
	sign(fl, "THE LAST BELL INN", Vector3.new(0, 18, 0), Color3.fromRGB(255, 214, 140))
end

-- Chapel / bell
do
	local look = CFrame.new(Vector3.new(0, 0, -60))
	local m = Instance.new("Model")
	m.Name = "Chapel"
	m.Parent = village
	local fl = part("Floor", Vector3.new(22, 1.4, 30), look * CFrame.new(0, FLOOR_Y + 1.8, 0), Color3.fromRGB(150, 148, 144), m, Enum.Material.Marble)
	m.PrimaryPart = fl
	part("WallL", Vector3.new(0.9, 16, 30), look * CFrame.new(-10.5, FLOOR_Y + 9.4, 0), Color3.fromRGB(168, 164, 156), m, Enum.Material.Limestone)
	part("WallR", Vector3.new(0.9, 16, 30), look * CFrame.new(10.5, FLOOR_Y + 9.4, 0), Color3.fromRGB(168, 164, 156), m, Enum.Material.Limestone)
	part("WallBack", Vector3.new(22, 16, 0.9), look * CFrame.new(0, FLOOR_Y + 9.4, -14.5), Color3.fromRGB(168, 164, 156), m, Enum.Material.Limestone)
	part("WallFL", Vector3.new(8, 16, 0.9), look * CFrame.new(-7, FLOOR_Y + 9.4, 14.5), Color3.fromRGB(168, 164, 156), m, Enum.Material.Limestone)
	part("WallFR", Vector3.new(8, 16, 0.9), look * CFrame.new(7, FLOOR_Y + 9.4, 14.5), Color3.fromRGB(168, 164, 156), m, Enum.Material.Limestone)
	part("Lintel", Vector3.new(6, 5, 0.9), look * CFrame.new(0, FLOOR_Y + 14.8, 14.5), Color3.fromRGB(168, 164, 156), m, Enum.Material.Limestone)
	part("Roof", Vector3.new(26, 1.4, 34), look * CFrame.new(0, FLOOR_Y + 18.4, 0), Color3.fromRGB(58, 62, 72), m, Enum.Material.Slate)
	part("Tower", Vector3.new(8, 22, 8), look * CFrame.new(0, FLOOR_Y + 22, -10), Color3.fromRGB(160, 156, 148), m, Enum.Material.Limestone)
	local bell = part("Bell", Vector3.new(4.4, 3.6, 4.4), look * CFrame.new(0, FLOOR_Y + 34, -10), Color3.fromRGB(212, 168, 64), m, Enum.Material.Metal)
	glow(bell, 24, 1.2, Color3.fromRGB(255, 210, 120))
	part("PewsL", Vector3.new(6, 2, 14), look * CFrame.new(-5, FLOOR_Y + 3, 0), Color3.fromRGB(92, 64, 40), m, Enum.Material.Wood)
	part("PewsR", Vector3.new(6, 2, 14), look * CFrame.new(5, FLOOR_Y + 3, 0), Color3.fromRGB(92, 64, 40), m, Enum.Material.Wood)
	sign(bell, "CHAPEL OF THE LAST BELL", Vector3.new(0, 6, 0), Color3.fromRGB(255, 226, 150))
end

-- Blacksmith
do
	local look = CFrame.new(Vector3.new(58, 0, 40)) * CFrame.Angles(0, math.rad(-120), 0)
	local m = Instance.new("Model")
	m.Name = "Blacksmith"
	m.Parent = village
	local fl = part("Floor", Vector3.new(22, 1.2, 18), look * CFrame.new(0, FLOOR_Y + 1.7, 0), Color3.fromRGB(70, 68, 66), m, Enum.Material.Slate)
	m.PrimaryPart = fl
	part("WallL", Vector3.new(0.8, 10, 18), look * CFrame.new(-10.6, FLOOR_Y + 6.6, 0), Color3.fromRGB(84, 84, 88), m, Enum.Material.Brick)
	part("WallR", Vector3.new(0.8, 10, 18), look * CFrame.new(10.6, FLOOR_Y + 6.6, 0), Color3.fromRGB(84, 84, 88), m, Enum.Material.Brick)
	part("WallBack", Vector3.new(22, 10, 0.8), look * CFrame.new(0, FLOOR_Y + 6.6, -8.6), Color3.fromRGB(84, 84, 88), m, Enum.Material.Brick)
	part("Roof", Vector3.new(24, 1, 20), look * CFrame.new(0, FLOOR_Y + 12.2, 0), Color3.fromRGB(52, 52, 56), m, Enum.Material.Metal)
	part("Anvil", Vector3.new(4, 2.4, 2.4), look * CFrame.new(-3, FLOOR_Y + 3.2, 2), Color3.fromRGB(40, 40, 44), m, Enum.Material.Metal)
	local forge = part("Forge", Vector3.new(6, 4, 4), look * CFrame.new(5, FLOOR_Y + 4, -4), Color3.fromRGB(90, 50, 40), m, Enum.Material.Brick)
	local coals = part("Coals", Vector3.new(3.4, 1.4, 2.4), look * CFrame.new(5, FLOOR_Y + 5.4, -4), Color3.fromRGB(255, 90, 30), m, Enum.Material.Neon)
	coals.CanCollide = false
	glow(coals, 18, 2, Color3.fromRGB(255, 100, 40))
	sign(fl, "MILLBROOK SMITHY", Vector3.new(0, 14, 0), Color3.fromRGB(255, 190, 140))
end

-- Market stalls
for i, off in ipairs({
	CFrame.new(-28, 0, 22) * CFrame.Angles(0, 0.4, 0),
	CFrame.new(-36, 0, 32) * CFrame.Angles(0, 0.2, 0),
	CFrame.new(30, 0, 24) * CFrame.Angles(0, -0.5, 0),
}) do
	local look = off
	local m = Instance.new("Model")
	m.Name = "Stall_" .. i
	m.Parent = village
	part("Floor", Vector3.new(12, 1, 10), look * CFrame.new(0, FLOOR_Y + 1.6, 0), Color3.fromRGB(96, 70, 44), m, Enum.Material.Wood)
	part("Back", Vector3.new(12, 7, 0.6), look * CFrame.new(0, FLOOR_Y + 5.2, -4.6), Color3.fromRGB(110, 78, 48), m, Enum.Material.Wood)
	part("Roof", Vector3.new(13, 0.5, 11), look * CFrame.new(0, FLOOR_Y + 9, 0) * CFrame.Angles(0.12, 0, 0), Color3.fromRGB(160, 64, 48), m, Enum.Material.Fabric)
	part("Counter", Vector3.new(10, 2, 1.8), look * CFrame.new(0, FLOOR_Y + 2.8, 3.4), Color3.fromRGB(122, 86, 52), m, Enum.Material.Wood)
	part("CrateA", Vector3.new(2.4, 2.2, 2.4), look * CFrame.new(-2.6, FLOOR_Y + 3.2, 0.4), Color3.fromRGB(150, 108, 64), m, Enum.Material.Wood)
	part("CrateB", Vector3.new(2.4, 2.2, 2.4), look * CFrame.new(2.4, FLOOR_Y + 3.2, 0.4), Color3.fromRGB(140, 96, 54), m, Enum.Material.Wood)
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "VillageSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, FLOOR_Y + 2.2, 16)
spawn.Anchored = true
spawn.Duration = 0
spawn.Neutral = true
spawn.Transparency = 0.35
spawn.BrickColor = BrickColor.new("Bright orange")
spawn.Parent = village

Lighting.ClockTime = 16.8
Lighting.Brightness = 2.1
Lighting.Ambient = Color3.fromRGB(80, 74, 66)
Lighting.OutdoorAmbient = Color3.fromRGB(120, 112, 98)
Lighting.FogStart = 60
Lighting.FogEnd = 420
Lighting.FogColor = Color3.fromRGB(150, 160, 170)

print("[Village] V2 Millbrook square ready")
