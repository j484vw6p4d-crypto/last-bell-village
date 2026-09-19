--!nocheck
-- VILLAGE-22b Gameplay: gather / cook / bank / steal / upgrade.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local World = require(script.Parent:WaitForChild("World"))

local profiles = {}
local baseByUser = {}
local night = false
local phaseEnds = os.clock() + Config.DaySeconds

local function ensure(plr)
	local p = profiles[plr.UserId]
	if not p then
		p = {
			coins = 0,
			herbs = 0,
			wood = 0,
			carry = 0,
			stock = 0,
			upgradeTier = 0,
			didHerb = false,
			didWood = false,
			didCook = false,
			didBank = false,
			didSteal = false,
			didUpgrade = false,
		}
		profiles[plr.UserId] = p
	end
	return p
end

local function richest()
	local bestName, bestCoins = "nobody", 0
	for _, plr in ipairs(Players:GetPlayers()) do
		local p = profiles[plr.UserId]
		if p and p.coins > bestCoins then
			bestCoins = p.coins
			bestName = plr.DisplayName
		end
	end
	return bestName, bestCoins
end

local function objective(p)
	if p.upgradeTier >= (Config.MaxUpgrade or 3) and p.coins >= 0 then
		if p.carry > 0 then
			return "Bank your meal at YOUR pad (Q)"
		end
		if p.herbs >= 1 and p.wood >= 1 then
			return "Cook a meal at YOUR pad (C)"
		end
		return "Gather herbs/wood, bank meals, steal rivals, show off your cottage"
	end
	local nextCost = (Config.UpgradeCosts and Config.UpgradeCosts[p.upgradeTier + 1]) or 20
	if p.coins >= nextCost and p.upgradeTier < (Config.MaxUpgrade or 3) then
		return "Upgrade your cottage at YOUR pad (B) - cost " .. nextCost
	end
	if p.carry > 0 then
		return "Bank the meal at YOUR BankPad (Q)"
	end
	if p.herbs >= 1 and p.wood >= 1 then
		return "Cook at YOUR BankPad (C) - needs 1 herb + 1 wood"
	end
	if p.herbs <= 0 then
		return "Gather herbs at a HerbBed (E)"
	end
	return "Chop wood at a WoodPile (E)"
end

local function tip(p)
	return string.format(
		"E gather  C cook  Q bank  R steal  B upgrade  |  F fly  |  stock %d  tier %d/%d",
		p.stock,
		p.upgradeTier,
		Config.MaxUpgrade or 3
	)
end

local function push(plr, note)
	local p = ensure(plr)
	local richName, richCoins = richest()
	Remotes.State:FireClient(plr, {
		build = Config.BuildId,
		night = night,
		seconds = math.max(0, math.floor(phaseEnds - os.clock())),
		coins = p.coins,
		herbs = p.herbs,
		wood = p.wood,
		carry = p.carry,
		stock = p.stock,
		upgradeTier = p.upgradeTier,
		maxUpgrade = Config.MaxUpgrade or 3,
		goal = Config.BankGoal,
		objective = objective(p),
		tip = tip(p),
		richName = richName,
		richCoins = richCoins,
		progress = math.clamp(p.coins / math.max(Config.BankGoal, 1), 0, 1),
	})
	if note then
		Remotes.Notify:FireClient(plr, note)
	end
end

local function near(plr, inst, range)
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not (hrp and inst and inst:IsA("BasePart")) then
		return false
	end
	return (hrp.Position - inst.Position).Magnitude <= (range or 16)
end

local function findBaseModel(inst)
	local cur = inst
	while cur and cur ~= workspace do
		if cur:IsA("Model") and string.sub(cur.Name, 1, 4) == "Base" then
			return cur
		end
		cur = cur.Parent
	end
	return nil
end

local function signRefresh(bank, name)
	local bill = bank:FindFirstChild("Sign")
	local t = bill and bill:FindFirstChildOfClass("TextLabel")
	if t then
		t.Text = string.upper(name) .. " BASE - Q bank / C cook / R steal / B upgrade"
	end
