--!nocheck
-- VILLAGE-16: country village on Test 1 terrain. Opening doors, real lamp fixtures.
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
	t.TextColor3 = color or Color3.fromRGB(255, 210, 140)
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
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Brightness = brightness or 1.6
	l.Range = range or 22
	l.Shadows = true
	l.Parent = a
	return l
end

-- Proper futuristic lamp post (metal pole + glass housing + small neon core)
local function lantern(parent, x, y, z)
	local cf = CFrame.new(x, y, z)
	part("LampPole", Vector3.new(0.45, 11, 0.45), cf * CFrame.new(0, 5.5, 0), Color3.fromRGB(72, 48, 28), parent, Enum.Material.Wood)
	part("LampArm", Vector3.new(2.4, 0.3, 0.3), cf * CFrame.new(1.1, 10.6, 0), Color3.fromRGB(72, 48, 28), parent, Enum.Material.Wood)
	part("LampCage", Vector3.new(1.5, 1.8, 1.5), cf * CFrame.new(2.2, 10.2, 0), Color3.fromRGB(55, 55, 60), parent, Enum.Material.Metal)
	local glass = part("LampGlass", Vector3.new(1.15, 1.4, 1.15), cf * CFrame.new(2.2, 10.2, 0), Color3.fromRGB(255, 220, 140), parent, Enum.Material.Glass)
	glass.Transparency = 0.35
	glass.CanCollide = false
	local core = part("LampFlame", Vector3.new(0.45, 0.55, 0.45), cf * CFrame.new(2.2, 10.15, 0), Color3.fromRGB(255, 170, 70), parent, Enum.Material.Neon)
	core.CanCollide = false
	lightOn(core, Vector3.zero, Color3.fromRGB(255, 180, 90), 22, 1.7)
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
	part("TableGlow", Vector3.new(7.2, 0.08, 3.2), cf * CFrame.new(0, 2.7, 0), Color3.fromRGB(255, 190, 100), parent, Enum.Material.Neon).CanCollide = false
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
	part("BackGlow", Vector3.new(1.6, 0.15, 0.12), cf * CFrame.new(0, 3.5, 0.9), Color3.fromRGB(255, 190, 100), parent, Enum.Material.Neon).CanCollide = false
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
	part("RugEdge", Vector3.new(12.2, 0.08, 8.2), cf * CFrame.new(0, -0.05, 0), Color3.fromRGB(255, 190, 100), parent, Enum.Material.Neon).CanCollide = false
end

local function furnitureBarrel(parent, cf)
	part("Crate", Vector3.new(2.8, 2.8, 2.8), cf * CFrame.new(0, 1.4, 0), Color3.fromRGB(45, 55, 70), parent, Enum.Material.Metal)
	part("CrateGlow", Vector3.new(2.9, 0.15, 2.9), cf * CFrame.new(0, 2.6, 0), Color3.fromRGB(255, 190, 100), parent, Enum.Material.Neon).CanCollide = false
end

local function applyHighEndGraphics()
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(90, 85, 75)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 125, 110)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 230, 190)
	Lighting.ColorShift_Bottom = Color3.fromRGB(20, 30, 50)
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.15
	Lighting.ClockTime = 16.0
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
-- ===== Country furniture (reads as real furniture, not neon slabs) =====
local function chair(m, cf)
	part("Seat", Vector3.new(2.0, 0.28, 2.0), cf * CFrame.new(0, 1.55, 0), Color3.fromRGB(120, 78, 42), m, Enum.Material.Wood)
	part("Cushion", Vector3.new(1.85, 0.22, 1.85), cf * CFrame.new(0, 1.78, 0), Color3.fromRGB(140, 70, 55), m, Enum.Material.Fabric)
	part("Back", Vector3.new(2.0, 2.1, 0.28), cf * CFrame.new(0, 2.7, 0.9), Color3.fromRGB(110, 72, 38), m, Enum.Material.Wood)
	part("BackSlat", Vector3.new(1.5, 0.15, 0.12), cf * CFrame.new(0, 3.3, 0.95), Color3.fromRGB(90, 58, 30), m, Enum.Material.Wood)
	for _, o in ipairs({
		Vector3.new(-0.75, 0.7, -0.75), Vector3.new(0.75, 0.7, -0.75),
		Vector3.new(-0.75, 0.7, 0.75), Vector3.new(0.75, 0.7, 0.75),
	}) do
		part("Leg", Vector3.new(0.22, 1.4, 0.22), cf * CFrame.new(o), Color3.fromRGB(85, 55, 28), m, Enum.Material.Wood)
	end
