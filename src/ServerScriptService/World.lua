--!nocheck
-- VILLAGE-14: futuristic village on Test 1 terrain. Opening doors, real lamp fixtures.
-- Never Terrain:Clear. Keeps hills; wipes place junk/Baseplate.
local World = {}

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local function part(name, size, cf, color, parent, mat, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.SmoothPlastic
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
	p.Material = mat or Enum.Material.Metal
	p.Anchored = true
	p.CastShadow = true
	p.Parent = parent
	return p
end

local function sign(adornee, text, offset, color)
	local bill = Instance.new("BillboardGui")
	bill.Name = "Sign"
	bill.Size = UDim2.fromOffset(260, 36)
	bill.StudsOffset = offset or Vector3.new(0, 6, 0)
	bill.AlwaysOnTop = false
	bill.MaxDistance = 120
	bill.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 0.35
	t.BackgroundColor3 = Color3.fromRGB(8, 16, 28)
	t.BorderSizePixel = 0
	t.Size = UDim2.fromScale(1, 1)
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(120, 230, 255)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextStrokeTransparency = 0.5
	t.Parent = bill
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = t
end

local function prompt(parent, name, objectText, actionText, key, dist)
	local pr = Instance.new("ProximityPrompt")
	pr.Name = name
	pr.ObjectText = objectText
	pr.ActionText = actionText
	pr.HoldDuration = 0.08
	pr.MaxActivationDistance = dist or 14
	pr.RequiresLineOfSight = false
	pr.KeyboardKeyCode = key or Enum.KeyCode.E
	pr.Parent = parent
	return pr
end

local function lightOn(parent, offset, color, range, brightness)
	local a = Instance.new("Attachment")
	a.Position = offset or Vector3.new(0, 0, 0)
	a.Parent = parent
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(140, 220, 255)
	l.Brightness = brightness or 1.6
	l.Range = range or 22
	l.Shadows = true
	l.Parent = a
	return l
end

-- Proper futuristic lamp post (metal pole + glass housing + small neon core)
local function lantern(parent, x, y, z)
	local cf = CFrame.new(x, y, z)
	part("LampPole", Vector3.new(0.55, 12, 0.55), cf * CFrame.new(0, 6, 0), Color3.fromRGB(35, 40, 50), parent, Enum.Material.Metal)
	part("LampArm", Vector3.new(3.2, 0.35, 0.35), cf * CFrame.new(1.4, 11.5, 0), Color3.fromRGB(45, 50, 60), parent, Enum.Material.Metal)
	part("LampHousing", Vector3.new(1.8, 1.1, 1.8), cf * CFrame.new(2.6, 11.2, 0), Color3.fromRGB(55, 65, 80), parent, Enum.Material.Metal)
	local glass = part("LampGlass", Vector3.new(1.4, 0.9, 1.4), cf * CFrame.new(2.6, 11.2, 0), Color3.fromRGB(180, 230, 255), parent, Enum.Material.Glass)
	glass.Transparency = 0.45
	glass.CanCollide = false
	local core = part("LampCore", Vector3.new(0.55, 0.55, 0.55), cf * CFrame.new(2.6, 11.2, 0), Color3.fromRGB(120, 230, 255), parent, Enum.Material.Neon)
	core.CanCollide = false
	lightOn(core, Vector3.new(), Color3.fromRGB(130, 220, 255), 26, 2.0)
end

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

-- Hinged door that opens / closes with ProximityPrompt
local function makeDoor(parent, hingeCf, size, color)
	local model = Instance.new("Model")
	model.Name = "Door"
	model.Parent = parent

	local hinge = Instance.new("Part")
	hinge.Name = "Hinge"
	hinge.Size = Vector3.new(0.25, size.Y, 0.25)
	hinge.CFrame = hingeCf
	hinge.Transparency = 1
	hinge.Anchored = true
	hinge.CanCollide = false
	hinge.Parent = model

	local door = part("Panel", size, hingeCf * CFrame.new(size.X * 0.5, 0, 0), color or Color3.fromRGB(20, 100, 140), model, Enum.Material.Metal)
	local stripe = part("DoorStripe", Vector3.new(size.X * 0.85, 0.22, 0.12), hingeCf * CFrame.new(size.X * 0.5, size.Y * 0.22, -size.Z * 0.55), Color3.fromRGB(80, 230, 255), model, Enum.Material.Neon)
	stripe.CanCollide = false
	local glass = part("DoorGlass", Vector3.new(size.X * 0.32, size.Y * 0.32, 0.1), hingeCf * CFrame.new(size.X * 0.55, size.Y * 0.08, -size.Z * 0.55), Color3.fromRGB(160, 220, 255), model, Enum.Material.Glass)
	glass.Transparency = 0.35
	glass.CanCollide = false
	local handle = part("Handle", Vector3.new(0.25, 1.1, 0.35), hingeCf * CFrame.new(size.X - 0.6, 0, -size.Z * 0.7), Color3.fromRGB(200, 220, 240), model, Enum.Material.Metal)

	local function layout(cf)
		hinge.CFrame = cf
		door.CFrame = cf * CFrame.new(size.X * 0.5, 0, 0)
		stripe.CFrame = cf * CFrame.new(size.X * 0.5, size.Y * 0.22, -size.Z * 0.55)
		glass.CFrame = cf * CFrame.new(size.X * 0.55, size.Y * 0.08, -size.Z * 0.55)
		handle.CFrame = cf * CFrame.new(size.X - 0.6, 0, -size.Z * 0.7)
	end
	layout(hingeCf)

	local closed = hingeCf
	local open = hingeCf * CFrame.Angles(0, math.rad(-100), 0)
	local isOpen = false
	local busy = false

	local pr = prompt(door, "DoorPrompt", "Door", "Open", Enum.KeyCode.E, 12)
	pr.Triggered:Connect(function()
		if busy then
			return
		end
		busy = true
		isOpen = not isOpen
		pr.ActionText = isOpen and "Close" or "Open"
		local from = isOpen and closed or open
		local to = isOpen and open or closed
		-- manual lerp for hinged parts
		task.spawn(function()
			local t0 = os.clock()
			local dur = 0.4
			while os.clock() - t0 < dur do
				local a = math.clamp((os.clock() - t0) / dur, 0, 1)
				a = a * a * (3 - 2 * a)
				layout(from:Lerp(to, a))
				task.wait()
			end
			layout(to)
			busy = false
		end)
	end)

	return model
end

local function furnitureTable(parent, cf)
	part("TableTop", Vector3.new(8, 0.35, 4), cf * CFrame.new(0, 2.5, 0), Color3.fromRGB(40, 48, 60), parent, Enum.Material.Metal)
	part("TableGlow", Vector3.new(7.2, 0.08, 3.2), cf * CFrame.new(0, 2.7, 0), Color3.fromRGB(80, 220, 255), parent, Enum.Material.Neon).CanCollide = false
	for _, o in ipairs({
		Vector3.new(-3.2, 1.15, -1.4), Vector3.new(3.2, 1.15, -1.4),
		Vector3.new(-3.2, 1.15, 1.4), Vector3.new(3.2, 1.15, 1.4),
	}) do
		part("Leg", Vector3.new(0.35, 2.3, 0.35), cf * CFrame.new(o), Color3.fromRGB(55, 60, 70), parent, Enum.Material.Metal)
	end
end

local function furnitureChair(parent, cf)
	part("Seat", Vector3.new(2.1, 0.3, 2.1), cf * CFrame.new(0, 1.55, 0), Color3.fromRGB(35, 42, 55), parent, Enum.Material.SmoothPlastic)
	part("Back", Vector3.new(2.1, 2.2, 0.28), cf * CFrame.new(0, 2.7, 0.9), Color3.fromRGB(35, 42, 55), parent, Enum.Material.SmoothPlastic)
	part("BackGlow", Vector3.new(1.6, 0.15, 0.12), cf * CFrame.new(0, 3.5, 0.9), Color3.fromRGB(80, 220, 255), parent, Enum.Material.Neon).CanCollide = false
	for _, o in ipairs({
		Vector3.new(-0.75, 0.7, -0.75), Vector3.new(0.75, 0.7, -0.75),
		Vector3.new(-0.75, 0.7, 0.75), Vector3.new(0.75, 0.7, 0.75),
	}) do
		part("CLeg", Vector3.new(0.25, 1.4, 0.25), cf * CFrame.new(o), Color3.fromRGB(50, 55, 65), parent, Enum.Material.Metal)
	end
end

local function furnitureBed(parent, cf)
	part("Frame", Vector3.new(9, 0.9, 13), cf * CFrame.new(0, 1, 0), Color3.fromRGB(30, 35, 45), parent, Enum.Material.Metal)
	part("Mattress", Vector3.new(8.4, 1.1, 12.2), cf * CFrame.new(0, 1.9, 0), Color3.fromRGB(200, 210, 220), parent, Enum.Material.Fabric)
	part("Sheet", Vector3.new(8.4, 0.35, 7), cf * CFrame.new(0, 2.55, 1.5), Color3.fromRGB(60, 140, 180), parent, Enum.Material.Fabric)
	part("Pillow", Vector3.new(7.2, 0.6, 2.2), cf * CFrame.new(0, 2.6, -4.5), Color3.fromRGB(230, 235, 240), parent, Enum.Material.Fabric)
	part("Headboard", Vector3.new(9.2, 4.2, 0.4), cf * CFrame.new(0, 3.4, -6.3), Color3.fromRGB(25, 30, 40), parent, Enum.Material.Metal)
	part("HeadGlow", Vector3.new(6, 0.2, 0.15), cf * CFrame.new(0, 5, -6.4), Color3.fromRGB(100, 230, 255), parent, Enum.Material.Neon).CanCollide = false
end

local function furnitureShelf(parent, cf)
	part("ShelfBack", Vector3.new(8, 9, 0.35), cf * CFrame.new(0, 5.2, 0.7), Color3.fromRGB(28, 34, 45), parent, Enum.Material.Metal)
	for i = 0, 3 do
		part("Board" .. i, Vector3.new(7.6, 0.25, 1.5), cf * CFrame.new(0, 1.6 + i * 2.1, 0), Color3.fromRGB(45, 52, 65), parent, Enum.Material.Metal)
	end
	for i = 0, 5 do
		part("Module" .. i, Vector3.new(0.9, 1.4, 1.1), cf * CFrame.new(-2.6 + i * 1.15, 2.5, 0), Color3.fromRGB(40 + i * 15, 80, 100 + i * 10), parent, Enum.Material.SmoothPlastic)
	end
end

local function furnitureFireplace(parent, cf)
	-- futuristic wall heater / holo-hearth
	part("HeaterFrame", Vector3.new(8.5, 7, 1.8), cf * CFrame.new(0, 4, 0), Color3.fromRGB(30, 36, 48), parent, Enum.Material.Metal)
	part("HeaterGlass", Vector3.new(6.5, 4.5, 0.3), cf * CFrame.new(0, 3.8, -0.9), Color3.fromRGB(120, 220, 255), parent, Enum.Material.Glass).Transparency = 0.3
	local core = part("HeaterCore", Vector3.new(5.5, 3.5, 0.5), cf * CFrame.new(0, 3.8, -0.5), Color3.fromRGB(80, 200, 255), parent, Enum.Material.Neon)
	core.CanCollide = false
	lightOn(core, Vector3.new(0, 0, -1), Color3.fromRGB(100, 210, 255), 24, 2.2)
	part("Vent", Vector3.new(7, 0.4, 1.2), cf * CFrame.new(0, 7.6, 0), Color3.fromRGB(50, 55, 65), parent, Enum.Material.DiamondPlate)
end

local function furnitureRug(parent, cf, color)
	part("Rug", Vector3.new(12, 0.12, 8), cf, color or Color3.fromRGB(25, 60, 90), parent, Enum.Material.Fabric)
	part("RugEdge", Vector3.new(12.2, 0.08, 8.2), cf * CFrame.new(0, -0.05, 0), Color3.fromRGB(80, 220, 255), parent, Enum.Material.Neon).CanCollide = false
end

local function furnitureBarrel(parent, cf)
	part("Crate", Vector3.new(2.8, 2.8, 2.8), cf * CFrame.new(0, 1.4, 0), Color3.fromRGB(45, 55, 70), parent, Enum.Material.Metal)
	part("CrateGlow", Vector3.new(2.9, 0.15, 2.9), cf * CFrame.new(0, 2.6, 0), Color3.fromRGB(80, 220, 255), parent, Enum.Material.Neon).CanCollide = false
end

local function applyHighEndGraphics()
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(40, 55, 80)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 90, 120)
	Lighting.ColorShift_Top = Color3.fromRGB(180, 220, 255)
	Lighting.ColorShift_Bottom = Color3.fromRGB(20, 30, 50)
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.15
	Lighting.ClockTime = 17.2
	Lighting.GeographicLatitude = 20
	Lighting.ExposureCompensation = 0.2

	local function ensure(className, name)
		local old = Lighting:FindFirstChild(name)
		if old then old:Destroy() end
		local fx = Instance.new(className)
		fx.Name = name
		fx.Parent = Lighting
		return fx
	end

	local atm = ensure("Atmosphere", "VillageAtmosphere")
	atm.Density = 0.22
	atm.Offset = 0.1
	atm.Color = Color3.fromRGB(140, 180, 220)
	atm.Decay = Color3.fromRGB(40, 60, 100)
	atm.Glare = 0.35
	atm.Haze = 1.1

	local bloom = ensure("BloomEffect", "VillageBloom")
	bloom.Intensity = 0.55
	bloom.Size = 32
	bloom.Threshold = 0.85

	local rays = ensure("SunRaysEffect", "VillageSunRays")
	rays.Intensity = 0.1
	rays.Spread = 0.65

	local cc = ensure("ColorCorrectionEffect", "VillageColor")
	cc.Brightness = 0.02
	cc.Contrast = 0.18
	cc.Saturation = 0.12
	cc.TintColor = Color3.fromRGB(220, 240, 255)

	local dof = ensure("DepthOfFieldEffect", "VillageDOF")
	dof.FarIntensity = 0.15
	dof.NearIntensity = 0.04
	dof.FocusDistance = 50
	dof.InFocusRadius = 40

	print("[Village] futuristic Future lighting applied")
