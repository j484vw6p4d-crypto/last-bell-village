--!nocheck
-- VILLAGE-15: futuristic village on Test 1 terrain. Opening doors, real lamp fixtures.
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
	local hit = workspace:Raycast(Vector3.new(x, 1200, z), Vector3.new(0, -3000, 0), params)
	if hit then
		return hit.Position.Y, hit
	end
	return nil, nil
end

-- Snap to terrain using several footprint samples so houses don't sink or float in voids.
local function at(x, z, ignore, halfX, halfZ)
	halfX = halfX or 12
	halfZ = halfZ or 10
	local samples = {
		{ 0, 0 },
		{ halfX, halfZ },
		{ -halfX, halfZ },
		{ halfX, -halfZ },
		{ -halfX, -halfZ },
		{ halfX, 0 },
		{ -halfX, 0 },
		{ 0, halfZ },
		{ 0, -halfZ },
	}
	local ys = {}
	for _, s in ipairs(samples) do
		local y = groundY(x + s[1], z + s[2], ignore)
		if y ~= nil then
			table.insert(ys, y)
		end
	end
	if #ys < 5 then
		-- bad void / off-map — fall back toward hub if possible
		local y0 = groundY(x, z, ignore)
		if y0 == nil then
			return CFrame.new(x, 8, z), 8, false
		end
		return CFrame.new(x, y0 + 1.2, z), y0 + 1.2, false
	end
	table.sort(ys)
	local yMin, yMax = ys[1], ys[#ys]
	-- too steep (cliff / mountain wall)
	if (yMax - yMin) > 18 then
		return CFrame.new(x, yMax + 1.5, z), yMax + 1.5, false
	end
	-- sit on highest sample so floor never clips into a slope
	local y = yMax + 1.0
	return CFrame.new(x, y, z), y, true
end

local function findGoodSpot(ignore, minDist, maxDist, minSep, fromSpots)
	local rng = Random.new(20260919 + #fromSpots * 9973)
	for _ = 1, 80 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(minDist, maxDist)
		local x = math.cos(angle) * dist
		local z = math.sin(angle) * dist
		local okSep = true
		for _, s in ipairs(fromSpots) do
			local dx, dz = s[1] - x, s[2] - z
			if math.sqrt(dx * dx + dz * dz) < minSep then
				okSep = false
				break
			end
		end
		if okSep then
			local cf, y, good = at(x, z, ignore, 16, 14)
			if good and y > 2 and y < 280 then
				return { x, z, y }
			end
		end
	end
	return nil
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

local function pickBaseSpots(ignore)
	-- Stay ON the playable Test 1 terrain (not off-map). Spread but not into the void.
	local spots = {}
	local fallbacks = {
		{ 180, 140 },
		{ -190, 130 },
		{ 170, -180 },
		{ -160, -170 },
	}
	for i = 1, 4 do
		local found = findGoodSpot(ignore, 150, 260, 140, spots)
		if found then
			table.insert(spots, found)
		else
			local f = fallbacks[i]
			local cf, y = at(f[1], f[2], ignore, 16, 14)
			table.insert(spots, { f[1], f[2], y })
		end
	end
	return spots
end


-- Futuristic building shell with real door opening
local function furnitureLiving(m, origin)
	-- sofa
	part("SofaBase", Vector3.new(8, 1.2, 2.8), origin * CFrame.new(-10, 1.4, -4), Color3.fromRGB(45, 70, 95), m, Enum.Material.Fabric)
	part("SofaBack", Vector3.new(8, 2.2, 0.7), origin * CFrame.new(-10, 2.6, -2.9), Color3.fromRGB(40, 60, 85), m, Enum.Material.Fabric)
	part("SofaArmL", Vector3.new(0.7, 1.6, 2.8), origin * CFrame.new(-14, 2.0, -4), Color3.fromRGB(40, 60, 85), m, Enum.Material.Fabric)
	part("SofaArmR", Vector3.new(0.7, 1.6, 2.8), origin * CFrame.new(-6, 2.0, -4), Color3.fromRGB(40, 60, 85), m, Enum.Material.Fabric)
	-- coffee table
	part("CoffeeTop", Vector3.new(4.5, 0.3, 2.2), origin * CFrame.new(-10, 1.6, -7.2), Color3.fromRGB(55, 42, 30), m, Enum.Material.Wood)
	part("CoffeeLeg", Vector3.new(0.35, 1.3, 0.35), origin * CFrame.new(-11.5, 0.9, -7.2), Color3.fromRGB(40, 30, 22), m, Enum.Material.Wood)
	part("CoffeeLeg2", Vector3.new(0.35, 1.3, 0.35), origin * CFrame.new(-8.5, 0.9, -7.2), Color3.fromRGB(40, 30, 22), m, Enum.Material.Wood)
	-- rug
	part("Rug", Vector3.new(12, 0.12, 8), origin * CFrame.new(-10, 0.85, -5), Color3.fromRGB(90, 45, 50), m, Enum.Material.Fabric)
	-- TV / media wall
	part("MediaWall", Vector3.new(7, 4.5, 0.4), origin * CFrame.new(-10, 3.5, -12.5), Color3.fromRGB(30, 34, 42), m, Enum.Material.SmoothPlastic)
	part("Screen", Vector3.new(5.5, 3.2, 0.15), origin * CFrame.new(-10, 3.6, -12.7), Color3.fromRGB(20, 40, 60), m, Enum.Material.Glass)
	part("ScreenGlow", Vector3.new(5.2, 2.9, 0.05), origin * CFrame.new(-10, 3.6, -12.85), Color3.fromRGB(80, 180, 255), m, Enum.Material.Neon).CanCollide = false
	-- dining
	part("DiningTop", Vector3.new(7.5, 0.35, 3.6), origin * CFrame.new(6, 2.4, -6), Color3.fromRGB(110, 80, 50), m, Enum.Material.Wood)
	for _, o in ipairs({ Vector3.new(3.2, 1.1, -1.3), Vector3.new(-3.2, 1.1, -1.3), Vector3.new(3.2, 1.1, 1.3), Vector3.new(-3.2, 1.1, 1.3) }) do
		part("DLeg", Vector3.new(0.35, 2.2, 0.35), origin * CFrame.new(6, 0, -6) * CFrame.new(o), Color3.fromRGB(70, 50, 32), m, Enum.Material.Wood)
	end
	for _, o in ipairs({ -2.2, 0, 2.2 }) do
		part("ChairSeat", Vector3.new(1.8, 0.3, 1.8), origin * CFrame.new(6 + o, 1.5, -8.2), Color3.fromRGB(80, 55, 35), m, Enum.Material.Wood)
		part("ChairBack", Vector3.new(1.8, 2.0, 0.3), origin * CFrame.new(6 + o, 2.5, -7.4), Color3.fromRGB(80, 55, 35), m, Enum.Material.Wood)
	end
	-- kitchen counter
	part("Counter", Vector3.new(10, 2.2, 2.4), origin * CFrame.new(10, 1.9, 2), Color3.fromRGB(55, 60, 70), m, Enum.Material.SmoothPlastic)
	part("CounterTop", Vector3.new(10.2, 0.25, 2.6), origin * CFrame.new(10, 3.1, 2), Color3.fromRGB(200, 205, 210), m, Enum.Material.Marble)
	part("Sink", Vector3.new(2.2, 0.35, 1.6), origin * CFrame.new(8, 3.3, 2), Color3.fromRGB(170, 180, 190), m, Enum.Material.Metal)
	part("Cabinets", Vector3.new(10, 2.5, 1.2), origin * CFrame.new(10, 5.5, 3.2), Color3.fromRGB(45, 50, 60), m, Enum.Material.SmoothPlastic)
	part("Fridge", Vector3.new(2.6, 5.5, 2.4), origin * CFrame.new(15.5, 3.5, 2), Color3.fromRGB(220, 225, 230), m, Enum.Material.Metal)
end

local function furnitureBedroom(m, origin)
	part("BedFrame", Vector3.new(8.5, 1.0, 12), origin * CFrame.new(12, 1.3, 8), Color3.fromRGB(55, 40, 28), m, Enum.Material.Wood)
	part("Mattress", Vector3.new(8, 1.1, 11.2), origin * CFrame.new(12, 2.2, 8), Color3.fromRGB(230, 230, 235), m, Enum.Material.Fabric)
	part("Blanket", Vector3.new(8, 0.4, 7), origin * CFrame.new(12, 2.85, 9.5), Color3.fromRGB(70, 110, 160), m, Enum.Material.Fabric)
	part("Pillow", Vector3.new(7, 0.6, 2.2), origin * CFrame.new(12, 2.9, 3.5), Color3.fromRGB(245, 245, 248), m, Enum.Material.Fabric)
	part("Headboard", Vector3.new(8.8, 4.2, 0.45), origin * CFrame.new(12, 3.5, 2.2), Color3.fromRGB(45, 32, 22), m, Enum.Material.Wood)
	part("NightL", Vector3.new(2.2, 2.0, 2.2), origin * CFrame.new(7, 1.8, 3.5), Color3.fromRGB(70, 50, 35), m, Enum.Material.Wood)
	part("NightR", Vector3.new(2.2, 2.0, 2.2), origin * CFrame.new(17, 1.8, 3.5), Color3.fromRGB(70, 50, 35), m, Enum.Material.Wood)
	local lamp = part("BedLamp", Vector3.new(0.7, 0.7, 0.7), origin * CFrame.new(7, 3.3, 3.5), Color3.fromRGB(255, 220, 160), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.zero, Color3.fromRGB(255, 210, 150), 12, 1.1)
	part("Wardrobe", Vector3.new(6, 10, 2.4), origin * CFrame.new(18, 5.8, 12), Color3.fromRGB(55, 42, 30), m, Enum.Material.Wood)
	part("WardrobeDoorL", Vector3.new(2.7, 8.5, 0.2), origin * CFrame.new(16.6, 5.5, 10.7), Color3.fromRGB(70, 52, 36), m, Enum.Material.Wood)
	part("WardrobeDoorR", Vector3.new(2.7, 8.5, 0.2), origin * CFrame.new(19.4, 5.5, 10.7), Color3.fromRGB(70, 52, 36), m, Enum.Material.Wood)
	part("RugBed", Vector3.new(10, 0.12, 6), origin * CFrame.new(12, 0.85, 14), Color3.fromRGB(50, 70, 100), m, Enum.Material.Fabric)
	part("Desk", Vector3.new(5, 2.2, 2.2), origin * CFrame.new(6, 1.9, 14), Color3.fromRGB(80, 58, 38), m, Enum.Material.Wood)
	part("DeskTop", Vector3.new(5.2, 0.25, 2.4), origin * CFrame.new(6, 3.1, 14), Color3.fromRGB(120, 90, 55), m, Enum.Material.Wood)
	part("DeskChair", Vector3.new(1.8, 0.35, 1.8), origin * CFrame.new(6, 1.5, 12), Color3.fromRGB(40, 45, 55), m, Enum.Material.Fabric)
end

local function house(parent, name, origin, wall, roof)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent

	local accent = Color3.fromRGB(70, 210, 255)
	local panel = wall or Color3.fromRGB(210, 200, 185)
	local trim = roof or Color3.fromRGB(55, 70, 90)
	local wood = Color3.fromRGB(110, 78, 48)

	-- Raised platform so the whole footprint sits above terrain
	local pad = part("LotPad", Vector3.new(58, 2.2, 48), origin * CFrame.new(0, 0.2, 0), Color3.fromRGB(70, 75, 82), m, Enum.Material.Concrete)
	m.PrimaryPart = pad
	part("LotEdge", Vector3.new(58.4, 0.35, 48.4), origin * CFrame.new(0, 1.35, 0), accent, m, Enum.Material.Neon).CanCollide = false

	local floorY = 2.0
	local floor = part("Floor", Vector3.new(46, 1.0, 36), origin * CFrame.new(0, floorY, 0), Color3.fromRGB(150, 120, 85), m, Enum.Material.WoodPlanks)
	-- exterior walls (house-like plaster + trim)
	local wh = 14
	part("WallB", Vector3.new(46, wh, 1.2), origin * CFrame.new(0, floorY + wh / 2, 17.5), panel, m, Enum.Material.SmoothPlastic)
	part("WallL", Vector3.new(1.2, wh, 36), origin * CFrame.new(-22.5, floorY + wh / 2, 0), panel, m, Enum.Material.SmoothPlastic)
	part("WallR", Vector3.new(1.2, wh, 36), origin * CFrame.new(22.5, floorY + wh / 2, 0), panel, m, Enum.Material.SmoothPlastic)
	part("WallF", Vector3.new(15, wh, 1.2), origin * CFrame.new(-14.5, floorY + wh / 2, -17.5), panel, m, Enum.Material.SmoothPlastic)
	part("WallF2", Vector3.new(15, wh, 1.2), origin * CFrame.new(14.5, floorY + wh / 2, -17.5), panel, m, Enum.Material.SmoothPlastic)
	-- pitched roof (reads as a real house)
	wedge("RoofL", Vector3.new(24, 7, 42), origin * CFrame.new(-11.5, floorY + wh + 2.5, 0) * CFrame.Angles(0, 0, 0.12), trim, m, Enum.Material.Slate)
	wedge("RoofR", Vector3.new(24, 7, 42), origin * CFrame.new(11.5, floorY + wh + 2.5, 0) * CFrame.Angles(0, math.pi, 0.12), trim, m, Enum.Material.Slate)
	part("Ridge", Vector3.new(2, 1, 40), origin * CFrame.new(0, floorY + wh + 5.5, 0), Color3.fromRGB(40, 45, 55), m, Enum.Material.Metal)
	part("Chimney", Vector3.new(3.2, 10, 3.2), origin * CFrame.new(14, floorY + wh + 4, 10), Color3.fromRGB(90, 70, 60), m, Enum.Material.Brick)

	-- door frame + opening door
	part("DoorFrameL", Vector3.new(1.1, 12, 1.3), origin * CFrame.new(-6, floorY + 6.5, -17.5), wood, m, Enum.Material.Wood)
	part("DoorFrameR", Vector3.new(1.1, 12, 1.3), origin * CFrame.new(6, floorY + 6.5, -17.5), wood, m, Enum.Material.Wood)
	part("DoorFrameTop", Vector3.new(12, 1.2, 1.3), origin * CFrame.new(0, floorY + 12.5, -17.5), wood, m, Enum.Material.Wood)
	makeDoor(m, origin * CFrame.new(-5.2, floorY + 6.2, -17.5), Vector3.new(10, 11.5, 0.45), Color3.fromRGB(70, 45, 28))

	-- windows with frames + sills
	for _, wx in ipairs({ -16, 16 }) do
		part("WinFrame", Vector3.new(5.2, 5.2, 0.5), origin * CFrame.new(wx, floorY + 8, -17.3), wood, m, Enum.Material.Wood)
		local g = part("WinGlass", Vector3.new(4.4, 4.4, 0.2), origin * CFrame.new(wx, floorY + 8, -17.6), Color3.fromRGB(160, 210, 235), m, Enum.Material.Glass)
		g.Transparency = 0.35
		part("WinSill", Vector3.new(5.4, 0.35, 1.0), origin * CFrame.new(wx, floorY + 5.3, -17.8), wood, m, Enum.Material.Wood)
	end
	for _, wz in ipairs({ -8, 8 }) do
		local g = part("SideWin", Vector3.new(0.2, 4, 3.5), origin * CFrame.new(-23, floorY + 8, wz), Color3.fromRGB(160, 210, 235), m, Enum.Material.Glass)
		g.Transparency = 0.35
	end

	-- porch
	part("Porch", Vector3.new(22, 1.0, 10), origin * CFrame.new(0, floorY - 0.3, -24), Color3.fromRGB(130, 100, 70), m, Enum.Material.WoodPlanks)
	part("PorchRail", Vector3.new(22, 1.1, 0.3), origin * CFrame.new(0, floorY + 1.2, -28.5), wood, m, Enum.Material.Wood)
	part("ColL", Vector3.new(1.2, 12, 1.2), origin * CFrame.new(-8, floorY + 6, -28), wood, m, Enum.Material.Wood)
	part("ColR", Vector3.new(1.2, 12, 1.2), origin * CFrame.new(8, floorY + 6, -28), wood, m, Enum.Material.Wood)
	part("PorchRoof", Vector3.new(24, 1.0, 12), origin * CFrame.new(0, floorY + 12.5, -24), trim, m, Enum.Material.Slate)

	-- interior divider + second door
	part("Divider", Vector3.new(1, 12, 20), origin * CFrame.new(2, floorY + 6.5, 4), panel, m, Enum.Material.SmoothPlastic)
	makeDoor(m, origin * CFrame.new(2, floorY + 5.5, -3) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(6.5, 10, 0.4), Color3.fromRGB(70, 45, 28))

	local io = origin * CFrame.new(0, floorY, 0)
	furnitureLiving(m, io)
	furnitureBedroom(m, io)

	-- ceiling light
	local ceil = part("CeilingLight", Vector3.new(2.8, 0.35, 2.8), origin * CFrame.new(-8, floorY + 12.5, -4), Color3.fromRGB(255, 230, 180), m, Enum.Material.Neon)
	ceil.CanCollide = false
	lightOn(ceil, Vector3.zero, Color3.fromRGB(255, 220, 170), 28, 2.0)
	-- porch sconces
	for _, sx in ipairs({ -7, 7 }) do
		part("Sconce", Vector3.new(0.4, 0.8, 0.4), origin * CFrame.new(sx, floorY + 8, -16.8), Color3.fromRGB(60, 60, 70), m, Enum.Material.Metal)
		local sc = part("SconceGlow", Vector3.new(0.45, 0.45, 0.45), origin * CFrame.new(sx, floorY + 8, -16.3), accent, m, Enum.Material.Neon)
		sc.CanCollide = false
		lightOn(sc, Vector3.zero, Color3.fromRGB(140, 220, 255), 12, 1.0)
	end

	return m
end

local function buildBase(parent, index, x, z, ignore)
	local origin, gy, good = at(x, z, ignore, 20, 18)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	local accent = Color3.fromRGB(70, 210, 255)
	-- yard pad above terrain
	local yard = part("Yard", Vector3.new(70, 2.0, 60), origin * CFrame.new(0, 0.2, 0), Color3.fromRGB(55, 95, 55), m, Enum.Material.Grass)
	m.PrimaryPart = yard
	part("Path", Vector3.new(8, 0.4, 28), origin * CFrame.new(0, 1.3, -14), Color3.fromRGB(90, 90, 95), m, Enum.Material.Concrete)
	part("FenceL", Vector3.new(0.5, 3.2, 58), origin * CFrame.new(-34, 2.4, 0), Color3.fromRGB(80, 60, 40), m, Enum.Material.Wood)
	part("FenceR", Vector3.new(0.5, 3.2, 58), origin * CFrame.new(34, 2.4, 0), Color3.fromRGB(80, 60, 40), m, Enum.Material.Wood)
	part("FenceB", Vector3.new(70, 3.2, 0.5), origin * CFrame.new(0, 2.4, 29), Color3.fromRGB(80, 60, 40), m, Enum.Material.Wood)

	-- smaller player house on the lot
	local ho = origin * CFrame.new(0, 1.2, 6)
	local panel = Color3.fromRGB(205, 195, 180)
	local trim = Color3.fromRGB(60, 75, 95)
	part("HouseFloor", Vector3.new(34, 1.0, 28), ho * CFrame.new(0, 1.8, 0), Color3.fromRGB(145, 115, 80), m, Enum.Material.WoodPlanks)
	part("HouseFound", Vector3.new(36, 1.8, 30), ho * CFrame.new(0, 0.5, 0), Color3.fromRGB(75, 78, 85), m, Enum.Material.Concrete)
	part("HWB", Vector3.new(34, 12, 1.1), ho * CFrame.new(0, 8, 13.5), panel, m, Enum.Material.SmoothPlastic)
	part("HWL", Vector3.new(1.1, 12, 28), ho * CFrame.new(-16.5, 8, 0), panel, m, Enum.Material.SmoothPlastic)
	part("HWR", Vector3.new(1.1, 12, 28), ho * CFrame.new(16.5, 8, 0), panel, m, Enum.Material.SmoothPlastic)
	part("HWF", Vector3.new(11, 12, 1.1), ho * CFrame.new(-10.5, 8, -13.5), panel, m, Enum.Material.SmoothPlastic)
	part("HWF2", Vector3.new(11, 12, 1.1), ho * CFrame.new(10.5, 8, -13.5), panel, m, Enum.Material.SmoothPlastic)
	wedge("HRL", Vector3.new(18, 5.5, 32), ho * CFrame.new(-8.5, 15.5, 0) * CFrame.Angles(0, 0, 0.12), trim, m, Enum.Material.Slate)
	wedge("HRR", Vector3.new(18, 5.5, 32), ho * CFrame.new(8.5, 15.5, 0) * CFrame.Angles(0, math.pi, 0.12), trim, m, Enum.Material.Slate)
	makeDoor(m, ho * CFrame.new(-4.5, 7, -13.5), Vector3.new(8.5, 10.5, 0.45), Color3.fromRGB(70, 45, 28))
	for _, wx in ipairs({ -10, 10 }) do
		local g = part("HWin", Vector3.new(3.5, 3.8, 0.2), ho * CFrame.new(wx, 8, -13.8), Color3.fromRGB(160, 210, 235), m, Enum.Material.Glass)
		g.Transparency = 0.35
	end

	-- interior basics
	part("Sofa", Vector3.new(6.5, 1.2, 2.4), ho * CFrame.new(-7, 3.2, -4), Color3.fromRGB(50, 75, 100), m, Enum.Material.Fabric)
	part("SofaBack", Vector3.new(6.5, 2, 0.6), ho * CFrame.new(-7, 4.2, -3), Color3.fromRGB(45, 65, 90), m, Enum.Material.Fabric)
	part("Table", Vector3.new(5, 0.3, 2.5), ho * CFrame.new(-7, 3.3, -7), Color3.fromRGB(100, 72, 45), m, Enum.Material.Wood)
	part("Bed", Vector3.new(6.5, 1.0, 9), ho * CFrame.new(8, 3.1, 4), Color3.fromRGB(220, 220, 230), m, Enum.Material.Fabric)
	part("BedFrame", Vector3.new(7, 0.8, 9.5), ho * CFrame.new(8, 2.4, 4), Color3.fromRGB(60, 42, 28), m, Enum.Material.Wood)
	part("Pillow", Vector3.new(5.5, 0.5, 1.8), ho * CFrame.new(8, 3.7, 0.8), Color3.fromRGB(245, 245, 250), m, Enum.Material.Fabric)
	part("Counter", Vector3.new(7, 2, 2), ho * CFrame.new(8, 3.5, -6), Color3.fromRGB(60, 65, 75), m, Enum.Material.SmoothPlastic)
	part("Fridge", Vector3.new(2.2, 4.5, 2), ho * CFrame.new(12, 4.5, -6), Color3.fromRGB(220, 225, 230), m, Enum.Material.Metal)
	local hLamp = part("Lamp", Vector3.new(1.8, 0.3, 1.8), ho * CFrame.new(-5, 12.5, -4), Color3.fromRGB(255, 225, 170), m, Enum.Material.Neon)
	hLamp.CanCollide = false
	lightOn(hLamp, Vector3.zero, Color3.fromRGB(255, 220, 160), 20, 1.6)

	-- kiosk
	part("KioskDesk", Vector3.new(12, 1.2, 4.5), origin * CFrame.new(0, 2.2, -16), Color3.fromRGB(50, 58, 70), m, Enum.Material.Metal)
	part("KioskCanopy", Vector3.new(14, 0.4, 9), origin * CFrame.new(0, 7.5, -16), Color3.fromRGB(40, 50, 65), m, Enum.Material.Metal)
	local bank = part("BankPad", Vector3.new(5, 1, 3.5), origin * CFrame.new(0, 3.1, -16), Color3.fromRGB(60, 180, 220), m, Enum.Material.Metal)
	sign(bank, "BASE " .. index .. " · Q bank / R steal", Vector3.new(0, 5, 0), accent)
	prompt(bank, "BankPrompt", "Your base kiosk", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 14)

	local spawn = part("SpawnPad", Vector3.new(8, 0.5, 8), origin * CFrame.new(0, 1.5, -26), Color3.fromRGB(50, 130, 90), m, Enum.Material.SmoothPlastic)
	sign(spawn, "SPAWN · BASE " .. index, Vector3.new(0, 4, 0), Color3.fromRGB(160, 255, 200))
	lantern(m, x - 12, gy, z - 18)
	lantern(m, x + 12, gy, z - 18)

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

	if not good then
		print(string.format("[Village] Base %d soft-placed (steep/edge) at (%.0f,%.0f)", index, x, z))
	end
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

	local hub, hubY = at(0, 0, ignore, 20, 16)
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
	local chapelCF = select(1, at(0, -160, ignore, 14, 16))
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
	local willowCF = select(1, at(-150, 120, ignore, 14, 12))
	house(root, "WillowHome", willowCF, Color3.fromRGB(45, 70, 65), Color3.fromRGB(22, 30, 28))
	local herbs = select(1, makeHerbBed(root, willowCF * CFrame.new(0, 0, -22), "WILLOW · E gather herbs"))

	local ashCF = select(1, at(155, 115, ignore, 14, 12))
	house(root, "AshCottage", ashCF, Color3.fromRGB(70, 55, 50), Color3.fromRGB(30, 24, 22))
	local wood = select(1, makeWoodPile(root, ashCF * CFrame.new(0, 0, -22), "ASH · E chop wood"))

	local innCF = select(1, at(20, 170, ignore, 14, 12))
	local inn = house(root, "LastBellInn", innCF, Color3.fromRGB(55, 50, 70), Color3.fromRGB(24, 22, 32))
	local kitchen = part("Kitchen", Vector3.new(8, 2.2, 8), innCF * CFrame.new(12, 2, 18), Color3.fromRGB(50, 60, 80), inn, Enum.Material.Metal)
	part("Stove", Vector3.new(4, 2.5, 3), innCF * CFrame.new(12, 2.4, 20), Color3.fromRGB(30, 35, 45), inn, Enum.Material.Metal)
	sign(kitchen, "INN · F cook meal", Vector3.new(0, 5, 0), Color3.fromRGB(255, 190, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 15)

	local reedCF = select(1, at(-145, -130, ignore, 14, 12))
	house(root, "ReedHouse", reedCF, Color3.fromRGB(50, 65, 55), Color3.fromRGB(22, 28, 24))
	local reedHerbs = select(1, makeHerbBed(root, reedCF * CFrame.new(10, 0, -20), "REED · E extra herbs"))

	local smithCF = select(1, at(150, -125, ignore, 14, 12))
	house(root, "MillbrookSmithy", smithCF, Color3.fromRGB(60, 55, 50), Color3.fromRGB(28, 26, 24))
	local coals = part("Coals", Vector3.new(4.5, 0.7, 3), smithCF * CFrame.new(-8, 2.2, -20), Color3.fromRGB(80, 200, 255), root, Enum.Material.Neon)
	coals.CanCollide = false
	lightOn(coals, Vector3.new(0, 1, 0), Color3.fromRGB(100, 210, 255), 20, 1.8)
	local scrap = select(1, makeWoodPile(root, smithCF * CFrame.new(10, 0, -20), "SMITHY · E scrap wood"))

	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = root
	local spots = pickBaseSpots(ignore)
	for i, s in ipairs(spots) do
		print(string.format("[Village] Base %d at (%.0f, %.0f)", i, s[1], s[2]))
		buildBase(bases, i, s[1], s[2], ignore)
	end

	watcher(root, -90, -210, ignore)
	watcher(root, 90, -210, ignore)
	watcher(root, 0, 220, ignore)

	print(string.format("[Village] VILLAGE-15 futuristic on Test 1 ground (hubY=%.1f)", hubY))
	return root
end

return World
