--!nocheck
-- VILLAGE-22: country gather / bank / steal / cottage upgrade loop.
-- Never Terrain:Clear. No ocean. Warm country graphics.
local World = {}

local Lighting = game:GetService("Lighting")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

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
	bill.Size = UDim2.fromOffset(280, 40)
	bill.StudsOffset = offset or Vector3.new(0, 5, 0)
	bill.AlwaysOnTop = false
	bill.MaxDistance = 120
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 0.3
	t.BackgroundColor3 = Color3.fromRGB(30, 22, 14)
	t.BorderSizePixel = 0
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(255, 230, 180)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = bill
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = t
	return bill
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.05
	pr.MaxActivationDistance = dist or 14
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key or Enum.KeyCode.E
	pr.Parent = parent
	return pr
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

local function at(x, z, ignore)
	local y = groundY(x, z, ignore)
	return CFrame.new(x, y, z), y
end

local function isCharacterModel(model)
	return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end

-- Targeted junk clear: no Terrain:Clear, do NOT wipe the Test 1 place map.
local function clearJunk()
	local destroyed = 0
	local function kill(inst)
		if inst and inst.Parent then
			inst:Destroy()
			destroyed += 1
		end
	end
	local junkNames = {
		VillageBuild = true,
		Village = true,
		Baseplate = true,
		# SpawnLocation left alone (Test 1 spawn)
		["Smooth Block Model"] = true,
	}
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Terrain") or child.Name == "Terrain" or child:IsA("Camera") then
			-- keep map + camera
		elseif child:IsA("Model") and isCharacterModel(child) then
			-- keep players
		elseif junkNames[child.Name] then
			kill(child)
		elseif child:IsA("BasePart") and child.Name == "Part" and child.Size.X >= 500 and child.Size.Z >= 500 then
			-- giant grey slabs only
			kill(child)
		end
	end
	print("[Village] clearJunk destroyed:", destroyed)
	return destroyed
end

local function stripOceanWater()
	local Terrain = workspace.Terrain
	local region = Region3.new(Vector3.new(-600, -80, -600), Vector3.new(600, 120, 600))
	region = region:ExpandToGrid(4)
	pcall(function()
		Terrain:ReplaceMaterial(region, 4, Enum.Material.Water, Enum.Material.Air)
	end)
	print("[Village] stripped leftover ocean water")
end

local function layGrass(parent, ignore)
	local Terrain = workspace.Terrain
	for x = -80, 80, 16 do
		for z = -80, 80, 16 do
			if (x * x + z * z) <= 80 * 80 then
				local gy = groundY(x, z, ignore)
				pcall(function()
					Terrain:FillBlock(CFrame.new(x, gy - 2, z), Vector3.new(18, 6, 18), Enum.Material.Grass)
				end)
			end
		end
	end
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
	print("[Village] grass laid over center")
end

local function applyHighEndGraphics()
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
	Lighting.Brightness = 2.4
	Lighting.Ambient = Color3.fromRGB(110, 100, 85)
	Lighting.OutdoorAmbient = Color3.fromRGB(145, 135, 115)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 170)
	Lighting.ColorShift_Bottom = Color3.fromRGB(80, 70, 50)
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 0.85
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.25
	Lighting.ClockTime = 15.8
	Lighting.GeographicLatitude = 35
	Lighting.ExposureCompensation = 0.05
	Lighting.FogColor = Color3.fromRGB(190, 200, 180)
	Lighting.FogStart = 280
	Lighting.FogEnd = 950

	local function ensure(className, name)
		local old = Lighting:FindFirstChild(name)
		if old then
			old:Destroy()
		end
		local fx = Instance.new(className)
		fx.Name = name
		fx.Parent = Lighting
		return fx
	end

	local atm = ensure("Atmosphere", "VillageAtmosphere")
	atm.Density = 0.28
	atm.Offset = 0.15
	atm.Color = Color3.fromRGB(200, 185, 150)
	atm.Decay = Color3.fromRGB(120, 100, 70)
	atm.Glare = 0.2
	atm.Haze = 1.4

	local bloom = ensure("BloomEffect", "VillageBloom")
	bloom.Intensity = 0.35
	bloom.Size = 24
	bloom.Threshold = 0.95

	local rays = ensure("SunRaysEffect", "VillageSunRays")
	rays.Intensity = 0.12
	rays.Spread = 0.7

	local cc = ensure("ColorCorrectionEffect", "VillageColor")
	cc.Brightness = 0.03
	cc.Contrast = 0.12
	cc.Saturation = 0.18
	cc.TintColor = Color3.fromRGB(255, 245, 225)

	print("[Village] warm country Future lighting applied")