end

local function isCharacterModel(model)
	return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function clearAllPlaceJunk()
	local destroyed = 0
	local function kill(inst)
		if inst and inst.Parent then
			inst:Destroy()
			destroyed += 1
		end
	end
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Terrain") or child.Name == "Terrain" then
		elseif child:IsA("Camera") then
		elseif child.Name == "VillageBuild" then
			kill(child)
		elseif child:IsA("Model") and isCharacterModel(child) then
		else
			kill(child)
		end
	end
	local leftovers = {}
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Terrain") or inst:IsA("Camera") then
		elseif inst:IsA("Model") then
			if not isCharacterModel(inst) then
				table.insert(leftovers, inst)
			end
		elseif inst:IsA("BasePart") then
			local parentModel = inst:FindFirstAncestorOfClass("Model")
			if not isCharacterModel(parentModel) then
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
	print("[Village] NUCLEAR junk wipe destroyed:", destroyed)
	return destroyed
end

local function pickBaseSpots()
	-- Spread across the WHOLE Test 1 map (far from hub + each other).
	local rng = Random.new(20260919)
	local spots = {}
	local tries = 0
	while #spots < 4 and tries < 600 do
		tries += 1
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(520, 900)
		local x = math.cos(angle) * dist
		local z = math.sin(angle) * dist
		local farFromHub = math.abs(x) >= 400 or math.abs(z) >= 400
		if farFromHub then
			local ok = true
			for _, s in ipairs(spots) do
				local dx = s[1] - x
				local dz = s[2] - z
				if math.sqrt(dx * dx + dz * dz) < 480 then
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
		-- Cardinal corners of a huge playable square
		spots = {
			{ 720, 280 },
			{ -680, 420 },
			{ 600, -720 },
			{ -640, -650 },
		}
	end
	return spots
