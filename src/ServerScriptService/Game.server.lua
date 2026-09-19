--!nocheck
-- VILLAGE-09 gameplay on Test 1 terrain.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local profiles = {}
local baseByUser = {}
local night = false
local phaseEnds = os.clock() + Config.DaySeconds

local function ensure(plr)
	local p = profiles[plr.UserId]
	if not p then
		p = {
			coins = 0, herbs = 0, wood = 0, carry = 0, stock = 0, rebirths = 0,
			didHerb = false, didWood = false, didCook = false, didBank = false, didRebirth = false,
		}
		profiles[plr.UserId] = p
	end
	return p
end

local function checklist(p)
	return {
		(p.didHerb and "[x] " or "[ ] ") .. "1. Gather herbs (E)",
		(p.didWood and "[x] " or "[ ] ") .. "2. Chop wood (E)",
		(p.didCook and "[x] " or "[ ] ") .. "3. Cook at Inn (F)",
		(p.didBank and "[x] " or "[ ] ") .. "4. Bank at YOUR base (Q)",
		(p.coins >= Config.BankGoal and "[x] " or "[ ] ") .. "5. Reach " .. Config.BankGoal .. " coins",
		(p.didRebirth and "[x] " or "[ ] ") .. "6. Rebirth at Chapel (P)",
	}
end

local function objective(p)
	if p.coins >= Config.BankGoal then return "Chapel altar — press P to rebirth" end
	if p.carry > 0 then return "Bank the meal at YOUR base (Q)" end
	if p.herbs > 0 and p.wood > 0 then return "Cook at the Inn kitchen (F)" end
	if p.herbs <= 0 then return "Gather herbs at Willow / Reed (E)" end
	return "Chop wood at Ash / Smithy (E)"
end

local function push(plr, note)
	local p = ensure(plr)
	Remotes.State:FireClient(plr, {
		build = Config.BuildId,
		night = night,
		seconds = math.max(0, math.floor(phaseEnds - os.clock())),
		coins = p.coins,
		herbs = p.herbs,
		wood = p.wood,
		carry = p.carry,
		stock = p.stock,
		rebirths = p.rebirths,
		goal = Config.BankGoal,
		objective = objective(p),
		checklist = checklist(p),
		progress = math.clamp(p.coins / math.max(Config.BankGoal, 1), 0, 1),
	})
	if note then Remotes.Notify:FireClient(plr, note) end
end

local function near(plr, inst, range)
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not (hrp and inst and inst:IsA("BasePart")) then return false end
	return (hrp.Position - inst.Position).Magnitude <= (range or 16)
end

local function findBaseModel(inst)
	local cur = inst
	while cur and cur ~= workspace do
		if cur:IsA("Model") and string.sub(cur.Name, 1, 4) == "Base" then return cur end
		cur = cur.Parent
	end
	return nil
end

local function signRefresh(bank, name)
	local bill = bank:FindFirstChild("Sign")
	local t = bill and bill:FindFirstChildOfClass("TextLabel")
	if t then t.Text = string.upper(name) .. " BASE  ·  Q bank / R steal" end
end

local function syncStock(plr)
	local m = baseByUser[plr.UserId]
	local p = ensure(plr)
	if m and m:FindFirstChild("Stock") then m.Stock.Value = p.stock end
end

local function clearCarry(plr)
	local char = plr.Character
	if not char then return end
	local old = char:FindFirstChild("CarriedMeal")
	if old then old:Destroy() end
end

local function setCarry(plr, on)
	clearCarry(plr)
	if not on then return end
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local meal = Instance.new("Part")
	meal.Name = "CarriedMeal"
	meal.Size = Vector3.new(1.4, 1.1, 1.4)
	meal.Color = Color3.fromRGB(180, 110, 50)
	meal.Material = Enum.Material.SmoothPlastic
	meal.CanCollide = false
	meal.Massless = true
	meal.CFrame = hrp.CFrame * CFrame.new(0, 1.2, -1.4)
	meal.Parent = plr.Character
	local w = Instance.new("WeldConstraint")
	w.Part0 = hrp
	w.Part1 = meal
	w.Parent = meal
end

local function assignBase(plr)
	local root = workspace:FindFirstChild("VillageBuild")
	local bases = root and root:FindFirstChild("Bases")
	if not bases then return nil end
	for _, m in ipairs(bases:GetChildren()) do
		local owner = m:FindFirstChild("OwnerUserId")
		if owner and owner.Value == plr.UserId then
			baseByUser[plr.UserId] = m
			return m
		end
	end
	for _, m in ipairs(bases:GetChildren()) do
		local owner = m:FindFirstChild("OwnerUserId")
		if owner and owner.Value == 0 then
			owner.Value = plr.UserId
			baseByUser[plr.UserId] = m
			local nameVal = m:FindFirstChild("OwnerName")
			if nameVal then nameVal.Value = plr.DisplayName end
			local bank = m:FindFirstChild("BankPad")
			if bank then signRefresh(bank, plr.DisplayName) end
			return m
		end
	end
	return nil