end

local function countryLantern(parent, x, y, z)
	local cf = CFrame.new(x, y, z)
	part("LampPole", Vector3.new(0.45, 10, 0.45), cf * CFrame.new(0, 5, 0), Color3.fromRGB(70, 50, 30), parent, Enum.Material.Wood)
	part("LampArm", Vector3.new(2.4, 0.3, 0.3), cf * CFrame.new(1.0, 9.5, 0), Color3.fromRGB(70, 50, 30), parent, Enum.Material.Wood)
	local glass = part("LampGlass", Vector3.new(1.2, 1.2, 1.2), cf * CFrame.new(2.0, 9.2, 0), Color3.fromRGB(255, 220, 140), parent, Enum.Material.Glass)
	glass.Transparency = 0.35
	glass.CanCollide = false
	local core = part("LampCore", Vector3.new(0.5, 0.5, 0.5), cf * CFrame.new(2.0, 9.2, 0), Color3.fromRGB(255, 190, 100), parent, Enum.Material.Neon)
	core.CanCollide = false
	lightOn(core, Vector3.zero, Color3.fromRGB(255, 190, 110), 22, 1.6)
end

local function makeHerbBed(parent, origin, label)
	local m = Instance.new("Model")
	m.Name = "HerbBed"
	m.Parent = parent
	local soil = part("Soil", Vector3.new(10, 1.1, 10), origin * CFrame.new(0, 0.55, 0), Color3.fromRGB(62, 42, 26), m, Enum.Material.Ground)
	m.PrimaryPart = soil
	part("SoilRim", Vector3.new(10.6, 0.45, 10.6), origin * CFrame.new(0, 0.25, 0), Color3.fromRGB(48, 34, 22), m, Enum.Material.Wood)
	local greens = {
		Color3.fromRGB(48, 120, 55),
		Color3.fromRGB(70, 150, 70),
		Color3.fromRGB(40, 100, 50),
		Color3.fromRGB(90, 170, 80),
		Color3.fromRGB(55, 130, 60),
	}
	for i = 1, 14 do
		local ang = (i / 14) * math.pi * 2
		local r = 1.2 + (i % 4) * 0.85
		local x = math.cos(ang) * r
		local z = math.sin(ang) * r * 0.9
		local h = 1.4 + (i % 3) * 0.55
		local leaf = part("Leaf" .. i, Vector3.new(1.1, h, 1.1), origin * CFrame.new(x, 1.1 + h * 0.5, z), greens[((i - 1) % #greens) + 1], m, Enum.Material.Grass)
		leaf.CanCollide = false
		if i % 3 == 0 then
			local flower = part("Flower" .. i, Vector3.new(0.55, 0.55, 0.55), origin * CFrame.new(x, 1.1 + h + 0.2, z), Color3.fromRGB(220, 90, 140), m, Enum.Material.SmoothPlastic)
			flower.CanCollide = false
		elseif i % 3 == 1 then
			local bud = part("Bud" .. i, Vector3.new(0.5, 0.5, 0.5), origin * CFrame.new(x, 1.1 + h + 0.15, z), Color3.fromRGB(240, 200, 70), m, Enum.Material.SmoothPlastic)
			bud.CanCollide = false
		end
	end
	local pad = part("Herbs", Vector3.new(4, 1, 4), origin * CFrame.new(0, 1.2, 0), Color3.fromRGB(60, 140, 70), m, Enum.Material.Grass)
	pad.Transparency = 0.35
	pad.CanCollide = false
	sign(pad, label or "HERBS - E gather", Vector3.new(0, 5, 0), Color3.fromRGB(160, 255, 180))
	prompt(pad, "HerbPrompt", "Herb garden", "Gather herbs", Enum.KeyCode.E, 15)
	return pad, m
end

local function makeWoodPile(parent, origin, label)
	local m = Instance.new("Model")
	m.Name = "WoodPile"
	m.Parent = parent
	local ground = part("BarkMat", Vector3.new(11, 0.4, 8), origin * CFrame.new(0, 0.2, 0), Color3.fromRGB(55, 40, 28), m, Enum.Material.Ground)
	m.PrimaryPart = ground
	local bark = {
		Color3.fromRGB(92, 62, 32),
		Color3.fromRGB(78, 52, 28),
		Color3.fromRGB(110, 78, 45),
		Color3.fromRGB(70, 48, 26),
		Color3.fromRGB(100, 70, 40),
	}
	local endGrain = Color3.fromRGB(190, 160, 110)
	local idx = 0
	for row = 0, 2 do
		for col = 0, 4 do
			idx += 1
			local y = 0.7 + row * 1.15
			local x = -3.2 + col * 1.55 + (row % 2) * 0.4
			local z = (row - 1) * 0.15
			local cf = origin * CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90))
			part("Log" .. idx, Vector3.new(4.2, 1.05, 1.05), cf, bark[(idx % #bark) + 1], m, Enum.Material.Wood)
			local capA = part("LogEndA" .. idx, Vector3.new(0.12, 1.0, 1.0), cf * CFrame.new(2.1, 0, 0), endGrain, m, Enum.Material.WoodPlanks)
			local capB = part("LogEndB" .. idx, Vector3.new(0.12, 1.0, 1.0), cf * CFrame.new(-2.1, 0, 0), endGrain, m, Enum.Material.WoodPlanks)
			capA.CanCollide = false
			capB.CanCollide = false
		end
	end
	part("Stump", Vector3.new(2.4, 1.6, 2.4), origin * CFrame.new(4.5, 0.9, -2.2), Color3.fromRGB(86, 58, 30), m, Enum.Material.Wood)
	part("StumpTop", Vector3.new(2.5, 0.2, 2.5), origin * CFrame.new(4.5, 1.75, -2.2), endGrain, m, Enum.Material.WoodPlanks)
	part("AxeHandle", Vector3.new(0.28, 2.6, 0.28), origin * CFrame.new(4.5, 2.6, -2.2) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("AxeHead", Vector3.new(1.3, 0.8, 0.22), origin * CFrame.new(5.3, 3.5, -2.0) * CFrame.Angles(0, math.rad(20), math.rad(25)), Color3.fromRGB(150, 155, 165), m, Enum.Material.Metal)

	local pad = part("WoodStation", Vector3.new(5, 1.2, 4), origin * CFrame.new(0, 2.2, 0), Color3.fromRGB(92, 62, 32), m, Enum.Material.Wood)
	pad.Transparency = 0.55
	pad.CanCollide = false
	sign(pad, label or "WOOD - E chop", Vector3.new(0, 5, 0), Color3.fromRGB(255, 210, 150))
	prompt(pad, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 15)
	return pad, m
end

local function clearCottage(folder)
	for _, c in ipairs(folder:GetChildren()) do
		c:Destroy()
	end
end

-- Tier 0: starter shed
local function buildCottageTier0(folder, origin)
	local wood = Color3.fromRGB(120, 85, 50)
	local dark = Color3.fromRGB(80, 55, 32)
	local wall = Color3.fromRGB(210, 195, 165)
	local roofC = Color3.fromRGB(75, 55, 40)
	local floor = part("Floor", Vector3.new(22, 1.0, 18), origin * CFrame.new(0, 1.0, 0), Color3.fromRGB(140, 105, 70), folder, Enum.Material.WoodPlanks)
	local baseModel = folder.Parent
	if baseModel and baseModel:IsA("Model") then
		baseModel.PrimaryPart = floor
	end
	part("Foundation", Vector3.new(23, 1.2, 19), origin * CFrame.new(0, 0.2, 0), Color3.fromRGB(110, 105, 95), folder, Enum.Material.Concrete)
	local h = 9
	part("WallBack", Vector3.new(22, h, 1), origin * CFrame.new(0, 1.0 + h / 2, 8.5), wall, folder, Enum.Material.WoodPlanks)
	part("WallLeft", Vector3.new(1, h, 18), origin * CFrame.new(-10.5, 1.0 + h / 2, 0), wall, folder, Enum.Material.WoodPlanks)
	part("WallRight", Vector3.new(1, h, 18), origin * CFrame.new(10.5, 1.0 + h / 2, 0), wall, folder, Enum.Material.WoodPlanks)
	part("WallFrontL", Vector3.new(7, h, 1), origin * CFrame.new(-7.5, 1.0 + h / 2, -8.5), wall, folder, Enum.Material.WoodPlanks)
	part("WallFrontR", Vector3.new(7, h, 1), origin * CFrame.new(7.5, 1.0 + h / 2, -8.5), wall, folder, Enum.Material.WoodPlanks)
	part("Lintel", Vector3.new(9, 1.6, 1), origin * CFrame.new(0, 1.0 + h - 0.8, -8.5), dark, folder, Enum.Material.Wood)
	wedge("RoofL", Vector3.new(12, 4, 20), origin * CFrame.new(-5.5, 1.0 + h + 1.2, 0), roofC, folder, Enum.Material.Slate)
	wedge("RoofR", Vector3.new(12, 4, 20), origin * CFrame.new(5.5, 1.0 + h + 1.2, 0) * CFrame.Angles(0, math.pi, 0), roofC, folder, Enum.Material.Slate)
	part("Porch", Vector3.new(16, 0.8, 8), origin * CFrame.new(0, 0.9, -13), wood, folder, Enum.Material.WoodPlanks)
	local lamp = part("Lamp", Vector3.new(1.0, 0.35, 1.0), origin * CFrame.new(0, 8.5, 0), Color3.fromRGB(255, 210, 140), folder, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.zero, Color3.fromRGB(255, 190, 110), 16, 1.2)
end

-- Tier 1: bigger timber + porch furniture
local function buildCottageTier1(folder, origin)
	buildCottageTier0(folder, origin)
	local wood = Color3.fromRGB(120, 85, 50)
	local dark = Color3.fromRGB(80, 55, 32)
	part("Wing", Vector3.new(10, 8, 12), origin * CFrame.new(14, 5, 2), Color3.fromRGB(200, 185, 155), folder, Enum.Material.WoodPlanks)
	part("WingRoof", Vector3.new(12, 0.6, 14), origin * CFrame.new(14, 9.5, 2), Color3.fromRGB(70, 50, 35), folder, Enum.Material.Slate)
	part("PorchTable", Vector3.new(4, 0.3, 2.4), origin * CFrame.new(-4, 2.4, -13), wood, folder, Enum.Material.Wood)
	part("PorchChair", Vector3.new(1.6, 0.25, 1.6), origin * CFrame.new(-4, 1.8, -15), wood, folder, Enum.Material.Wood)
	part("PorchChairBack", Vector3.new(1.6, 1.6, 0.25), origin * CFrame.new(-4, 2.6, -14.3), wood, folder, Enum.Material.Wood)
	part("Barrel", Vector3.new(2.2, 2.4, 2.2), origin * CFrame.new(5, 1.8, -12), dark, folder, Enum.Material.Wood)
	part("PostL", Vector3.new(0.7, 8, 0.7), origin * CFrame.new(-7, 5, -16), dark, folder, Enum.Material.Wood)
	part("PostR", Vector3.new(0.7, 8, 0.7), origin * CFrame.new(7, 5, -16), dark, folder, Enum.Material.Wood)
	part("PorchRoof", Vector3.new(18, 0.6, 9), origin * CFrame.new(0, 9.2, -13), Color3.fromRGB(70, 50, 35), folder, Enum.Material.Slate)
end

-- Tier 2: stone chimney + better roof + lights
local function buildCottageTier2(folder, origin)
	buildCottageTier1(folder, origin)
	local stone = Color3.fromRGB(120, 115, 105)
	part("Chimney", Vector3.new(3.2, 14, 3.2), origin * CFrame.new(8, 10, 6), stone, folder, Enum.Material.Slate)
	part("ChimneyCap", Vector3.new(3.8, 0.6, 3.8), origin * CFrame.new(8, 17.2, 6), Color3.fromRGB(90, 85, 75), folder, Enum.Material.Concrete)
	part("RoofTrim", Vector3.new(24, 0.4, 0.5), origin * CFrame.new(0, 11.5, -8.8), Color3.fromRGB(90, 60, 35), folder, Enum.Material.Wood)
	local g1 = part("WinL", Vector3.new(0.2, 3.2, 3.2), origin * CFrame.new(-10.7, 5.5, -2), Color3.fromRGB(170, 210, 230), folder, Enum.Material.Glass)
	g1.Transparency = 0.4
	local g2 = part("WinR", Vector3.new(0.2, 3.2, 3.2), origin * CFrame.new(10.7, 5.5, -2), Color3.fromRGB(170, 210, 230), folder, Enum.Material.Glass)
	g2.Transparency = 0.4
	local porchLamp = part("PorchLamp", Vector3.new(0.8, 0.8, 0.8), origin * CFrame.new(0, 8.5, -16), Color3.fromRGB(255, 200, 120), folder, Enum.Material.Neon)
	porchLamp.CanCollide = false
	lightOn(porchLamp, Vector3.zero, Color3.fromRGB(255, 180, 100), 20, 1.5)
	countryLantern(folder, origin.X - 12, origin.Y, origin.Z - 20)
	countryLantern(folder, origin.X + 12, origin.Y, origin.Z - 20)
end

-- Tier 3: fancy half-timber showpiece + lanterns + garden
local function buildCottageTier3(folder, origin)
	buildCottageTier2(folder, origin)
	local dark = Color3.fromRGB(60, 40, 25)
	local cream = Color3.fromRGB(230, 220, 195)
	-- half-timber beams
	for _, ox in ipairs({-6, 0, 6}) do
		part("BeamV" .. ox, Vector3.new(0.5, 9, 0.35), origin * CFrame.new(ox, 5.5, -8.7), dark, folder, Enum.Material.Wood)
	end
	part("BeamH1", Vector3.new(20, 0.45, 0.35), origin * CFrame.new(0, 4, -8.7), dark, folder, Enum.Material.Wood)
	part("BeamH2", Vector3.new(20, 0.45, 0.35), origin * CFrame.new(0, 7.5, -8.7), dark, folder, Enum.Material.Wood)
	part("FancyGable", Vector3.new(8, 5, 1), origin * CFrame.new(0, 13, -8.5), cream, folder, Enum.Material.WoodPlanks)
	-- garden beds
	part("GardenSoil", Vector3.new(10, 0.8, 4), origin * CFrame.new(-16, 0.5, -6), Color3.fromRGB(70, 50, 30), folder, Enum.Material.Ground)
	for i = 1, 6 do
		local flower = part("GardenFlower" .. i, Vector3.new(0.7, 1.2, 0.7), origin * CFrame.new(-19 + i * 1.2, 1.4, -6), Color3.fromRGB(200, 80 + i * 20, 100), folder, Enum.Material.Grass)
		flower.CanCollide = false
	end
	part("GardenSoil2", Vector3.new(10, 0.8, 4), origin * CFrame.new(16, 0.5, -6), Color3.fromRGB(70, 50, 30), folder, Enum.Material.Ground)
	for i = 1, 6 do
		local bush = part("GardenBush" .. i, Vector3.new(1.0, 1.4, 1.0), origin * CFrame.new(13 + i * 1.1, 1.5, -6), Color3.fromRGB(50, 120, 55), folder, Enum.Material.Grass)
		bush.CanCollide = false
	end
	countryLantern(folder, origin.X - 18, origin.Y, origin.Z + 10)
	countryLantern(folder, origin.X + 18, origin.Y, origin.Z + 10)
	local banner = part("Banner", Vector3.new(6, 2.2, 0.2), origin * CFrame.new(0, 12, -9), Color3.fromRGB(140, 50, 40), folder, Enum.Material.Fabric)
	banner.CanCollide = false
end

local TIER_BUILDERS = {
	[0] = buildCottageTier0,
	[1] = buildCottageTier1,
	[2] = buildCottageTier2,
	[3] = buildCottageTier3,
}

function World.rebuildBase(model, tier)
	if not (model and model:IsA("Model")) then
		return
	end
	tier = math.clamp(tonumber(tier) or 0, 0, Config.MaxUpgrade or 3)
	local cottage = model:FindFirstChild("Cottage")
	if not cottage then
		cottage = Instance.new("Folder")
		cottage.Name = "Cottage"
		cottage.Parent = model
	end
	local originVal = model:FindFirstChild("OriginCF")
	local origin = originVal and originVal.Value or model:GetPivot()
	clearCottage(cottage)
	local builder = TIER_BUILDERS[tier] or buildCottageTier0
	builder(cottage, origin)
	model:SetAttribute("UpgradeTier", tier)
	local tierVal = model:FindFirstChild("UpgradeTier")
	if tierVal then
		tierVal.Value = tier
	end
	print(string.format("[Village] rebuildBase %s tier=%d", model.Name, tier))
end

local function attachBankPad(model, origin, index)
	local bank = part("BankPad", Vector3.new(6, 1, 4.5), origin * CFrame.new(0, 2.6, -18), Color3.fromRGB(180, 140, 70), model, Enum.Material.WoodPlanks)
	sign(bank, "BASE " .. index .. " - Q bank / C cook / R steal", Vector3.new(0, 5, 0))
	prompt(bank, "BankPrompt", "Your bank", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "CookPrompt", "Craft meal", "Cook meal", Enum.KeyCode.C, 14)
	prompt(bank, "StealPrompt", "Rival bank", "Steal stock", Enum.KeyCode.R, 14)
	prompt(bank, "UpgradePrompt", "Cottage", "Upgrade Cottage", Enum.KeyCode.B, 14)
	return bank
end

local function buildBase(parent, index, x, z, ignore)
	local origin, gy = at(x, z, ignore)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	local originCF = Instance.new("CFrameValue")
	originCF.Name = "OriginCF"
	originCF.Value = origin
	originCF.Parent = m

	local cottage = Instance.new("Folder")
	cottage.Name = "Cottage"
	cottage.Parent = m

	World.rebuildBase(m, 0)
	attachBankPad(m, origin, index)

	local spawn = part("SpawnPart", Vector3.new(8, 0.5, 8), origin * CFrame.new(0, 1.3, -28), Color3.fromRGB(70, 130, 80), m, Enum.Material.Grass)
	sign(spawn, "SPAWN - BASE " .. index, Vector3.new(0, 4, 0), Color3.fromRGB(180, 255, 180))

	m:SetAttribute("OwnerUserId", 0)
	m:SetAttribute("UpgradeTier", 0)

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

	local tierVal = Instance.new("IntValue")
	tierVal.Name = "UpgradeTier"
	tierVal.Value = 0
	tierVal.Parent = m

	print(string.format("[Village] Base %d at (%.0f, %.1f, %.0f)", index, x, gy, z))
	return m
end

local function pickBaseSpots(ignore)
	local candidates = {
		{ 70, 55 },
		{ -75, 50 },
		{ 65, -70 },
		{ -60, -75 },
	}
	local spots = {}
	for i, c in ipairs(candidates) do
		local _, y = at(c[1], c[2], ignore)
		table.insert(spots, { c[1], c[2], y })
	end
	return spots
end

function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end
	local oldV = workspace:FindFirstChild("Village")
	if oldV then
		-- keep folder name Village for VillageKeep compatibility if present as empty marker
	end

	clearJunk()
	stripOceanWater()
	applyHighEndGraphics()

	local root = Instance.new("Folder")
	root.Name = "VillageBuild"
	root.Parent = workspace

	-- Also expose as Village alias folder pointer via StringValue for keep scripts
	local village = workspace:FindFirstChild("Village")
	if not village then
		village = Instance.new("Folder")
		village.Name = "Village"
		village.Parent = workspace
	end
	-- clear previous Village children that are not characters
	for _, c in ipairs(village:GetChildren()) do
		c:Destroy()
	end
	local pointer = Instance.new("ObjectValue")
	pointer.Name = "BuildRoot"
	pointer.Value = root
	pointer.Parent = village

	local ignore = { root, village }

	layGrass(root, ignore)

	-- Harvest nodes around the green
	local herbSpots = {
		{ -35, 25, "HERBS - E gather" },
		{ 40, 20, "HERBS - E gather" },
		{ -30, -40, "HERBS - E gather" },
	}
	for _, s in ipairs(herbSpots) do
		local cf = select(1, at(s[1], s[2], ignore))
		makeHerbBed(root, cf, s[3])
	end
	local woodSpots = {
		{ 35, -30, "WOOD - E chop" },
		{ -45, -15, "WOOD - E chop" },
		{ 20, 45, "WOOD - E chop" },
	}
	for _, s in ipairs(woodSpots) do
		local cf = select(1, at(s[1], s[2], ignore))
		makeWoodPile(root, cf, s[3])
	end

	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	local spots = pickBaseSpots(ignore)
	local maxB = Config.MaxBases or 4
	for i = 1, math.min(maxB, #spots) do
		local s = spots[i]
		buildBase(bases, i, s[1], s[2], ignore)
	end

	-- central spawn for unassigned
	local hubY = groundY(0, 0, ignore)
	local sl = Instance.new("SpawnLocation")
	sl.Name = "VillageSpawn"
	sl.Size = Vector3.new(8, 1, 8)
	sl.CFrame = CFrame.new(0, hubY + 2, 0)
	sl.Anchored = true
	sl.Duration = 0
	sl.Neutral = true
	sl.Color = Color3.fromRGB(70, 140, 90)
	sl.Material = Enum.Material.Grass
	sl.Parent = root
	sign(sl, "VILLAGE-22 GREEN", Vector3.new(0, 5, 0))

	print(string.format("[Village] VILLAGE-22 ready (hubY=%.1f) gather/bank/steal/upgrade", hubY))
	return root
end

return World