end

-- Futuristic building shell with real door opening
local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent

	local accent = Color3.fromRGB(70, 210, 255)
	local panel = wall or Color3.fromRGB(45, 55, 70)
	local trim = roof or Color3.fromRGB(25, 30, 40)

	local floor = part("Floor", Vector3.new(52, 1.2, 40), origin * CFrame.new(0, 0.7, 0), Color3.fromRGB(35, 40, 52), m, Enum.Material.Metal)
	m.PrimaryPart = floor
	part("Foundation", Vector3.new(54, 2, 42), origin * CFrame.new(0, -0.5, 0), Color3.fromRGB(28, 32, 40), m, Enum.Material.Concrete)

	-- walls
	part("WallB", Vector3.new(52, 18, 1.2), origin * CFrame.new(0, 10, 19.5), panel, m, Enum.Material.SmoothPlastic)
	part("WallL", Vector3.new(1.2, 18, 40), origin * CFrame.new(-25.5, 10, 0), panel, m, Enum.Material.SmoothPlastic)
	part("WallR", Vector3.new(1.2, 18, 40), origin * CFrame.new(25.5, 10, 0), panel, m, Enum.Material.SmoothPlastic)
	part("WallF", Vector3.new(18, 18, 1.2), origin * CFrame.new(-16, 10, -19.5), panel, m, Enum.Material.SmoothPlastic)
	part("WallF2", Vector3.new(18, 18, 1.2), origin * CFrame.new(16, 10, -19.5), panel, m, Enum.Material.SmoothPlastic)
	-- neon trim lines
	part("TrimF", Vector3.new(52, 0.3, 0.2), origin * CFrame.new(0, 18.5, -19.9), accent, m, Enum.Material.Neon).CanCollide = false
	part("TrimB", Vector3.new(52, 0.3, 0.2), origin * CFrame.new(0, 18.5, 19.9), accent, m, Enum.Material.Neon).CanCollide = false

	-- flat futuristic roof
	part("Roof", Vector3.new(56, 1.5, 44), origin * CFrame.new(0, 19.5, 0), trim, m, Enum.Material.Metal)
	part("RoofCap", Vector3.new(20, 0.4, 8), origin * CFrame.new(0, 20.5, 0), accent, m, Enum.Material.Neon).CanCollide = false
	part("Antenna", Vector3.new(0.4, 8, 0.4), origin * CFrame.new(18, 24, 12), Color3.fromRGB(60, 70, 85), m, Enum.Material.Metal)
	part("AntennaGlow", Vector3.new(0.6, 0.6, 0.6), origin * CFrame.new(18, 28.5, 12), accent, m, Enum.Material.Neon).CanCollide = false

	-- doorway frame + OPENING door (not empty hole)
	part("DoorFrameL", Vector3.new(1.2, 14, 1.4), origin * CFrame.new(-6.2, 7.5, -19.5), Color3.fromRGB(50, 60, 75), m, Enum.Material.Metal)
	part("DoorFrameR", Vector3.new(1.2, 14, 1.4), origin * CFrame.new(6.2, 7.5, -19.5), Color3.fromRGB(50, 60, 75), m, Enum.Material.Metal)
	part("DoorFrameTop", Vector3.new(12.4, 1.2, 1.4), origin * CFrame.new(0, 14.5, -19.5), Color3.fromRGB(50, 60, 75), m, Enum.Material.Metal)
	makeDoor(m, origin * CFrame.new(-5.5, 7, -19.5), Vector3.new(10.5, 12.5, 0.5), Color3.fromRGB(25, 90, 130))

	-- windows
	for _, wx in ipairs({-20, -12, 12, 20}) do
		local g = part("Win", Vector3.new(5, 5, 0.25), origin * CFrame.new(wx, 10, -20), Color3.fromRGB(140, 210, 255), m, Enum.Material.Glass)
		g.Transparency = 0.35
		part("WinFrame", Vector3.new(5.5, 5.5, 0.4), origin * CFrame.new(wx, 10, -19.7), Color3.fromRGB(40, 50, 65), m, Enum.Material.Metal)
	end

	-- porch deck aligned under door
	part("Porch", Vector3.new(24, 1, 12), origin * CFrame.new(0, 0.55, -26), Color3.fromRGB(40, 48, 60), m, Enum.Material.Metal)
	part("PorchEdge", Vector3.new(24.2, 0.2, 0.25), origin * CFrame.new(0, 1.1, -32), accent, m, Enum.Material.Neon).CanCollide = false
	part("ColL", Vector3.new(1.4, 14, 1.4), origin * CFrame.new(-9, 8, -31), Color3.fromRGB(45, 55, 70), m, Enum.Material.Metal)
	part("ColR", Vector3.new(1.4, 14, 1.4), origin * CFrame.new(9, 8, -31), Color3.fromRGB(45, 55, 70), m, Enum.Material.Metal)
	part("PorchRoof", Vector3.new(26, 1, 14), origin * CFrame.new(0, 15.5, -26), trim, m, Enum.Material.Metal)

	-- interior divider + second door
	part("Divider", Vector3.new(1, 16, 22), origin * CFrame.new(5, 9, 4), panel, m, Enum.Material.SmoothPlastic)
	makeDoor(m, origin * CFrame.new(5, 6, -4) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(7, 11, 0.45), Color3.fromRGB(25, 90, 130))

	furnitureRug(m, origin * CFrame.new(-10, 1.4, -2), Color3.fromRGB(20, 50, 80))
	furnitureTable(m, origin * CFrame.new(-10, 0.7, -2))
	furnitureChair(m, origin * CFrame.new(-14, 0.7, -4))
	furnitureChair(m, origin * CFrame.new(-6, 0.7, -4))
	furnitureChair(m, origin * CFrame.new(-14, 0.7, 1) * CFrame.Angles(0, math.pi, 0))
	furnitureChair(m, origin * CFrame.new(-6, 0.7, 1) * CFrame.Angles(0, math.pi, 0))
	furnitureFireplace(m, origin * CFrame.new(-10, 0.7, 16))
	furnitureShelf(m, origin * CFrame.new(-22, 0.7, 6) * CFrame.Angles(0, math.pi / 2, 0))
	furnitureBarrel(m, origin * CFrame.new(-20, 0.7, -12))
	furnitureBed(m, origin * CFrame.new(16, 0.7, 6))
	furnitureRug(m, origin * CFrame.new(16, 1.4, -8), Color3.fromRGB(30, 40, 70))
	part("Wardrobe", Vector3.new(6, 11, 2.4), origin * CFrame.new(22, 6.2, 15), Color3.fromRGB(35, 42, 55), m, Enum.Material.Metal)

	local chand = part("CeilingLight", Vector3.new(3, 0.4, 3), origin * CFrame.new(-8, 17, -2), accent, m, Enum.Material.Neon)
	chand.CanCollide = false
	lightOn(chand, Vector3.new(), Color3.fromRGB(140, 220, 255), 30, 2.4)

	-- wall sconce lamps (not floating balls)
	for _, sx in ipairs({-10, 10}) do
		part("SconceArm", Vector3.new(0.3, 0.3, 1.2), origin * CFrame.new(sx, 10, -18.6), Color3.fromRGB(50, 55, 65), m, Enum.Material.Metal)
		local sc = part("SconceCore", Vector3.new(0.5, 0.5, 0.5), origin * CFrame.new(sx, 10, -17.8), accent, m, Enum.Material.Neon)
		sc.CanCollide = false
		lightOn(sc, Vector3.new(), Color3.fromRGB(130, 220, 255), 14, 1.2)
	end

	return m
