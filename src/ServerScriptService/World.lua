--!nocheck
-- VILLAGE-18: one enterable country shed with porch. No harvest/steal/bases.
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

local function lightOn(parent, offset, color, range, brightness)
	local a = Instance.new("Attachment")
	a.Position = offset or Vector3.zero
	a.Parent = parent
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(255, 200, 120)
	l.Brightness = brightness or 1.4
	l.Range = range or 18
	l.Shadows = true
	l.Parent = a
	return l
end

local function sign(adornee, text, offset)
	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.fromOffset(220, 36)
	bill.StudsOffset = offset or Vector3.new(0, 5, 0)
	bill.AlwaysOnTop = false
	bill.MaxDistance = 100
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 0.3
	t.BackgroundColor3 = Color3.fromRGB(30, 22, 14)
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 230, 180)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = bill
end

local function groundY(x, z, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore or {}
	params.IgnoreWater = true
	local hit = workspace:Raycast(Vector3.new(x, 1200, z), Vector3.new(0, -3000, 0), params)
	if hit then
		return hit.Position.Y
	end
	return 4
end

local function clearJunk()
	-- Nuclear wipe of place junk (keeps Terrain, Camera, characters, VillageBuild).
	local destroyed = 0
	local function kill(inst)
		if inst and inst.Parent then
			inst:Destroy()
			destroyed += 1
		end
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Terrain") or child.Name == "Terrain" then
			-- keep map
		elseif child:IsA("Camera") then
			-- keep
		elseif child.Name == "VillageBuild" then
			kill(child)
		elseif child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
			-- keep players
		else
			kill(child)
		end
	end

	-- leftovers (nested parts / models)
	local leftovers = {}
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Terrain") or inst:IsA("Camera") then
			-- keep
		elseif inst:IsA("Model") then
			if not inst:FindFirstChildOfClass("Humanoid") then
				table.insert(leftovers, inst)
			end
		elseif inst:IsA("BasePart") then
			local parentModel = inst:FindFirstAncestorOfClass("Model")
			if not (parentModel and parentModel:FindFirstChildOfClass("Humanoid")) then
				-- huge flat grey slabs / baseplates / construction
				local n = string.lower(inst.Name)
				local hugeFlat = inst.Size.X >= 40 and inst.Size.Z >= 40 and inst.Size.Y <= 10
				local named = string.find(n, "baseplate", 1, true)
					or string.find(n, "spawn", 1, true)
					or n == "part"
					or n == "ground"
				table.insert(leftovers, inst)
			end
		end
	end
	table.sort(leftovers, function(a, b)
		return #(a:GetFullName()) > #(b:GetFullName())
	end)
	for _, inst in ipairs(leftovers) do
		kill(inst)
	end
	print("[Village] junk wipe destroyed:", destroyed)
	return destroyed
end

-- Cover the old grey yard with grass (no Terrain:Clear — only FillBlock grass).
local function layGrass(parent, ignore)
	local Terrain = workspace.Terrain
	-- paint grass voxels over the old middle yard (FillBlock only — never Terrain:Clear)
	for x = -80, 80, 16 do
		for z = -80, 80, 16 do
			if (x * x + z * z) <= 80 * 80 then
				local gy = groundY(x, z, ignore)
				local cf = CFrame.new(x, gy - 2, z)
				pcall(function()
					Terrain:FillBlock(cf, Vector3.new(18, 6, 18), Enum.Material.Grass)
				end)
			end
		end
	end
	-- grass carpet so the yard reads green even if terrain paint is thin
	local folder = Instance.new("Folder")
	folder.Name = "GrassCover"
	folder.Parent = parent
	for x = -72, 72, 24 do
		for z = -72, 72, 24 do
			if (x * x + z * z) <= 75 * 75 then
				local gy = groundY(x, z, ignore)
				local g = part(
					"GrassPatch",
					Vector3.new(24, 0.4, 24),
					CFrame.new(x, gy + 0.15, z),
					Color3.fromRGB(70, 130, 55),
					folder,
					Enum.Material.Grass
				)
				g.CanCollide = false
			end
		end
	end
	print("[Village] grass laid over former junkyard")
end


local function warmLighting()
	local Lighting = game:GetService("Lighting")
	pcall(function()
		Lighting.Technology = Enum.Technology.ShadowMap
	end)
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(100, 95, 85)
	Lighting.OutdoorAmbient = Color3.fromRGB(140, 135, 120)
	Lighting.ClockTime = 15.5
	Lighting.GlobalShadows = true
end

-- One simple shed you can walk into (wide open doorway, no blocking door).
local function buildShed(parent, origin)
	local m = Instance.new("Model")
	m.Name = "PlayerShed"
	m.Parent = parent

	local wood = Color3.fromRGB(120, 85, 50)
	local dark = Color3.fromRGB(80, 55, 32)
	local wall = Color3.fromRGB(210, 195, 165)
	local roofC = Color3.fromRGB(75, 55, 40)

	-- raised floor so it sits above terrain
	local floor = part("Floor", Vector3.new(28, 1.2, 22), origin * CFrame.new(0, 1.2, 0), Color3.fromRGB(140, 105, 70), m, Enum.Material.WoodPlanks)
	m.PrimaryPart = floor
	part("Foundation", Vector3.new(29, 1.5, 23), origin * CFrame.new(0, 0.3, 0), Color3.fromRGB(110, 105, 95), m, Enum.Material.Concrete)

	-- walls (front has a WIDE open doorway — walk straight in)
	local h = 11
	part("WallBack", Vector3.new(28, h, 1), origin * CFrame.new(0, 1.2 + h / 2, 10.5), wall, m, Enum.Material.WoodPlanks)
	part("WallLeft", Vector3.new(1, h, 22), origin * CFrame.new(-13.5, 1.2 + h / 2, 0), wall, m, Enum.Material.WoodPlanks)
	part("WallRight", Vector3.new(1, h, 22), origin * CFrame.new(13.5, 1.2 + h / 2, 0), wall, m, Enum.Material.WoodPlanks)
	-- front: two side panels + open gap ~10 studs wide
	part("WallFrontL", Vector3.new(8, h, 1), origin * CFrame.new(-10, 1.2 + h / 2, -10.5), wall, m, Enum.Material.WoodPlanks)
	part("WallFrontR", Vector3.new(8, h, 1), origin * CFrame.new(10, 1.2 + h / 2, -10.5), wall, m, Enum.Material.WoodPlanks)
	part("Lintel", Vector3.new(12, 2, 1), origin * CFrame.new(0, 1.2 + h - 1, -10.5), dark, m, Enum.Material.Wood)
	-- door swung open against the wall (visual only, no collision)
	local door = part("DoorOpen", Vector3.new(9, 9, 0.4), origin * CFrame.new(-5.5, 1.2 + 5, -9.2) * CFrame.Angles(0, math.rad(-75), 0), dark, m, Enum.Material.Wood)
	door.CanCollide = false

	-- pitched roof
	wedge("RoofL", Vector3.new(15, 5, 26), origin * CFrame.new(-7, 1.2 + h + 1.5, 0) * CFrame.Angles(0, 0, 0.15), roofC, m, Enum.Material.Slate)
	wedge("RoofR", Vector3.new(15, 5, 26), origin * CFrame.new(7, 1.2 + h + 1.5, 0) * CFrame.Angles(0, math.pi, 0.15), roofC, m, Enum.Material.Slate)

	-- windows
	local g1 = part("WinL", Vector3.new(0.2, 3.5, 3.5), origin * CFrame.new(-13.6, 1.2 + 6, -2), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
	g1.Transparency = 0.4
	local g2 = part("WinR", Vector3.new(0.2, 3.5, 3.5), origin * CFrame.new(13.6, 1.2 + 6, -2), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
	g2.Transparency = 0.4

	-- porch
	part("Porch", Vector3.new(20, 1.0, 10), origin * CFrame.new(0, 1.1, -16), wood, m, Enum.Material.WoodPlanks)
	part("PorchRailL", Vector3.new(0.35, 2.2, 8), origin * CFrame.new(-9.5, 2.5, -16), dark, m, Enum.Material.Wood)
	part("PorchRailR", Vector3.new(0.35, 2.2, 8), origin * CFrame.new(9.5, 2.5, -16), dark, m, Enum.Material.Wood)
	part("PorchRailF", Vector3.new(8, 2.2, 0.35), origin * CFrame.new(-5.5, 2.5, -20.5), dark, m, Enum.Material.Wood)
	part("PorchRailF2", Vector3.new(8, 2.2, 0.35), origin * CFrame.new(5.5, 2.5, -20.5), dark, m, Enum.Material.Wood)
	-- porch opening in the middle of the front rail
	part("PostL", Vector3.new(0.8, 10, 0.8), origin * CFrame.new(-8, 6, -20), dark, m, Enum.Material.Wood)
	part("PostR", Vector3.new(0.8, 10, 0.8), origin * CFrame.new(8, 6, -20), dark, m, Enum.Material.Wood)
	part("PorchRoof", Vector3.new(22, 0.7, 11), origin * CFrame.new(0, 11.5, -16), roofC, m, Enum.Material.Slate)

	-- simple furniture (walkable room)
	-- bed
	part("BedFrame", Vector3.new(6.5, 0.8, 9), origin * CFrame.new(7, 2.3, 3), dark, m, Enum.Material.Wood)
	part("Mattress", Vector3.new(6, 0.9, 8.4), origin * CFrame.new(7, 3.0, 3), Color3.fromRGB(230, 225, 215), m, Enum.Material.Fabric)
	part("Pillow", Vector3.new(5.2, 0.5, 1.8), origin * CFrame.new(7, 3.6, -0.5), Color3.fromRGB(245, 240, 230), m, Enum.Material.Fabric)
	part("Blanket", Vector3.new(6, 0.3, 5), origin * CFrame.new(7, 3.55, 4), Color3.fromRGB(90, 110, 80), m, Enum.Material.Fabric)
	-- table + chairs
	part("TableTop", Vector3.new(5, 0.3, 2.8), origin * CFrame.new(-6, 3.3, -2), wood, m, Enum.Material.Wood)
	part("TLeg1", Vector3.new(0.3, 2.0, 0.3), origin * CFrame.new(-8, 2.2, -3), dark, m, Enum.Material.Wood)
	part("TLeg2", Vector3.new(0.3, 2.0, 0.3), origin * CFrame.new(-4, 2.2, -3), dark, m, Enum.Material.Wood)
	part("TLeg3", Vector3.new(0.3, 2.0, 0.3), origin * CFrame.new(-8, 2.2, -1), dark, m, Enum.Material.Wood)
	part("TLeg4", Vector3.new(0.3, 2.0, 0.3), origin * CFrame.new(-4, 2.2, -1), dark, m, Enum.Material.Wood)
	part("ChairSeat", Vector3.new(1.8, 0.25, 1.8), origin * CFrame.new(-6, 2.4, -4.5), wood, m, Enum.Material.Wood)
	part("ChairBack", Vector3.new(1.8, 1.8, 0.25), origin * CFrame.new(-6, 3.3, -3.7), wood, m, Enum.Material.Wood)
	-- chest
	part("Chest", Vector3.new(3.5, 2.2, 2.0), origin * CFrame.new(-8, 2.8, 6), dark, m, Enum.Material.Wood)
	-- rug
	part("Rug", Vector3.new(8, 0.1, 6), origin * CFrame.new(0, 1.85, 0), Color3.fromRGB(130, 60, 50), m, Enum.Material.Fabric)

	-- warm lamp inside
	local lamp = part("Lamp", Vector3.new(1.2, 0.4, 1.2), origin * CFrame.new(0, 10.5, 0), Color3.fromRGB(255, 210, 140), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.zero, Color3.fromRGB(255, 190, 110), 20, 1.5)

	sign(floor, "YOUR SHED · walk in", Vector3.new(0, 8, -12))
	return m
end

function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end

	clearJunk()
	warmLighting()

	local root = Instance.new("Folder")
	root.Name = "VillageBuild"
	root.Parent = workspace
	local ignore = { root }

	-- replace grey middle yard with grass
	layGrass(root, ignore)

	-- place shed near spawn on solid ground
	local x, z = 0, 0
	local y = groundY(x, z, ignore)
	local origin = CFrame.new(x, y, z)
	buildShed(root, origin)

	-- spawn pad on the porch path
	local spawnY = y + 2.0
	local spawn = part("SpawnPad", Vector3.new(8, 0.5, 8), CFrame.new(0, spawnY, -24), Color3.fromRGB(70, 130, 80), root, Enum.Material.Grass)
	sign(spawn, "SPAWN", Vector3.new(0, 4, 0))

	-- SpawnLocation for Roblox
	local sl = Instance.new("SpawnLocation")
	sl.Name = "VillageSpawn"
	sl.Size = Vector3.new(6, 1, 6)
	sl.CFrame = CFrame.new(0, spawnY + 0.5, -24)
	sl.Anchored = true
	sl.Duration = 0
	sl.Neutral = true
	sl.Color = Color3.fromRGB(70, 140, 90)
	sl.Material = Enum.Material.Grass
	sl.Parent = root

	print(string.format("[Village] VILLAGE-18 one shed (y=%.1f) — explore only", y))
	return root
end

return World
