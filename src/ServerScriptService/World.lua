--!nocheck
-- VILLAGE-09: builds ON Test 1 terrain (raycast snap). No floating plateau.
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

local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	local floor = part("Floor", Vector3.new(28, 1.2, 22), origin * CFrame.new(0, 0.7, 0), Color3.fromRGB(98, 74, 48), m, Enum.Material.WoodPlanks)
	m.PrimaryPart = floor
	part("Foundation", Vector3.new(30, 1.8, 24), origin * CFrame.new(0, -0.2, 0), Color3.fromRGB(110, 105, 98), m, Enum.Material.Slate)
	part("WallB", Vector3.new(28, 12, 1), origin * CFrame.new(0, 7, 10.6), wall, m, Enum.Material.Brick)
	part("WallL", Vector3.new(1, 12, 22), origin * CFrame.new(-13.6, 7, 0), wall, m, Enum.Material.Brick)
	part("WallR", Vector3.new(1, 12, 22), origin * CFrame.new(13.6, 7, 0), wall, m, Enum.Material.Brick)
	part("WallF", Vector3.new(9, 12, 1), origin * CFrame.new(-9.5, 7, -10.6), wall, m, Enum.Material.Brick)
	part("WallF2", Vector3.new(9, 12, 1), origin * CFrame.new(9.5, 7, -10.6), wall, m, Enum.Material.Brick)
	part("Lintel", Vector3.new(10, 3, 1), origin * CFrame.new(0, 11.5, -10.6), wall, m, Enum.Material.Brick)
	part("Door", Vector3.new(8, 9.5, 0.4), origin * CFrame.new(0, 5.3, -10.6), Color3.fromRGB(42, 28, 18), m, Enum.Material.Wood)
	wedge("RoofA", Vector3.new(14, 5, 30), origin * CFrame.new(-7.5, 15, 0) * CFrame.Angles(0, 0, 0.06), roof, m, Enum.Material.Slate)
	wedge("RoofB", Vector3.new(14, 5, 30), origin * CFrame.new(7.5, 15, 0) * CFrame.Angles(0, math.pi, 0.06), roof, m, Enum.Material.Slate)
	part("Chimney", Vector3.new(2.6, 7, 2.6), origin * CFrame.new(9, 17.5, 6), Color3.fromRGB(88, 70, 60), m, Enum.Material.Brick)
	part("WindowL", Vector3.new(3, 3, 0.3), origin * CFrame.new(-8, 7.5, -11), Color3.fromRGB(170, 210, 220), m, Enum.Material.Glass)
	part("WindowR", Vector3.new(3, 3, 0.3), origin * CFrame.new(8, 7.5, -11), Color3.fromRGB(170, 210, 220), m, Enum.Material.Glass)
	part("Table", Vector3.new(7, 1, 3.5), origin * CFrame.new(-5, 2.4, 1), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	part("Bed", Vector3.new(6, 1.4, 10), origin * CFrame.new(8, 2.2, 1), Color3.fromRGB(120, 70, 80), m, Enum.Material.Fabric)
	part("Shelf", Vector3.new(7, 5, 1.1), origin * CFrame.new(-10, 5, 7), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	local fire = part("Fire", Vector3.new(2, 1, 1), origin * CFrame.new(9, 4.5, 8), Color3.fromRGB(255, 120, 40), m, Enum.Material.Neon)
	fire.CanCollide = false
	lightOn(fire, Vector3.new(0, 1, 0), Color3.fromRGB(255, 130, 50), 14, 1.3)
	local lamp = part("Lamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 10.5, 0), Color3.fromRGB(255, 215, 140), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.new(), Color3.fromRGB(255, 210, 140), 16, 1.4)
	part("Porch", Vector3.new(12, 0.8, 6), origin * CFrame.new(0, 0.5, -14), Color3.fromRGB(100, 74, 48), m, Enum.Material.WoodPlanks)
	local porchLamp = part("PorchLamp", Vector3.new(1.1, 1.1, 1.1), origin * CFrame.new(0, 5.5, -14), Color3.fromRGB(255, 200, 110), m, Enum.Material.Neon)
	porchLamp.CanCollide = false
	lightOn(porchLamp, Vector3.new(), Color3.fromRGB(255, 185, 100), 18, 1.6)
	return m
end

local function buildBase(parent, index, x, z, ignore)
	local origin, gy = at(x, z, ignore)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	-- Thin pad ON terrain (not a second world)
	local yard = part("Yard", Vector3.new(56, 1.2, 50), origin * CFrame.new(0, 0.6, 0), Color3.fromRGB(78, 108, 62), m, Enum.Material.Grass)
	m.PrimaryPart = yard
	part("Path", Vector3.new(7, 0.35, 22), origin * CFrame.new(0, 1.25, -14), Color3.fromRGB(118, 108, 95), m, Enum.Material.Cobblestone)
	part("FenceL", Vector3.new(0.5, 3.2, 48), origin * CFrame.new(-27, 2.4, 0), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("FenceR", Vector3.new(0.5, 3.2, 48), origin * CFrame.new(27, 2.4, 0), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)
	part("FenceB", Vector3.new(55, 3.2, 0.5), origin * CFrame.new(0, 2.4, 24), Color3.fromRGB(85, 65, 40), m, Enum.Material.Wood)

	local houseOrigin = origin * CFrame.new(0, 1.2, 4)
	part("HouseFloor", Vector3.new(24, 1.1, 18), houseOrigin * CFrame.new(0, 0.55, 0), Color3.fromRGB(105, 80, 55), m, Enum.Material.WoodPlanks)
	part("HouseFound", Vector3.new(26, 1.5, 20), houseOrigin * CFrame.new(0, -0.4, 0), Color3.fromRGB(100, 96, 90), m, Enum.Material.Slate)
	part("HouseWallB", Vector3.new(24, 11, 1), houseOrigin * CFrame.new(0, 6.2, 8.6), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallL", Vector3.new(1, 11, 18), houseOrigin * CFrame.new(-11.6, 6.2, 0), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallR", Vector3.new(1, 11, 18), houseOrigin * CFrame.new(11.6, 6.2, 0), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallF", Vector3.new(7, 11, 1), houseOrigin * CFrame.new(-8.5, 6.2, -8.6), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseWallF2", Vector3.new(7, 11, 1), houseOrigin * CFrame.new(8.5, 6.2, -8.6), Color3.fromRGB(155, 125, 95), m, Enum.Material.Brick)
	part("HouseDoor", Vector3.new(7, 9, 0.4), houseOrigin * CFrame.new(0, 5, -8.6), Color3.fromRGB(50, 32, 20), m, Enum.Material.Wood)
	wedge("HouseRoofA", Vector3.new(12, 4.5, 22), houseOrigin * CFrame.new(-6.5, 13.5, 0) * CFrame.Angles(0, 0, 0.08), Color3.fromRGB(100, 48, 38), m, Enum.Material.Slate)
	wedge("HouseRoofB", Vector3.new(12, 4.5, 22), houseOrigin * CFrame.new(6.5, 13.5, 0) * CFrame.Angles(0, math.pi, 0.08), Color3.fromRGB(100, 48, 38), m, Enum.Material.Slate)
	part("HouseBed", Vector3.new(5.5, 1.3, 9), houseOrigin * CFrame.new(6, 2, 1), Color3.fromRGB(80, 100, 140), m, Enum.Material.Fabric)
	part("HouseTable", Vector3.new(6, 1, 3), houseOrigin * CFrame.new(-5, 2, 0), Color3.fromRGB(110, 80, 50), m, Enum.Material.Wood)
	part("HouseChest", Vector3.new(3, 2.2, 2.4), houseOrigin * CFrame.new(-6, 2.2, 5), Color3.fromRGB(140, 100, 50), m, Enum.Material.Wood)
	local houseLamp = part("HouseLamp", Vector3.new(1.1, 1.1, 1.1), houseOrigin * CFrame.new(0, 9.5, 0), Color3.fromRGB(255, 215, 140), m, Enum.Material.Neon)
	houseLamp.CanCollide = false
	lightOn(houseLamp, Vector3.new(), Color3.fromRGB(255, 210, 140), 14, 1.4)

	part("Awning", Vector3.new(14, 0.4, 8), origin * CFrame.new(0, 8, -12), Color3.fromRGB(150, 45, 40), m, Enum.Material.Fabric)
	part("AwningPoleL", Vector3.new(0.5, 7.5, 0.5), origin * CFrame.new(-5.5, 4.3, -14), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("AwningPoleR", Vector3.new(0.5, 7.5, 0.5), origin * CFrame.new(5.5, 4.3, -14), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("Counter", Vector3.new(12, 1.3, 4), origin * CFrame.new(0, 2, -12), Color3.fromRGB(120, 86, 52), m, Enum.Material.Wood)
	local bank = part("BankPad", Vector3.new(5, 1, 4), origin * CFrame.new(0, 2.8, -12), Color3.fromRGB(190, 160, 70), m, Enum.Material.Metal)
	sign(bank, "YOUR BASE · Q bank / R steal", Vector3.new(0, 5.5, 0), Color3.fromRGB(255, 220, 140))
	prompt(bank, "BankPrompt", "Your base stall", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 14)
	local stallLamp = part("StallLamp", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(0, 7.4, -14), Color3.fromRGB(255, 200, 110), m, Enum.Material.Neon)
	stallLamp.CanCollide = false
	lightOn(stallLamp, Vector3.new(), Color3.fromRGB(255, 190, 100), 16, 1.6)

	-- Spawn clearly above yard surface
	local spawn = part("SpawnPad", Vector3.new(7, 0.5, 7), origin * CFrame.new(0, 1.4, -20), Color3.fromRGB(70, 140, 95), m, Enum.Material.Grass)
	sign(spawn, "SPAWN · BASE " .. index, Vector3.new(0, 4.5, 0), Color3.fromRGB(180, 255, 180))
	lantern(m, x - 10, gy, z - 16)
	lantern(m, x + 10, gy, z - 16)

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

-- Nuclear wipe: every place prop/model/folder in Workspace except Terrain, Camera, characters.
-- Radius clears missed the yard; user asked to remove EVERY junk part.
local function clearAllPlaceJunk()
	local destroyed = 0

	-- Pass 1: top-level Workspace children
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Terrain") or child.Name == "Terrain" then
			-- keep hills / map
		elseif child:IsA("Camera") then
			-- keep
		elseif child.Name == "VillageBuild" then
			child:Destroy()
			destroyed += 1
		elseif child:IsA("Model") and isCharacterModel(child) then
			-- keep player
		else
			child:Destroy()
			destroyed += 1
		end
	end

	-- Pass 2: any leftover BaseParts / Models still hanging under Workspace
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
			if not isCharacterModel(parentModel) then
				table.insert(leftovers, inst)
			end
		elseif inst:IsA("Folder") or inst:IsA("Configuration") or inst:IsA("Attachment") then
			-- folders of leftover FX / attachments under workspace (not under character)
			local parentModel = inst:FindFirstAncestorOfClass("Model")
			if not isCharacterModel(parentModel) and inst.Parent == workspace then
				table.insert(leftovers, inst)
			end
		end
	end
	table.sort(leftovers, function(a, b)
		return #(a:GetFullName()) > #(b:GetFullName())
	end)
	for _, inst in ipairs(leftovers) do
		if inst.Parent then
			inst:Destroy()
			destroyed += 1
		end
	end

	print("[Village] NUCLEAR junk wipe destroyed:", destroyed)
	return destroyed
end


function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end

	-- Wipe the grey construction sandbox in the middle of Test 1
	clearAllPlaceJunk()

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

	-- Player bases around the middle construction ring (on real ground)
	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	-- Farther out on the hills so bases are not inside the old yard
	local spots = {
		{ 105, 55 },
		{ -105, 55 },
		{ 105, -55 },
		{ -105, -55 },
	}
	for i, s in ipairs(spots) do
		buildBase(bases, i, s[1], s[2], ignore)
	end

	-- Horror props off the paths
	watcher(root, -30, -95, ignore)
	watcher(root, 30, -95, ignore)
	watcher(root, 0, 95, ignore)

	-- Fallback plaza marker at hub
	part("FrontPath", Vector3.new(6, 0.35, 14), hub * CFrame.new(0, 0.45, 14), Color3.fromRGB(118, 108, 95), root, Enum.Material.Cobblestone)

	print(string.format("[Village] VILLAGE-09 on Test 1 ground (hubY=%.1f)", hubY))
	return root
end

return World