end

local function table4(m, cf, sx, sz)
	sx = sx or 6.5
	sz = sz or 3.2
	part("Top", Vector3.new(sx, 0.3, sz), cf * CFrame.new(0, 2.45, 0), Color3.fromRGB(130, 90, 50), m, Enum.Material.Wood)
	for _, o in ipairs({
		Vector3.new(-sx / 2 + 0.4, 1.15, -sz / 2 + 0.4),
		Vector3.new(sx / 2 - 0.4, 1.15, -sz / 2 + 0.4),
		Vector3.new(-sx / 2 + 0.4, 1.15, sz / 2 - 0.4),
		Vector3.new(sx / 2 - 0.4, 1.15, sz / 2 - 0.4),
	}) do
		part("TLeg", Vector3.new(0.32, 2.3, 0.32), cf * CFrame.new(o), Color3.fromRGB(90, 60, 32), m, Enum.Material.Wood)
	end
end

local function bed(m, cf)
	part("Frame", Vector3.new(7.5, 0.9, 11), cf * CFrame.new(0, 1.1, 0), Color3.fromRGB(95, 62, 34), m, Enum.Material.Wood)
	part("Mattress", Vector3.new(7.0, 1.0, 10.2), cf * CFrame.new(0, 1.95, 0), Color3.fromRGB(235, 230, 220), m, Enum.Material.Fabric)
	part("Sheet", Vector3.new(7.0, 0.35, 6.5), cf * CFrame.new(0, 2.55, 1.4), Color3.fromRGB(70, 100, 75), m, Enum.Material.Fabric)
	part("Pillow", Vector3.new(6.2, 0.55, 2.0), cf * CFrame.new(0, 2.6, -3.8), Color3.fromRGB(245, 240, 230), m, Enum.Material.Fabric)
	part("Headboard", Vector3.new(7.8, 3.8, 0.4), cf * CFrame.new(0, 3.2, -5.3), Color3.fromRGB(85, 55, 30), m, Enum.Material.Wood)
	part("Footboard", Vector3.new(7.6, 1.6, 0.35), cf * CFrame.new(0, 2.3, 5.3), Color3.fromRGB(85, 55, 30), m, Enum.Material.Wood)
	for _, o in ipairs({
		Vector3.new(-3.3, 0.55, -4.8), Vector3.new(3.3, 0.55, -4.8),
		Vector3.new(-3.3, 0.55, 4.8), Vector3.new(3.3, 0.55, 4.8),
	}) do
		part("Post", Vector3.new(0.35, 1.1, 0.35), cf * CFrame.new(o), Color3.fromRGB(75, 48, 26), m, Enum.Material.Wood)
	end
end

local function dresser(m, cf)
	part("Body", Vector3.new(5.5, 3.6, 2.2), cf * CFrame.new(0, 2.5, 0), Color3.fromRGB(105, 72, 40), m, Enum.Material.Wood)
	for i = 0, 2 do
		part("Drawer", Vector3.new(5.0, 0.9, 0.15), cf * CFrame.new(0, 1.3 + i * 1.1, -1.15), Color3.fromRGB(120, 85, 50), m, Enum.Material.Wood)
		part("Knob", Vector3.new(0.25, 0.25, 0.25), cf * CFrame.new(0, 1.3 + i * 1.1, -1.3), Color3.fromRGB(180, 150, 70), m, Enum.Material.Metal)
	end
end