end

local function buildBase(parent, index, x, z, ignore)
	local origin, gy = at(x, z, ignore)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	local accent = Color3.fromRGB(70, 210, 255)
	local yard = part("Yard", Vector3.new(96, 1.1, 86), origin * CFrame.new(0, 0.55, 0), Color3.fromRGB(40, 70, 55), m, Enum.Material.Grass)
	m.PrimaryPart = yard
	part("Path", Vector3.new(10, 0.35, 36), origin * CFrame.new(0, 1.2, -18), Color3.fromRGB(50, 55, 65), m, Enum.Material.Concrete)
	part("PathGlow", Vector3.new(10.2, 0.08, 36), origin * CFrame.new(0, 1.4, -18), accent, m, Enum.Material.Neon).CanCollide = false
	part("FenceL", Vector3.new(0.5, 3.5, 84), origin * CFrame.new(-47, 2.5, 0), Color3.fromRGB(40, 50, 65), m, Enum.Material.Metal)
	part("FenceR", Vector3.new(0.5, 3.5, 84), origin * CFrame.new(47, 2.5, 0), Color3.fromRGB(40, 50, 65), m, Enum.Material.Metal)
	part("FenceB", Vector3.new(96, 3.5, 0.5), origin * CFrame.new(0, 2.5, 41), Color3.fromRGB(40, 50, 65), m, Enum.Material.Metal)

	local houseOrigin = origin * CFrame.new(0, 1.1, 10)
	local panel = Color3.fromRGB(48, 58, 75)
	part("HouseFloor", Vector3.new(44, 1.2, 34), houseOrigin * CFrame.new(0, 0.6, 0), Color3.fromRGB(35, 40, 52), m, Enum.Material.Metal)
	part("HouseFound", Vector3.new(46, 1.8, 36), houseOrigin * CFrame.new(0, -0.5, 0), Color3.fromRGB(28, 32, 40), m, Enum.Material.Concrete)
	part("HouseWallB", Vector3.new(44, 16, 1.2), houseOrigin * CFrame.new(0, 8.8, 16.5), panel, m, Enum.Material.SmoothPlastic)
	part("HouseWallL", Vector3.new(1.2, 16, 34), houseOrigin * CFrame.new(-21.5, 8.8, 0), panel, m, Enum.Material.SmoothPlastic)
	part("HouseWallR", Vector3.new(1.2, 16, 34), houseOrigin * CFrame.new(21.5, 8.8, 0), panel, m, Enum.Material.SmoothPlastic)
	part("HouseWallF", Vector3.new(14, 16, 1.2), houseOrigin * CFrame.new(-14, 8.8, -16.5), panel, m, Enum.Material.SmoothPlastic)
	part("HouseWallF2", Vector3.new(14, 16, 1.2), houseOrigin * CFrame.new(14, 8.8, -16.5), panel, m, Enum.Material.SmoothPlastic)
	part("HouseRoof", Vector3.new(48, 1.4, 38), houseOrigin * CFrame.new(0, 17.5, 0), Color3.fromRGB(22, 26, 34), m, Enum.Material.Metal)
	part("HouseRoofGlow", Vector3.new(16, 0.3, 6), houseOrigin * CFrame.new(0, 18.4, 0), accent, m, Enum.Material.Neon).CanCollide = false

	part("DoorFrameL", Vector3.new(1.1, 13, 1.3), houseOrigin * CFrame.new(-6, 7, -16.5), Color3.fromRGB(50, 60, 75), m, Enum.Material.Metal)
	part("DoorFrameR", Vector3.new(1.1, 13, 1.3), houseOrigin * CFrame.new(6, 7, -16.5), Color3.fromRGB(50, 60, 75), m, Enum.Material.Metal)
	part("DoorFrameTop", Vector3.new(12, 1.1, 1.3), houseOrigin * CFrame.new(0, 13.5, -16.5), Color3.fromRGB(50, 60, 75), m, Enum.Material.Metal)
	makeDoor(m, houseOrigin * CFrame.new(-5.2, 6.5, -16.5), Vector3.new(10, 12, 0.5), Color3.fromRGB(25, 90, 130))

	for _, wx in ipairs({-14, 14}) do
		local g = part("HWin", Vector3.new(4, 4.5, 0.25), houseOrigin * CFrame.new(wx, 9, -17), Color3.fromRGB(140, 210, 255), m, Enum.Material.Glass)
		g.Transparency = 0.35
	end

	furnitureRug(m, houseOrigin * CFrame.new(-8, 1.35, -2), Color3.fromRGB(20, 50, 80))
	furnitureTable(m, houseOrigin * CFrame.new(-8, 0.6, -2))
	furnitureChair(m, houseOrigin * CFrame.new(-12, 0.6, -4))
	furnitureChair(m, houseOrigin * CFrame.new(-4, 0.6, -4))
	furnitureFireplace(m, houseOrigin * CFrame.new(-8, 0.6, 12))
	furnitureBed(m, houseOrigin * CFrame.new(10, 0.6, 4))
	furnitureShelf(m, houseOrigin * CFrame.new(17, 0.6, -6) * CFrame.Angles(0, -math.pi / 2, 0))
	local hLamp = part("CeilingLight", Vector3.new(2.5, 0.35, 2.5), houseOrigin * CFrame.new(-6, 15.5, -2), accent, m, Enum.Material.Neon)
	hLamp.CanCollide = false
	lightOn(hLamp, Vector3.new(), Color3.fromRGB(140, 220, 255), 26, 2.1)

	-- trade kiosk (futuristic stall)
	part("KioskDesk", Vector3.new(14, 1.3, 5), origin * CFrame.new(0, 2, -18), Color3.fromRGB(40, 50, 65), m, Enum.Material.Metal)
	part("KioskCanopy", Vector3.new(16, 0.4, 10), origin * CFrame.new(0, 8.5, -18), Color3.fromRGB(25, 30, 40), m, Enum.Material.Metal)
	part("KioskGlow", Vector3.new(15, 0.15, 0.2), origin * CFrame.new(0, 8.8, -22), accent, m, Enum.Material.Neon).CanCollide = false
	part("KioskPoleL", Vector3.new(0.5, 8, 0.5), origin * CFrame.new(-7, 4.5, -20), Color3.fromRGB(45, 55, 70), m, Enum.Material.Metal)
	part("KioskPoleR", Vector3.new(0.5, 8, 0.5), origin * CFrame.new(7, 4.5, -20), Color3.fromRGB(45, 55, 70), m, Enum.Material.Metal)
	local bank = part("BankPad", Vector3.new(5.5, 1, 4), origin * CFrame.new(0, 2.9, -18), Color3.fromRGB(60, 180, 220), m, Enum.Material.Metal)
	sign(bank, "BASE " .. index .. " · Q bank / R steal", Vector3.new(0, 5, 0), accent)
	prompt(bank, "BankPrompt", "Your base kiosk", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 14)

	local spawn = part("SpawnPad", Vector3.new(9, 0.5, 9), origin * CFrame.new(0, 1.35, -32), Color3.fromRGB(40, 120, 90), m, Enum.Material.SmoothPlastic)
	part("SpawnRing", Vector3.new(9.4, 0.15, 9.4), origin * CFrame.new(0, 1.6, -32), accent, m, Enum.Material.Neon).CanCollide = false
	sign(spawn, "SPAWN · BASE " .. index, Vector3.new(0, 4, 0), Color3.fromRGB(160, 255, 200))
	lantern(m, x - 16, gy, z - 24)
	lantern(m, x + 16, gy, z - 24)
	lantern(m, x - 16, gy, z + 22)
	lantern(m, x + 16, gy, z + 22)

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
	local origin = select(1, at(x, z, ignore))
	local torso = part("Watcher", Vector3.new(2, 3.2, 1.2), origin * CFrame.new(0, 4.2, 0), Color3.fromRGB(12, 14, 22), parent, Enum.Material.Metal)
	part("Head", Vector3.new(1.6, 1.6, 1.6), origin * CFrame.new(0, 6.5, 0), Color3.fromRGB(10, 12, 18), parent, Enum.Material.Metal)
	part("EyeL", Vector3.new(0.35, 0.25, 0.2), origin * CFrame.new(-0.35, 6.55, -0.8), Color3.fromRGB(255, 40, 80), parent, Enum.Material.Neon).CanCollide = false
	part("EyeR", Vector3.new(0.35, 0.25, 0.2), origin * CFrame.new(0.35, 6.55, -0.8), Color3.fromRGB(255, 40, 80), parent, Enum.Material.Neon).CanCollide = false
	lightOn(torso, Vector3.new(0, 2, -1), Color3.fromRGB(180, 20, 60), 10, 0.7)