end

local function teleportToBase(plr)
	local m = baseByUser[plr.UserId] or assignBase(plr)
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not (m and hrp) then return end
	local spawn = m:FindFirstChild("SpawnPad")
	if spawn then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

local function applyDayNight(isNight)
	night = isNight
	if isNight then
		Lighting.ClockTime = 0.15
		Lighting.Brightness = 0.4
		Lighting.OutdoorAmbient = Color3.fromRGB(28, 30, 50)
		Lighting.Ambient = Color3.fromRGB(45, 40, 60)
		Lighting.FogColor = Color3.fromRGB(16, 18, 32)
		Lighting.FogStart = 35
		Lighting.FogEnd = 200
	else
		Lighting.ClockTime = 16.3
		Lighting.Brightness = 2.3
		Lighting.OutdoorAmbient = Color3.fromRGB(150, 135, 115)
		Lighting.Ambient = Color3.fromRGB(120, 115, 105)
		Lighting.FogColor = Color3.fromRGB(190, 200, 210)
		Lighting.FogStart = 250
		Lighting.FogEnd = 900
	end
end

local function onHerbs(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then push(plr, "Get closer to the herbs.") return end
	if p.herbs >= Config.MaxHerbs then push(plr, "Herb pouch full.") return end
	p.herbs += 1
	p.didHerb = true
	push(plr, "Herbs " .. p.herbs .. "/" .. Config.MaxHerbs)
end

local function onWood(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then push(plr, "Get closer to the wood.") return end
	if p.wood >= Config.MaxWood then push(plr, "Wood bundle full.") return end
	p.wood += 1
	p.didWood = true
	push(plr, "Wood " .. p.wood .. "/" .. Config.MaxWood)
end

local function onCook(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then push(plr, "Stand at the kitchen.") return end
	if p.carry >= Config.MaxCarry then push(plr, "Already carrying a meal — bank it (Q).") return end
	if p.herbs < 1 or p.wood < 1 then push(plr, "Need 1 herb and 1 wood.") return end
	p.herbs -= 1
	p.wood -= 1
	p.carry += 1
	p.didCook = true
	setCarry(plr, true)
	push(plr, "Meal cooked — bank it at YOUR base (Q).")
end

local function onBank(plr, pad)
	local p = ensure(plr)
	if night then push(plr, "Banking is daytime only.") return end
	if not near(plr, pad, 14) then push(plr, "Stand at your base counter.") return end
	local base = findBaseModel(pad)
	local owner = base and base:FindFirstChild("OwnerUserId")
	if not owner or owner.Value ~= plr.UserId then push(plr, "That is not your base.") return end
	if p.carry < 1 then push(plr, "Cook a meal first (F).") return end
	p.carry -= 1
	clearCarry(plr)
	local payout = math.floor(Config.MealValue * (1 + 0.25 * p.rebirths))
	p.coins += payout
	p.didBank = true
	syncStock(plr)
	push(plr, "Sold +" .. payout .. " (" .. p.coins .. "/" .. Config.BankGoal .. ")")
end

local function onSteal(plr, pad)
	local p = ensure(plr)
	if not night then push(plr, "Steal only at night.") return end
	if not near(plr, pad, Config.StealRange) then push(plr, "Get closer.") return end
	local base = findBaseModel(pad)
	local owner = base and base:FindFirstChild("OwnerUserId")
	if not owner or owner.Value == 0 then push(plr, "Empty base.") return end
	if owner.Value == plr.UserId then push(plr, "Can't steal from yourself.") return end
	if p.carry >= Config.MaxCarry then push(plr, "Hands full.") return end
	local victimPlr = Players:GetPlayerByUserId(owner.Value)
	local victim = victimPlr and ensure(victimPlr) or nil
	if victim and victim.carry > 0 then
		victim.carry -= 1
		clearCarry(victimPlr)
		p.carry += 1
		setCarry(plr, true)
		push(plr, "Stole their meal!")
		if victimPlr then push(victimPlr, plr.DisplayName .. " stole your meal!") end
		return
	end
	if victim and victim.coins >= Config.MealValue then
		victim.coins -= Config.MealValue
		p.carry += 1
		setCarry(plr, true)
		push(plr, "Robbed their till!")
		if victimPlr then push(victimPlr, plr.DisplayName .. " robbed your base!") end
		return
	end
	push(plr, "Nothing to steal.")
end

local function onRebirth(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 18) then push(plr, "Stand at the altar.") return end
	if p.coins < Config.BankGoal then push(plr, "Need " .. Config.BankGoal .. " coins.") return end
	p.coins = 0
	p.herbs = 0
	p.wood = 0
	p.carry = 0
	p.stock = 0
	p.rebirths += 1
	p.didRebirth = true
	p.didHerb = false
	p.didWood = false
	p.didCook = false
	p.didBank = false
	clearCarry(plr)
	syncStock(plr)
	push(plr, "Rebirth " .. p.rebirths .. " — the bell remembers you.")
	teleportToBase(plr)
end

local function handlePrompt(plr, promptInst)
	local pad = promptInst.Parent
	local n = promptInst.Name
	if n == "HerbPrompt" then onHerbs(plr, pad)
	elseif n == "WoodPrompt" then onWood(plr, pad)
	elseif n == "CookPrompt" then onCook(plr, pad)
	elseif n == "BankPrompt" then onBank(plr, pad)
	elseif n == "StealPrompt" then onSteal(plr, pad)
	elseif n == "RebirthPrompt" then onRebirth(plr, pad)
	end
end

Players.PlayerAdded:Connect(function(plr)
	ensure(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.6)
		assignBase(plr)
		teleportToBase(plr)
		local p = ensure(plr)
		setCarry(plr, p.carry > 0)
		push(plr, "Your base is on the village grounds. Follow the tasks.")
	end)
	task.defer(function()
		assignBase(plr)
		push(plr)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	local m = baseByUser[plr.UserId]
	if m then
		local owner = m:FindFirstChild("OwnerUserId")
		if owner then owner.Value = 0 end
		local stock = m:FindFirstChild("Stock")
		if stock then stock.Value = 0 end
		local nameVal = m:FindFirstChild("OwnerName")
		if nameVal then nameVal.Value = "Open" end
		local bank = m:FindFirstChild("BankPad")
		if bank then signRefresh(bank, "Open") end
	end
	baseByUser[plr.UserId] = nil
	profiles[plr.UserId] = nil
end)

Remotes.Act.OnServerEvent:Connect(function(plr, kind)
	if type(kind) ~= "string" then return end
	local root = workspace:FindFirstChild("VillageBuild")
	if not root then return end
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if kind == "E" then
		local best, bestDist, bestName = nil, 22, nil
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("ProximityPrompt") and (d.Name == "HerbPrompt" or d.Name == "WoodPrompt") then
				local pad = d.Parent
				if pad and pad:IsA("BasePart") then
					local dist = (hrp.Position - pad.Position).Magnitude
					if dist < bestDist then best, bestDist, bestName = pad, dist, d.Name end
				end
			end
		end
		if bestName == "HerbPrompt" then onHerbs(plr, best)
		elseif bestName == "WoodPrompt" then onWood(plr, best) end
	elseif kind == "F" then
		local inn = root:FindFirstChild("LastBellInn")
		local kitchen = inn and inn:FindFirstChild("Kitchen")
		if kitchen then onCook(plr, kitchen) end
	elseif kind == "Q" then
		local m = baseByUser[plr.UserId] or assignBase(plr)
		local bank = m and m:FindFirstChild("BankPad")
		if bank then onBank(plr, bank) end
	elseif kind == "R" then
		local bases = root:FindFirstChild("Bases")
		if not bases then return end
		local best, bestDist = nil, Config.StealRange
		for _, m in ipairs(bases:GetChildren()) do
			local owner = m:FindFirstChild("OwnerUserId")
			local bank = m:FindFirstChild("BankPad")
			if owner and owner.Value ~= plr.UserId and bank then
				local dist = (hrp.Position - bank.Position).Magnitude
				if dist < bestDist then best, bestDist = bank, dist end
			end
		end
		if best then onSteal(plr, best) else push(plr, "No rival base nearby.") end
	elseif kind == "P" then
		local chapel = root:FindFirstChild("ChapelOfTheLastBell")
		local altar = chapel and chapel:FindFirstChild("Altar")
		if altar then onRebirth(plr, altar) end
	end
end)

applyDayNight(false)

task.spawn(function()
	while true do
		task.wait(1)
		if os.clock() >= phaseEnds then
			applyDayNight(not night)
			phaseEnds = os.clock() + (night and Config.NightSeconds or Config.DaySeconds)
			for _, plr in ipairs(Players:GetPlayers()) do
				push(plr, night and "Night falls. Steal is open (R)." or "Dawn. Bank meals (Q).")
			end
		else
			for _, plr in ipairs(Players:GetPlayers()) do push(plr) end
		end
	end
end)

task.spawn(function()
	local root = workspace:WaitForChild("VillageBuild", 45)
	if not root then
		warn("[Village] VillageBuild missing — is VillageKeep running?")
		return
	end
	local function hook(inst)
		if inst:IsA("ProximityPrompt") then
			inst.Triggered:Connect(function(plr) handlePrompt(plr, inst) end)
		end
	end
	for _, d in ipairs(root:GetDescendants()) do hook(d) end
	root.DescendantAdded:Connect(hook)
end)

print("[Village] VILLAGE-09 Game ready")