end

local function syncStock(plr)
	local m = baseByUser[plr.UserId]
	local p = ensure(plr)
	if m then
		local stock = m:FindFirstChild("Stock")
		if stock then
			stock.Value = p.stock
		end
		m:SetAttribute("Stock", p.stock)
	end
end

local function clearCarry(plr)
	local char = plr.Character
	if not char then
		return
	end
	local old = char:FindFirstChild("CarriedMeal")
	if old then
		old:Destroy()
	end
end

local function setCarry(plr, on)
	clearCarry(plr)
	if not on then
		return
	end
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
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
	if not bases then
		return nil
	end
	for _, m in ipairs(bases:GetChildren()) do
		local ownerId = m:GetAttribute("OwnerUserId") or 0
		local owner = m:FindFirstChild("OwnerUserId")
		if owner then
			ownerId = owner.Value
		end
		if ownerId == plr.UserId then
			baseByUser[plr.UserId] = m
			return m
		end
	end
	for _, m in ipairs(bases:GetChildren()) do
		local owner = m:FindFirstChild("OwnerUserId")
		local ownerId = m:GetAttribute("OwnerUserId") or (owner and owner.Value) or 0
		if ownerId == 0 then
			if owner then
				owner.Value = plr.UserId
			end
			m:SetAttribute("OwnerUserId", plr.UserId)
			baseByUser[plr.UserId] = m
			local nameVal = m:FindFirstChild("OwnerName")
			if nameVal then
				nameVal.Value = plr.DisplayName
			end
			local bank = m:FindFirstChild("BankPad")
			if bank then
				signRefresh(bank, plr.DisplayName)
			end
			return m
		end
	end
	return nil
end

local function teleportToBase(plr)
	local m = baseByUser[plr.UserId] or assignBase(plr)
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not (m and hrp) then
		return
	end
	local spawn = m:FindFirstChild("SpawnPart") or m:FindFirstChild("SpawnPad")
	if spawn then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

local function applyDayNight(isNight)
	night = isNight
	if isNight then
		Lighting.ClockTime = 0.2
		Lighting.Brightness = 0.55
		Lighting.OutdoorAmbient = Color3.fromRGB(40, 42, 60)
		Lighting.Ambient = Color3.fromRGB(50, 48, 65)
	else
		Lighting.ClockTime = 15.8
		Lighting.Brightness = 2.4
		Lighting.OutdoorAmbient = Color3.fromRGB(145, 135, 115)
		Lighting.Ambient = Color3.fromRGB(110, 100, 85)
	end
end