local function fireplace(m, cf)
	part("Stone", Vector3.new(7.5, 8.5, 2.4), cf * CFrame.new(0, 4.8, 0), Color3.fromRGB(120, 115, 105), m, Enum.Material.Limestone)
	part("Opening", Vector3.new(4.2, 3.6, 1.2), cf * CFrame.new(0, 2.8, -0.8), Color3.fromRGB(25, 20, 18), m, Enum.Material.SmoothPlastic)
	part("Mantel", Vector3.new(8.2, 0.55, 2.8), cf * CFrame.new(0, 6.8, -0.2), Color3.fromRGB(90, 60, 35), m, Enum.Material.Wood)
	local fire = part("Fire", Vector3.new(3.2, 2.0, 0.8), cf * CFrame.new(0, 2.2, -0.5), Color3.fromRGB(255, 120, 40), m, Enum.Material.Neon)
	fire.CanCollide = false
	lightOn(fire, Vector3.new(0, 0.5, -0.5), Color3.fromRGB(255, 130, 50), 18, 1.6)
	part("Hearth", Vector3.new(8, 0.4, 3.2), cf * CFrame.new(0, 0.5, -0.6), Color3.fromRGB(100, 95, 90), m, Enum.Material.Slate)
end

local function rug(m, cf, color)
	part("Rug", Vector3.new(10, 0.1, 7), cf, color or Color3.fromRGB(120, 55, 45), m, Enum.Material.Fabric)
end

local function shelf(m, cf)
	part("Back", Vector3.new(6.5, 7.5, 0.35), cf * CFrame.new(0, 4.5, 0.7), Color3.fromRGB(95, 65, 35), m, Enum.Material.Wood)
	for i = 0, 3 do
		part("Board", Vector3.new(6.2, 0.25, 1.3), cf * CFrame.new(0, 1.4 + i * 1.8, 0), Color3.fromRGB(110, 78, 42), m, Enum.Material.Wood)
	end
	for i = 0, 4 do
		part("Book", Vector3.new(0.55, 1.3, 1.0), cf * CFrame.new(-2 + i * 1.0, 2.2, 0), Color3.fromRGB(80 + i * 20, 40, 35), m, Enum.Material.SmoothPlastic)
	end
end

local function kitchenCounter(m, cf)
	part("Base", Vector3.new(9, 2.3, 2.4), cf * CFrame.new(0, 1.9, 0), Color3.fromRGB(100, 70, 42), m, Enum.Material.Wood)
	part("Top", Vector3.new(9.2, 0.28, 2.6), cf * CFrame.new(0, 3.15, 0), Color3.fromRGB(210, 200, 185), m, Enum.Material.Marble)
	part("Sink", Vector3.new(2.0, 0.35, 1.5), cf * CFrame.new(-2, 3.35, 0), Color3.fromRGB(170, 175, 180), m, Enum.Material.Metal)
	part("Cupboard", Vector3.new(9, 2.2, 1.1), cf * CFrame.new(0, 5.2, 1.0), Color3.fromRGB(95, 65, 38), m, Enum.Material.Wood)
end

-- Shell variants inspired by common countryside cottages
local STYLES = {
	miller = {
		wall = Color3.fromRGB(232, 222, 205),
		timber = Color3.fromRGB(92, 60, 32),
		roof = Color3.fromRGB(70, 55, 45),
		trim = Color3.fromRGB(92, 60, 32),
		kind = "timber", -- white plaster + dark beams
	},
	willow = {
		wall = Color3.fromRGB(145, 95, 70),
		timber = Color3.fromRGB(70, 45, 28),
		roof = Color3.fromRGB(55, 70, 50),
		trim = Color3.fromRGB(55, 90, 55),
		kind = "cabin", -- warm wood cabin
	},
	ash = {
		wall = Color3.fromRGB(165, 85, 65),
		timber = Color3.fromRGB(80, 50, 35),
		roof = Color3.fromRGB(85, 85, 90),
		trim = Color3.fromRGB(200, 200, 195),
		kind = "brick", -- brick cottage
	},
	inn = {
		wall = Color3.fromRGB(180, 140, 100),
		timber = Color3.fromRGB(75, 48, 28),
		roof = Color3.fromRGB(95, 45, 35),
		trim = Color3.fromRGB(120, 40, 35),
		kind = "inn", -- larger inn
	},
	reed = {
		wall = Color3.fromRGB(210, 200, 160),
		timber = Color3.fromRGB(100, 78, 45),
		roof = Color3.fromRGB(120, 100, 55),
		trim = Color3.fromRGB(70, 110, 70),
		kind = "thatch", -- cream walls, straw roof tone
	},
	smith = {
		wall = Color3.fromRGB(110, 105, 100),
		timber = Color3.fromRGB(60, 55, 50),
		roof = Color3.fromRGB(50, 50, 55),
		trim = Color3.fromRGB(140, 90, 40),
		kind = "stone", -- stone workshop house
	},
	base = {
		wall = Color3.fromRGB(220, 205, 175),
		timber = Color3.fromRGB(95, 65, 38),
		roof = Color3.fromRGB(75, 55, 40),
		trim = Color3.fromRGB(60, 90, 55),
		kind = "cottage",
	},
}