end


-- Realistic harvest props (wood pile + leafy herb bed)
local function makeHerbBed(parent, origin, label)
	local m = Instance.new("Model")
	m.Name = "HerbBed"
	m.Parent = parent
	local soil = part("Soil", Vector3.new(10, 1.1, 10), origin * CFrame.new(0, 0.55, 0), Color3.fromRGB(62, 42, 26), m, Enum.Material.Ground)
	m.PrimaryPart = soil
	part("SoilRim", Vector3.new(10.6, 0.45, 10.6), origin * CFrame.new(0, 0.25, 0), Color3.fromRGB(48, 34, 22), m, Enum.Material.Wood)
	-- leafy clusters
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
		-- flower tip
		if i % 3 == 0 then
			local flower = part("Flower" .. i, Vector3.new(0.55, 0.55, 0.55), origin * CFrame.new(x, 1.1 + h + 0.2, z), Color3.fromRGB(220, 90, 140), m, Enum.Material.SmoothPlastic)
			flower.CanCollide = false
		elseif i % 3 == 1 then
			local bud = part("Bud" .. i, Vector3.new(0.5, 0.5, 0.5), origin * CFrame.new(x, 1.1 + h + 0.15, z), Color3.fromRGB(240, 200, 70), m, Enum.Material.SmoothPlastic)
			bud.CanCollide = false
		end
	end
	-- center harvest pad (invisible hit for prompt)
	local pad = part("Herbs", Vector3.new(4, 1, 4), origin * CFrame.new(0, 1.2, 0), Color3.fromRGB(60, 140, 70), m, Enum.Material.Grass)
	pad.Transparency = 0.35
	pad.CanCollide = false
	sign(pad, label or "HERBS · E gather", Vector3.new(0, 5, 0), Color3.fromRGB(160, 255, 180))
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
	-- stacked log rows
	for row = 0, 2 do
		for col = 0, 4 do
			idx += 1
			local y = 0.7 + row * 1.15
			local x = -3.2 + col * 1.55 + (row % 2) * 0.4
			local z = (row - 1) * 0.15
			local cf = origin * CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90))
			local log = part("Log" .. idx, Vector3.new(4.2, 1.05, 1.05), cf, bark[(idx % #bark) + 1], m, Enum.Material.Wood)
			-- end caps (sawn face)
			local capA = part("LogEndA" .. idx, Vector3.new(0.12, 1.0, 1.0), cf * CFrame.new(2.1, 0, 0), endGrain, m, Enum.Material.WoodPlanks)
			local capB = part("LogEndB" .. idx, Vector3.new(0.12, 1.0, 1.0), cf * CFrame.new(-2.1, 0, 0), endGrain, m, Enum.Material.WoodPlanks)
			capA.CanCollide = false
			capB.CanCollide = false
		end
	end
	-- leaning axe block / stump
	part("Stump", Vector3.new(2.4, 1.6, 2.4), origin * CFrame.new(4.5, 0.9, -2.2), Color3.fromRGB(86, 58, 30), m, Enum.Material.Wood)
	part("StumpTop", Vector3.new(2.5, 0.2, 2.5), origin * CFrame.new(4.5, 1.75, -2.2), endGrain, m, Enum.Material.WoodPlanks)
	-- axe resting on stump
	part("AxeHandle", Vector3.new(0.28, 2.6, 0.28), origin * CFrame.new(4.5, 2.6, -2.2) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(70, 48, 28), m, Enum.Material.Wood)
	part("AxeHead", Vector3.new(1.3, 0.8, 0.22), origin * CFrame.new(5.3, 3.5, -2.0) * CFrame.Angles(0, math.rad(20), math.rad(25)), Color3.fromRGB(150, 155, 165), m, Enum.Material.Metal)

	local pad = part("WoodStation", Vector3.new(5, 1.2, 4), origin * CFrame.new(0, 2.2, 0), Color3.fromRGB(92, 62, 32), m, Enum.Material.Wood)
	pad.Transparency = 0.55
	pad.CanCollide = false
	sign(pad, label or "WOOD · E chop", Vector3.new(0, 5, 0), Color3.fromRGB(255, 210, 150))
	prompt(pad, "WoodPrompt", "Woodpile", "Chop wood", Enum.KeyCode.E, 15)
	return pad, m
end

function World.build()
	local old = workspace:FindFirstChild("VillageBuild")
	if old then
		old:Destroy()
	end

	clearAllPlaceJunk()
	applyHighEndGraphics()

	local root = Instance.new("Folder")
	root.Name = "VillageBuild"
	root.Parent = workspace
	local ignore = { root }

	local hub, hubY = at(0, 0, ignore)
	house(root, "MillerHouse", hub, Color3.fromRGB(48, 58, 75), Color3.fromRGB(22, 26, 34))
	local millerTag = part("MillerTag", Vector3.new(2, 0.4, 2), hub * CFrame.new(0, 22, -28), Color3.fromRGB(70, 210, 255), root, Enum.Material.Neon)
	millerTag.CanCollide = false
	sign(millerTag, "MILLER HOUSE · village core", Vector3.new(0, 2, 0))

	-- garden beds as neon planters
	part("PlanterL", Vector3.new(10, 1.2, 4), hub * CFrame.new(-18, 1.2, 14), Color3.fromRGB(35, 45, 55), root, Enum.Material.Metal)
	part("PlanterR", Vector3.new(10, 1.2, 4), hub * CFrame.new(18, 1.2, 14), Color3.fromRGB(35, 45, 55), root, Enum.Material.Metal)
	part("PlantL", Vector3.new(8, 1.5, 2.5), hub * CFrame.new(-18, 2.5, 14), Color3.fromRGB(40, 160, 90), root, Enum.Material.Grass)
	part("PlantR", Vector3.new(8, 1.5, 2.5), hub * CFrame.new(18, 2.5, 14), Color3.fromRGB(40, 160, 90), root, Enum.Material.Grass)
	part("WellRing", Vector3.new(7, 2.4, 7), hub * CFrame.new(0, 1.6, 24), Color3.fromRGB(50, 60, 75), root, Enum.Material.Metal)
	part("WellCore", Vector3.new(4.5, 0.5, 4.5), hub * CFrame.new(0, 2.6, 24), Color3.fromRGB(80, 200, 255), root, Enum.Material.Neon).CanCollide = false
	lantern(root, -20, hubY, -10)
	lantern(root, 20, hubY, -10)
	lantern(root, -12, hubY, 28)
	lantern(root, 12, hubY, 28)

	-- short roads
	for _, xz in ipairs({
		{ 0, -80, 12, 0.4, 100 }, { 0, 80, 12, 0.4, 100 },
		{ -80, 0, 100, 0.4, 12 }, { 80, 0, 100, 0.4, 12 },
	}) do
		local cf = select(1, at(xz[1], xz[2], ignore))
		part("Road", Vector3.new(xz[3], xz[4], xz[5]), cf * CFrame.new(0, 0.25, 0), Color3.fromRGB(45, 50, 60), root, Enum.Material.Concrete)
	end

	-- Chapel (futuristic)
	local chapelCF = select(1, at(0, -380, ignore))
	local chapel = Instance.new("Model")
	chapel.Name = "ChapelOfTheLastBell"
	chapel.Parent = root
	part("Nave", Vector3.new(26, 18, 36), chapelCF * CFrame.new(0, 10, -8), Color3.fromRGB(50, 58, 75), chapel, Enum.Material.SmoothPlastic)
	part("Tower", Vector3.new(10, 32, 10), chapelCF * CFrame.new(0, 18, -24), Color3.fromRGB(40, 48, 62), chapel, Enum.Material.Metal)
	part("TowerGlow", Vector3.new(8, 0.5, 8), chapelCF * CFrame.new(0, 34, -24), Color3.fromRGB(70, 210, 255), chapel, Enum.Material.Neon).CanCollide = false
	local bell = part("LastBell", Vector3.new(4, 4, 4), chapelCF * CFrame.new(0, 28, -24), Color3.fromRGB(200, 220, 255), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(160, 220, 255), 28, 2)
	makeDoor(chapel, chapelCF * CFrame.new(-5, 7, 10), Vector3.new(10, 13, 0.5), Color3.fromRGB(25, 90, 130))
	local altar = part("Altar", Vector3.new(10, 2.2, 4.5), chapelCF * CFrame.new(0, 1.8, -22), Color3.fromRGB(70, 90, 120), chapel, Enum.Material.Metal)
	sign(altar, "CHAPEL · P rebirth at 80 coins", Vector3.new(0, 6, 0))
	prompt(altar, "RebirthPrompt", "Last Bell", "Rebirth", Enum.KeyCode.P, 16)

	-- Willow / Ash / Inn / Reed / Smith — spaced so labels don't pile on Miller porch
	local willowCF = select(1, at(-420, 180, ignore))
	house(root, "WillowHome", willowCF, Color3.fromRGB(45, 70, 65), Color3.fromRGB(22, 30, 28))
	local herbs = select(1, makeHerbBed(root, willowCF * CFrame.new(0, 0, -22), "WILLOW · E gather herbs"))

	local ashCF = select(1, at(440, 160, ignore))
	house(root, "AshCottage", ashCF, Color3.fromRGB(70, 55, 50), Color3.fromRGB(30, 24, 22))
	local wood = select(1, makeWoodPile(root, ashCF * CFrame.new(0, 0, -22), "ASH · E chop wood"))

	local innCF = select(1, at(40, 420, ignore))
	local inn = house(root, "LastBellInn", innCF, Color3.fromRGB(55, 50, 70), Color3.fromRGB(24, 22, 32))
	local kitchen = part("Kitchen", Vector3.new(8, 2.2, 8), innCF * CFrame.new(12, 2, 18), Color3.fromRGB(50, 60, 80), inn, Enum.Material.Metal)
	part("Stove", Vector3.new(4, 2.5, 3), innCF * CFrame.new(12, 2.4, 20), Color3.fromRGB(30, 35, 45), inn, Enum.Material.Metal)
	sign(kitchen, "INN · F cook meal", Vector3.new(0, 5, 0), Color3.fromRGB(255, 190, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 15)

	local reedCF = select(1, at(-400, -320, ignore))
	house(root, "ReedHouse", reedCF, Color3.fromRGB(50, 65, 55), Color3.fromRGB(22, 28, 24))
	local reedHerbs = select(1, makeHerbBed(root, reedCF * CFrame.new(10, 0, -20), "REED · E extra herbs"))

	local smithCF = select(1, at(420, -300, ignore))
	house(root, "MillbrookSmithy", smithCF, Color3.fromRGB(60, 55, 50), Color3.fromRGB(28, 26, 24))
	local coals = part("Coals", Vector3.new(4.5, 0.7, 3), smithCF * CFrame.new(-8, 2.2, -20), Color3.fromRGB(80, 200, 255), root, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(100, 210, 255), 20, 1.8)
	local scrap = select(1, makeWoodPile(root, smithCF * CFrame.new(10, 0, -20), "SMITHY · E scrap wood"))

	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	local spots = pickBaseSpots()
	for i, s in ipairs(spots) do
		print(string.format("[Village] Base %d at (%.0f, %.0f)", i, s[1], s[2]))
		buildBase(bases, i, s[1], s[2], ignore)
	end

	watcher(root, -220, -500, ignore)
	watcher(root, 220, -500, ignore)
	watcher(root, 0, 520, ignore)

	print(string.format("[Village] VILLAGE-14 futuristic on Test 1 ground (hubY=%.1f)", hubY))
	return root
end

return World