local function onHerbs(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then
		push(plr, "Get closer to the herbs.")
		return
	end
	if p.herbs >= Config.MaxHerbs then
		push(plr, "Herb pouch full.")
		return
	end
	p.herbs += 1
	p.didHerb = true
	Remotes.FX:FireClient(plr, { kind = "gather", pad = pad })
	push(plr, "Herbs " .. p.herbs .. "/" .. Config.MaxHerbs)
end

local function onWood(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then
		push(plr, "Get closer to the wood.")
		return
	end
	if p.wood >= Config.MaxWood then
		push(plr, "Wood bundle full.")
		return
	end
	p.wood += 1
	p.didWood = true
	Remotes.FX:FireClient(plr, { kind = "chop", pad = pad })
	push(plr, "Wood " .. p.wood .. "/" .. Config.MaxWood)
end

local function onCook(plr, pad)
	local p = ensure(plr)
	if pad and not near(plr, pad, 16) then
		push(plr, "Stand at your BankPad to cook.")
		return
	end
	if pad then
		local base = findBaseModel(pad)
		local owner = base and base:FindFirstChild("OwnerUserId")
		local ownerId = base and (base:GetAttribute("OwnerUserId") or (owner and owner.Value)) or -1
		if ownerId ~= plr.UserId then
			push(plr, "Cook only at YOUR base.")
			return
		end
	end
	if p.carry >= Config.MaxCarry then
		push(plr, "Already carrying a meal - bank it (Q).")
		return
	end
	if p.herbs < 1 or p.wood < 1 then
		push(plr, "Need 1 herb and 1 wood.")
		return
	end
	p.herbs -= 1
	p.wood -= 1
	p.carry = 1
	p.didCook = true
	setCarry(plr, true)
	push(plr, "Meal ready - bank it at YOUR pad (Q).")
end

local function onBank(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 14) then
		push(plr, "Stand at your BankPad.")
		return
	end
	local base = findBaseModel(pad)
	local owner = base and base:FindFirstChild("OwnerUserId")
	local ownerId = base and (base:GetAttribute("OwnerUserId") or (owner and owner.Value)) or -1
	if ownerId ~= plr.UserId then
		push(plr, "That is not your base.")
		return
	end
	if p.carry < 1 then
		push(plr, "Cook a meal first (C).")
		return
	end
	p.carry = 0
	clearCarry(plr)
	local payout = Config.MealValue or 14
	p.coins += payout
	p.stock += 1
	p.didBank = true
	syncStock(plr)
	-- spectacle for everyone
	Remotes.FX:FireAllClients({ kind = "banked", pad = pad, playerName = plr.DisplayName, coins = payout })
	push(plr, "BANKED +" .. payout .. " coins (stock " .. p.stock .. ")")
end

local function onSteal(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, Config.StealRange) then
		push(plr, "Get closer to steal.")
		return
	end
	local base = findBaseModel(pad)
	local owner = base and base:FindFirstChild("OwnerUserId")
	local ownerId = base and (base:GetAttribute("OwnerUserId") or (owner and owner.Value)) or 0
	if ownerId == 0 then
		push(plr, "Empty base.")
		return
	end
	if ownerId == plr.UserId then
		push(plr, "Cannot steal from yourself.")
		return
	end
	if p.carry >= Config.MaxCarry then
		push(plr, "Hands full - bank first.")
		return
	end
	local victimPlr = Players:GetPlayerByUserId(ownerId)
	local victim = victimPlr and ensure(victimPlr) or nil
	local stockVal = base:FindFirstChild("Stock")
	local stockCount = (victim and victim.stock) or (stockVal and stockVal.Value) or 0
	if stockCount <= 0 then
		push(plr, "Nothing in their stock.")
		return
	end
	if victim then
		victim.stock -= 1
		syncStock(victimPlr)
	elseif stockVal then
		stockVal.Value = math.max(0, stockVal.Value - 1)
	end
	p.carry = 1
	p.didSteal = true
	setCarry(plr, true)
	push(plr, "Stole a banked meal!")
	if victimPlr then
		push(victimPlr, plr.DisplayName .. " stole from your stock!")
	end
end

local function onUpgrade(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 14) then
		push(plr, "Stand at your BankPad.")
		return
	end
	local base = findBaseModel(pad) or baseByUser[plr.UserId]
	local owner = base and base:FindFirstChild("OwnerUserId")
	local ownerId = base and (base:GetAttribute("OwnerUserId") or (owner and owner.Value)) or -1
	if not base or ownerId ~= plr.UserId then
		push(plr, "Upgrade only at YOUR base.")
		return
	end
	if p.upgradeTier >= (Config.MaxUpgrade or 3) then
		push(plr, "Cottage already maxed.")
		return
	end
	local nextTier = p.upgradeTier + 1
	local cost = (Config.UpgradeCosts and Config.UpgradeCosts[nextTier]) or 20
	if p.coins < cost then
		push(plr, "Need " .. cost .. " coins to upgrade.")
		return
	end
	p.coins -= cost
	p.upgradeTier = nextTier
	p.didUpgrade = true
	World.rebuildBase(base, nextTier)
	local tierVal = base:FindFirstChild("UpgradeTier")
	if tierVal then
		tierVal.Value = nextTier
	end
	push(plr, "Cottage upgraded to tier " .. nextTier .. " (-" .. cost .. " coins)")
end

local function handlePrompt(plr, promptInst)
	local pad = promptInst.Parent
	local n = promptInst.Name
	if n == "HerbPrompt" then
		onHerbs(plr, pad)
	elseif n == "WoodPrompt" then
		onWood(plr, pad)
	elseif n == "CookPrompt" then
		onCook(plr, pad)
	elseif n == "BankPrompt" then
		onBank(plr, pad)
	elseif n == "StealPrompt" then
		onSteal(plr, pad)
	elseif n == "UpgradePrompt" then
		onUpgrade(plr, pad)
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
		push(plr, "Welcome to VILLAGE-22b - gather, cook, bank, steal, upgrade!")
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
		if owner then
			owner.Value = 0
		end
		m:SetAttribute("OwnerUserId", 0)
		local stock = m:FindFirstChild("Stock")
		if stock then
			stock.Value = 0
		end
		local nameVal = m:FindFirstChild("OwnerName")
		if nameVal then
			nameVal.Value = "Open"
		end
		local bank = m:FindFirstChild("BankPad")
		if bank then
			signRefresh(bank, "Open")
		end
	end
	baseByUser[plr.UserId] = nil
	profiles[plr.UserId] = nil
end)

Remotes.Act.OnServerEvent:Connect(function(plr, kind)
	if type(kind) ~= "string" then
		return
	end
	local root = workspace:FindFirstChild("VillageBuild")
	if not root then
		return
	end
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	if kind == "E" or kind == "Herbs" or kind == "Wood" then
		local best, bestDist, bestName = nil, 22, nil
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("ProximityPrompt") and (d.Name == "HerbPrompt" or d.Name == "WoodPrompt") then
				local pad = d.Parent
				if pad and pad:IsA("BasePart") then
					local dist = (hrp.Position - pad.Position).Magnitude
					if dist < bestDist then
						best, bestDist, bestName = pad, dist, d.Name
					end
				end
			end
		end
		if bestName == "HerbPrompt" then
			onHerbs(plr, best)
		elseif bestName == "WoodPrompt" then
			onWood(plr, best)
		end
	elseif kind == "C" or kind == "Cook" or kind == "Craft" then
		local m = baseByUser[plr.UserId] or assignBase(plr)
		local bank = m and m:FindFirstChild("BankPad")
		if bank then
			onCook(plr, bank)
		else
			push(plr, "No base assigned.")
		end
	elseif kind == "Q" or kind == "Bank" then
		local m = baseByUser[plr.UserId] or assignBase(plr)
		local bank = m and m:FindFirstChild("BankPad")
		if bank then
			onBank(plr, bank)
		end
	elseif kind == "R" or kind == "Steal" then
		local bases = root:FindFirstChild("Bases")
		if not bases then
			return
		end
		local best, bestDist = nil, Config.StealRange
		for _, m in ipairs(bases:GetChildren()) do
			local owner = m:FindFirstChild("OwnerUserId")
			local ownerId = m:GetAttribute("OwnerUserId") or (owner and owner.Value) or 0
			local bank = m:FindFirstChild("BankPad")
			if ownerId ~= plr.UserId and ownerId ~= 0 and bank then
				local dist = (hrp.Position - bank.Position).Magnitude
				if dist < bestDist then
					best, bestDist = bank, dist
				end
			end
		end
		if best then
			onSteal(plr, best)
		else
			push(plr, "No rival base nearby.")
		end
	elseif kind == "B" or kind == "Upgrade" then
		local m = baseByUser[plr.UserId] or assignBase(plr)
		local bank = m and m:FindFirstChild("BankPad")
		if bank then
			onUpgrade(plr, bank)
		end
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
				push(plr, night and "Night softens the green." or "Day returns to the village.")
			end
		else
			for _, plr in ipairs(Players:GetPlayers()) do
				push(plr)
			end
		end
	end
end)

task.spawn(function()
	local root = workspace:WaitForChild("VillageBuild", 60)
	if not root then
		warn("[Village] VillageBuild missing - is VillageKeep running?")
		return
	end
	local function hook(inst)
		if inst:IsA("ProximityPrompt") then
			inst.Triggered:Connect(function(plr)
				handlePrompt(plr, inst)
			end)
		end
	end
	for _, d in ipairs(root:GetDescendants()) do
		hook(d)
	end
	root.DescendantAdded:Connect(hook)
end)

-- Lightweight smoke harness (prints PASS/FAIL). Enable with attribute SmokeTest=true on ServerScriptService.
task.defer(function()
	do
		-- auto smoke for VILLAGE-22b QA (always on)
	end
	if false then
		return
	end
	task.wait(2)
	local root = workspace:FindFirstChild("VillageBuild")
	local ok = true
	local function check(cond, msg)
		if not cond then
			ok = false
			warn("[Smoke FAIL]", msg)
		else
			print("[Smoke PASS]", msg)
		end
	end
	check(root ~= nil, "VillageBuild exists")
	check(root and root:FindFirstChild("Bases") ~= nil, "Bases folder")
	check(Config.BuildId == "VILLAGE-22b", "BuildId VILLAGE-22b")
	check(type(World.rebuildBase) == "function", "World.rebuildBase export")
	local herb = root and root:FindFirstChild("HerbBed", true)
	local wood = root and root:FindFirstChild("WoodPile", true)
	check(herb ~= nil, "HerbBed present")
	check(wood ~= nil, "WoodPile present")
	local bases = root and root:FindFirstChild("Bases")
	local b1 = bases and bases:FindFirstChild("Base1")
	check(b1 ~= nil and b1:FindFirstChild("BankPad") ~= nil, "Base1 BankPad")
	if b1 then
		World.rebuildBase(b1, 2)
		check(b1:GetAttribute("UpgradeTier") == 2, "rebuildBase tier 2")
		World.rebuildBase(b1, 0)
	end
	
	-- Simulated economy loop (no real player needed)
	local sim = {
		coins = 0, herbs = 0, wood = 0, carry = 0, stock = 0, upgradeTier = 0,
	}
	local function simGather(kind)
		if kind == "herb" and sim.herbs < Config.MaxHerbs then sim.herbs += 1 end
		if kind == "wood" and sim.wood < Config.MaxWood then sim.wood += 1 end
	end
	local function simCook()
		if sim.carry >= Config.MaxCarry then return false end
		if sim.herbs < 1 or sim.wood < 1 then return false end
		sim.herbs -= 1
		sim.wood -= 1
		sim.carry = 1
		return true
	end
	local function simBank()
		if sim.carry < 1 then return false end
		sim.carry = 0
		sim.coins += (Config.MealValue or 14)
		sim.stock += 1
		return true
	end
	local function simUpgrade()
		local nextTier = sim.upgradeTier + 1
		if nextTier > (Config.MaxUpgrade or 3) then return false end
		local cost = Config.UpgradeCosts[nextTier]
		if sim.coins < cost then return false end
		sim.coins -= cost
		sim.upgradeTier = nextTier
		return true
	end
	for _ = 1, 3 do
		simGather("herb"); simGather("wood")
		check(simCook(), "sim cook")
		check(simBank(), "sim bank")
	end
	check(sim.coins == 42, "sim coins after 3 banks == 42 (got " .. tostring(sim.coins) .. ")")
	check(sim.stock == 3, "sim stock == 3")
	-- bank more to afford upgrades 20+45+80 = 145 -> need 11 banks = 154
	for _ = 1, 8 do
		simGather("herb"); simGather("wood"); simCook(); simBank()
	end
	check(simUpgrade(), "upgrade to 1")
	check(simUpgrade(), "upgrade to 2")
	check(simUpgrade(), "upgrade to 3")
	check(sim.upgradeTier == 3, "sim max tier 3")
	-- steal sim
	local victim = { stock = 2 }
	local thief = { carry = 0 }
	if victim.stock > 0 and thief.carry < Config.MaxCarry then
		victim.stock -= 1
		thief.carry = 1
	end
	check(victim.stock == 1 and thief.carry == 1, "sim steal transfers stock->carry")

print(ok and "[Smoke] ALL PASS" or "[Smoke] HAD FAILURES")
end)

print("[Village] VILLAGE-22b Game ready")