local function window(m, cf, timber)
	part("Frame", Vector3.new(4.6, 4.6, 0.45), cf, timber, m, Enum.Material.Wood)
	local g = part("Glass", Vector3.new(3.9, 3.9, 0.15), cf * CFrame.new(0, 0, -0.2), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
	g.Transparency = 0.4
	part("MullionV", Vector3.new(0.15, 3.9, 0.12), cf * CFrame.new(0, 0, -0.28), timber, m, Enum.Material.Wood)
	part("MullionH", Vector3.new(3.9, 0.15, 0.12), cf * CFrame.new(0, 0, -0.28), timber, m, Enum.Material.Wood)
	part("Sill", Vector3.new(5.0, 0.3, 0.8), cf * CFrame.new(0, -2.5, -0.2), timber, m, Enum.Material.Wood)
end

local function furnishCottage(m, origin, styleName)
	-- living left / front
	rug(m, origin * CFrame.new(-8, 0.85, -4), Color3.fromRGB(130, 60, 50))
	fireplace(m, origin * CFrame.new(-8, 0.7, 12))
	-- sofa (simple but legible)
	part("SofaBase", Vector3.new(7.5, 1.1, 2.6), origin * CFrame.new(-8, 1.35, -2), Color3.fromRGB(95, 70, 50), m, Enum.Material.Wood)
	part("SofaCush", Vector3.new(7.2, 0.7, 2.3), origin * CFrame.new(-8, 2.1, -2), Color3.fromRGB(120, 75, 55), m, Enum.Material.Fabric)
	part("SofaBack", Vector3.new(7.5, 2.0, 0.55), origin * CFrame.new(-8, 2.7, -0.95), Color3.fromRGB(110, 68, 48), m, Enum.Material.Fabric)
	table4(m, origin * CFrame.new(-8, 0.7, -6.5), 5.5, 2.6)
	chair(m, origin * CFrame.new(-11, 0.7, -8.5))
	chair(m, origin * CFrame.new(-5, 0.7, -8.5))
	shelf(m, origin * CFrame.new(-16, 0.7, 2) * CFrame.Angles(0, math.rad(90), 0))
	-- dining / kitchen right-front
	table4(m, origin * CFrame.new(8, 0.7, -6), 7, 3.4)
	chair(m, origin * CFrame.new(5, 0.7, -8.5))
	chair(m, origin * CFrame.new(8, 0.7, -8.5))
	chair(m, origin * CFrame.new(11, 0.7, -8.5))
	kitchenCounter(m, origin * CFrame.new(10, 0.7, 2))
	part("Fridge", Vector3.new(2.4, 5.2, 2.2), origin * CFrame.new(15, 3.4, 2), Color3.fromRGB(225, 225, 230), m, Enum.Material.Metal)
	-- bedroom right-back
	bed(m, origin * CFrame.new(10, 0.7, 8))
	dresser(m, origin * CFrame.new(16, 0.7, 3))
	part("Nightstand", Vector3.new(2.0, 1.8, 1.8), origin * CFrame.new(5.5, 1.6, 3.5), Color3.fromRGB(100, 70, 40), m, Enum.Material.Wood)
	local lamp = part("BedLamp", Vector3.new(0.55, 0.7, 0.55), origin * CFrame.new(5.5, 3.0, 3.5), Color3.fromRGB(255, 220, 150), m, Enum.Material.Neon)
	lamp.CanCollide = false
	lightOn(lamp, Vector3.zero, Color3.fromRGB(255, 200, 130), 10, 0.9)
	rug(m, origin * CFrame.new(10, 0.85, 12), Color3.fromRGB(60, 90, 70))
	-- ceiling beam lamp
	local ceil = part("CeilLamp", Vector3.new(1.6, 0.5, 1.6), origin * CFrame.new(-6, 11.5, -3), Color3.fromRGB(255, 210, 140), m, Enum.Material.Neon)
	ceil.CanCollide = false
	lightOn(ceil, Vector3.zero, Color3.fromRGB(255, 200, 130), 22, 1.5)
end

local function house(parent, name, origin, styleName)
	styleName = styleName or "miller"
	local st = STYLES[styleName] or STYLES.miller
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent

	local wall, timber, roofC, trim = st.wall, st.timber, st.roof, st.trim
	local kind = st.kind

	-- stone / wood foundation lot
	local lot = part("Lot", Vector3.new(52, 2.0, 42), origin * CFrame.new(0, 0.15, 0), Color3.fromRGB(115, 110, 100), m, Enum.Material.Limestone)
	m.PrimaryPart = lot
	local floorY = 1.8
	part("Floor", Vector3.new(40, 0.9, 32), origin * CFrame.new(0, floorY, 0), Color3.fromRGB(145, 110, 70), m, Enum.Material.WoodPlanks)

	local wh = 12
	local matWall = Enum.Material.SmoothPlastic
	if kind == "brick" or kind == "stone" then
		matWall = Enum.Material.Brick
	elseif kind == "cabin" then
		matWall = Enum.Material.WoodPlanks
	end

	-- walls
	part("WallB", Vector3.new(40, wh, 1.15), origin * CFrame.new(0, floorY + wh / 2, 15.5), wall, m, matWall)
	part("WallL", Vector3.new(1.15, wh, 32), origin * CFrame.new(-19.5, floorY + wh / 2, 0), wall, m, matWall)
	part("WallR", Vector3.new(1.15, wh, 32), origin * CFrame.new(19.5, floorY + wh / 2, 0), wall, m, matWall)
	part("WallF", Vector3.new(13, wh, 1.15), origin * CFrame.new(-12.5, floorY + wh / 2, -15.5), wall, m, matWall)
	part("WallF2", Vector3.new(13, wh, 1.15), origin * CFrame.new(12.5, floorY + wh / 2, -15.5), wall, m, matWall)

	-- timber framing accents for half-timber look
	if kind == "timber" or kind == "inn" then
		for _, x in ipairs({ -19.5, 0, 19.5 }) do
			part("BeamV", Vector3.new(0.55, wh, 0.55), origin * CFrame.new(x, floorY + wh / 2, -15.7), timber, m, Enum.Material.Wood)
		end
		part("BeamH", Vector3.new(40, 0.55, 0.55), origin * CFrame.new(0, floorY + wh - 0.4, -15.7), timber, m, Enum.Material.Wood)
		part("BeamMid", Vector3.new(40, 0.45, 0.45), origin * CFrame.new(0, floorY + wh / 2, -15.7), timber, m, Enum.Material.Wood)
	end

	-- pitched roof (thatch-ish darker for reed)
	local roofMat = Enum.Material.Slate
	if kind == "thatch" then
		roofMat = Enum.Material.Grass
	elseif kind == "cabin" then
		roofMat = Enum.Material.Wood
	end
	wedge("RoofL", Vector3.new(21, 6.5, 38), origin * CFrame.new(-10, floorY + wh + 2.2, 0) * CFrame.Angles(0, 0, 0.14), roofC, m, roofMat)
	wedge("RoofR", Vector3.new(21, 6.5, 38), origin * CFrame.new(10, floorY + wh + 2.2, 0) * CFrame.Angles(0, math.pi, 0.14), roofC, m, roofMat)
	part("Ridge", Vector3.new(1.6, 0.7, 36), origin * CFrame.new(0, floorY + wh + 5.2, 0), timber, m, Enum.Material.Wood)
	part("Chimney", Vector3.new(2.8, 9, 2.8), origin * CFrame.new(12, floorY + wh + 3.5, 8), Color3.fromRGB(110, 90, 80), m, Enum.Material.Brick)

	-- door
	part("DoorFrameL", Vector3.new(1.0, 10.5, 1.2), origin * CFrame.new(-5.5, floorY + 5.8, -15.5), timber, m, Enum.Material.Wood)
	part("DoorFrameR", Vector3.new(1.0, 10.5, 1.2), origin * CFrame.new(5.5, floorY + 5.8, -15.5), timber, m, Enum.Material.Wood)
	part("DoorFrameTop", Vector3.new(11, 1.0, 1.2), origin * CFrame.new(0, floorY + 11.2, -15.5), timber, m, Enum.Material.Wood)
	makeDoor(m, origin * CFrame.new(-4.8, floorY + 5.5, -15.5), Vector3.new(9.2, 10, 0.4), Color3.fromRGB(80, 48, 26))

	-- windows
	window(m, origin * CFrame.new(-12, floorY + 7, -15.3), timber)
	window(m, origin * CFrame.new(12, floorY + 7, -15.3), timber)
	-- side windows
	local sideG = part("SideGlass", Vector3.new(0.15, 3.5, 3.2), origin * CFrame.new(-20, floorY + 7, -6), Color3.fromRGB(170, 210, 230), m, Enum.Material.Glass)
	sideG.Transparency = 0.4

	-- shutters for willow/reed
	if kind == "cabin" or kind == "thatch" then
		part("ShutL1", Vector3.new(1.0, 4.2, 0.2), origin * CFrame.new(-14.5, floorY + 7, -15.7), trim, m, Enum.Material.Wood)
		part("ShutL2", Vector3.new(1.0, 4.2, 0.2), origin * CFrame.new(-9.5, floorY + 7, -15.7), trim, m, Enum.Material.Wood)
		part("ShutR1", Vector3.new(1.0, 4.2, 0.2), origin * CFrame.new(9.5, floorY + 7, -15.7), trim, m, Enum.Material.Wood)
		part("ShutR2", Vector3.new(1.0, 4.2, 0.2), origin * CFrame.new(14.5, floorY + 7, -15.7), trim, m, Enum.Material.Wood)
	end

	-- porch (inn gets bigger porch)
	local porchZ = (kind == "inn") and 12 or 9
	part("Porch", Vector3.new(20, 0.9, porchZ), origin * CFrame.new(0, floorY - 0.2, -15.5 - porchZ / 2), Color3.fromRGB(130, 95, 60), m, Enum.Material.WoodPlanks)
	part("Rail", Vector3.new(20, 1.0, 0.28), origin * CFrame.new(0, floorY + 1.1, -15.5 - porchZ), timber, m, Enum.Material.Wood)
	part("ColL", Vector3.new(1.0, 10, 1.0), origin * CFrame.new(-7, floorY + 5, -15.5 - porchZ + 0.8), timber, m, Enum.Material.Wood)
	part("ColR", Vector3.new(1.0, 10, 1.0), origin * CFrame.new(7, floorY + 5, -15.5 - porchZ + 0.8), timber, m, Enum.Material.Wood)
	part("PorchRoof", Vector3.new(22, 0.8, porchZ + 1), origin * CFrame.new(0, floorY + 10.5, -15.5 - porchZ / 2), roofC, m, roofMat)

	-- interior divider
	part("Divider", Vector3.new(0.9, 11, 18), origin * CFrame.new(1, floorY + 6, 3), wall, m, matWall)
	makeDoor(m, origin * CFrame.new(1, floorY + 5, -3) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(5.8, 9.5, 0.35), Color3.fromRGB(80, 48, 26))

	furnishCottage(m, origin * CFrame.new(0, floorY, 0), styleName)

	-- flower boxes under front windows
	part("BoxL", Vector3.new(4.5, 0.7, 1.2), origin * CFrame.new(-12, floorY + 4.2, -16.3), Color3.fromRGB(90, 60, 35), m, Enum.Material.Wood)
	part("FlowL", Vector3.new(4.0, 0.7, 0.9), origin * CFrame.new(-12, floorY + 4.9, -16.3), Color3.fromRGB(220, 80, 100), m, Enum.Material.Grass)
	part("BoxR", Vector3.new(4.5, 0.7, 1.2), origin * CFrame.new(12, floorY + 4.2, -16.3), Color3.fromRGB(90, 60, 35), m, Enum.Material.Wood)
	part("FlowR", Vector3.new(4.0, 0.7, 0.9), origin * CFrame.new(12, floorY + 4.9, -16.3), Color3.fromRGB(240, 200, 70), m, Enum.Material.Grass)

	return m
end

local function buildBase(parent, index, x, z, ignore)
	local origin, gy, good = at(x, z, ignore, 18, 16)
	local m = Instance.new("Model")
	m.Name = "Base" .. index
	m.Parent = parent

	-- each base gets a slightly different cottage tint
	local palette = {
		{ wall = Color3.fromRGB(225, 215, 190), roof = Color3.fromRGB(80, 55, 40), trim = Color3.fromRGB(60, 100, 60) },
		{ wall = Color3.fromRGB(160, 105, 75), roof = Color3.fromRGB(70, 75, 70), trim = Color3.fromRGB(90, 50, 35) },
		{ wall = Color3.fromRGB(200, 185, 155), roof = Color3.fromRGB(100, 50, 40), trim = Color3.fromRGB(50, 70, 90) },
		{ wall = Color3.fromRGB(175, 120, 90), roof = Color3.fromRGB(60, 55, 50), trim = Color3.fromRGB(120, 80, 40) },
	}
	local pal = palette[((index - 1) % #palette) + 1]

	local yard = part("Yard", Vector3.new(64, 1.8, 54), origin * CFrame.new(0, 0.2, 0), Color3.fromRGB(70, 115, 60), m, Enum.Material.Grass)
	m.PrimaryPart = yard
	part("Path", Vector3.new(7, 0.35, 24), origin * CFrame.new(0, 1.2, -12), Color3.fromRGB(120, 110, 95), m, Enum.Material.Cobblestone)
	part("FenceL", Vector3.new(0.4, 2.8, 52), origin * CFrame.new(-31, 2.0, 0), Color3.fromRGB(90, 65, 40), m, Enum.Material.Wood)
	part("FenceR", Vector3.new(0.4, 2.8, 52), origin * CFrame.new(31, 2.0, 0), Color3.fromRGB(90, 65, 40), m, Enum.Material.Wood)
	part("FenceB", Vector3.new(64, 2.8, 0.4), origin * CFrame.new(0, 2.0, 26), Color3.fromRGB(90, 65, 40), m, Enum.Material.Wood)

	-- plant a full country cottage as the base house
	local styleCopy = {
		wall = pal.wall,
		timber = Color3.fromRGB(90, 60, 35),
		roof = pal.roof,
		trim = pal.trim,
		kind = (index % 2 == 0) and "cabin" or "timber",
	}
	STYLES["base" .. index] = styleCopy
	house(m, "Home", origin * CFrame.new(0, 0.8, 4), "base" .. index)

	-- market stall out front
	part("StallDesk", Vector3.new(11, 1.2, 4), origin * CFrame.new(0, 2.0, -16), Color3.fromRGB(120, 85, 50), m, Enum.Material.Wood)
	part("StallCloth", Vector3.new(12, 0.25, 8), origin * CFrame.new(0, 7.2, -16), pal.trim, m, Enum.Material.Fabric)
	part("StallPoleL", Vector3.new(0.4, 7, 0.4), origin * CFrame.new(-5, 4, -18), Color3.fromRGB(80, 55, 30), m, Enum.Material.Wood)
	part("StallPoleR", Vector3.new(0.4, 7, 0.4), origin * CFrame.new(5, 4, -18), Color3.fromRGB(80, 55, 30), m, Enum.Material.Wood)
	local bank = part("BankPad", Vector3.new(4.5, 0.9, 3.2), origin * CFrame.new(0, 2.9, -16), Color3.fromRGB(180, 150, 70), m, Enum.Material.Metal)
	sign(bank, "BASE " .. index .. " · Q bank / R steal", Vector3.new(0, 5, 0), Color3.fromRGB(255, 220, 150))
	prompt(bank, "BankPrompt", "Your base stall", "Bank meal", Enum.KeyCode.Q, 14)
	prompt(bank, "StealPrompt", "Rival base", "Steal meal", Enum.KeyCode.R, 14)

	local spawn = part("SpawnPad", Vector3.new(7, 0.45, 7), origin * CFrame.new(0, 1.35, -24), Color3.fromRGB(80, 140, 90), m, Enum.Material.Grass)
	sign(spawn, "SPAWN · BASE " .. index, Vector3.new(0, 4, 0), Color3.fromRGB(180, 255, 180))
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

	if not good then
		print(string.format("[Village] Base %d soft-placed at (%.0f, %.0f)", index, x, z))
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
	house(root, "MillerHouse", hub, "miller")
	local millerTag = part("MillerTag", Vector3.new(2, 0.4, 2), hub * CFrame.new(0, 22, -28), Color3.fromRGB(255, 200, 120), root, Enum.Material.Neon)
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
	part("TowerGlow", Vector3.new(8, 0.5, 8), chapelCF * CFrame.new(0, 34, -24), Color3.fromRGB(255, 200, 120), chapel, Enum.Material.Neon).CanCollide = false
	local bell = part("LastBell", Vector3.new(4, 4, 4), chapelCF * CFrame.new(0, 28, -24), Color3.fromRGB(200, 220, 255), chapel, Enum.Material.Metal)
	lightOn(bell, Vector3.new(0, 2, 0), Color3.fromRGB(160, 220, 255), 28, 2)
	makeDoor(chapel, chapelCF * CFrame.new(-5, 7, 10), Vector3.new(10, 13, 0.5), Color3.fromRGB(25, 90, 130))
	local altar = part("Altar", Vector3.new(10, 2.2, 4.5), chapelCF * CFrame.new(0, 1.8, -22), Color3.fromRGB(70, 90, 120), chapel, Enum.Material.Metal)
	sign(altar, "CHAPEL · P rebirth at 80 coins", Vector3.new(0, 6, 0))
	prompt(altar, "RebirthPrompt", "Last Bell", "Rebirth", Enum.KeyCode.P, 16)

	-- Willow / Ash / Inn / Reed / Smith — spaced so labels don't pile on Miller porch
	local willowCF = select(1, at(-150, 120, ignore, 14, 12))
	house(root, "WillowHome", willowCF, "willow")
	local herbs = select(1, makeHerbBed(root, willowCF * CFrame.new(0, 0, -22), "WILLOW · E gather herbs"))

	local ashCF = select(1, at(155, 115, ignore, 14, 12))
	house(root, "AshCottage", ashCF, "ash")
	local wood = select(1, makeWoodPile(root, ashCF * CFrame.new(0, 0, -22), "ASH · E chop wood"))

	local innCF = select(1, at(20, 170, ignore, 14, 12))
	local inn = house(root, "LastBellInn", innCF, "inn")
	local kitchen = part("Kitchen", Vector3.new(8, 2.2, 8), innCF * CFrame.new(12, 2.4, 18), Color3.fromRGB(120, 85, 50), inn, Enum.Material.Wood)
	part("Stove", Vector3.new(4, 2.5, 3), innCF * CFrame.new(12, 2.8, 20), Color3.fromRGB(55, 50, 48), inn, Enum.Material.Metal)
	sign(kitchen, "INN · F cook meal", Vector3.new(0, 5, 0), Color3.fromRGB(255, 190, 140))
	prompt(kitchen, "CookPrompt", "Inn kitchen", "Cook meal", Enum.KeyCode.F, 15)

	local reedCF = select(1, at(-145, -130, ignore, 14, 12))
	house(root, "ReedHouse", reedCF, "reed")
	local reedHerbs = select(1, makeHerbBed(root, reedCF * CFrame.new(10, 0, -20), "REED · E extra herbs"))

	local smithCF = select(1, at(150, -125, ignore, 14, 12))
	house(root, "MillbrookSmithy", smithCF, "smith")
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

	print(string.format("[Village] VILLAGE-16 country village on Test 1 ground (hubY=%.1f)", hubY))
	return root
end

return World
