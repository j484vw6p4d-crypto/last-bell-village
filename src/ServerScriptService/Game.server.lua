--!nocheck
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
		(p.didCook and "[x] " or "[ ] ") .. "3. Cook meal at Inn (F)",
		(p.didBank and "[x] " or "[ ] ") .. "4. Bank at YOUR base (Q)",
		(p.coins >= Config.BankGoal and "[x] " or "[ ] ") .. "5. Reach " .. Config.BankGoal .. " coins",
		(p.didRebirth and "[x] " or "[ ] ") .. "6. Rebirth at Chapel (P)",
	}
end

local function objective(p)
	if p.coins >= Config.BankGoal then
		return "Chapel altar — press P to rebirth"
	end
	if p.carry > 0 then
		return "Return to YOUR base and bank (Q)"
	end
	if p.herbs > 0 and p.wood > 0 then
		return "Cook at the Inn kitchen (F)"
	end
	if p.herbs <= 0 then
		return "Gather herbs at Willow / Reed (E)"
	end
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
	if note then
		Remotes.Notify:FireClient(plr, note)
	end
end

local function near(plr, inst, range)
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
	if not bill then
		return
	end
	local t = bill:FindFirstChildOfClass("TextLabel")
	if t then
		t.Text = string.upper(name) .. " BASE  ·  Q bank / R steal"
	end
end

local function syncBaseStock(plr)
	local m = baseByUser[plr.UserId]
	local p = ensure(plr)
	if m then
		local stock = m:FindFirstChild("Stock")
		if stock then
			stock.Value = p.stock
		end
	end
end

local function clearCarryVisual(plr)
	local char = plr.Character
	if not char then
		return
	end
	local old = char:FindFirstChild("CarriedMeal")
	if old then
		old:Destroy()
	end
end

local function setCarryVisual(plr, on)
	clearCarryVisual(plr)
	if not on then
		return
	end
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
	meal.Parent = char
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = meal
	weld.Parent = meal
end

local function assignBase(plr)
	local root = workspace:FindFirstChild("VillageBuild")
	if not root then
		return nil
	end
	local bases = root:FindFirstChild("Bases")
	if not bases then
		return nil
	end
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
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not (m and hrp) then
		return
	end
	local spawn = m:FindFirstChild("SpawnPad")
	if spawn then
		hrp.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

local function onGatherHerbs(plr, pad)
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
	push(plr, "Herbs " .. p.herbs .. "/" .. Config.MaxHerbs)
end

local function onGatherWood(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then
		push(plr, "Get closer to the woodpile.")
		return
	end
	if p.wood >= Config.MaxWood then
		push(plr, "Wood bundle full.")
		return
	end
	p.wood += 1
	p.didWood = true
	push(plr, "Wood " .. p.wood .. "/" .. Config.MaxWood)
end

local function onCook(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 16) then
		push(plr, "Stand at the kitchen.")
		return
	end
	if p.carry >= Config.MaxCarry then
		push(plr, "You already carry a meal. Bank it (Q).")
		return
	end
	if p.herbs < 1 or p.wood < 1 then
		push(plr, "Need 1 herb and 1 wood to cook.")
		return
	end
	p.herbs -= 1
	p.wood -= 1
	p.carry += 1
	p.didCook = true
	setCarryVisual(plr, true)
	push(plr, "Meal cooked! Take it to YOUR base (Q).")
end

local function onBank(plr, pad)
	local p = ensure(plr)
	if night then
		push(plr, "Banking is daytime only.")
		return
	end
	if not near(plr, pad, 14) then
		push(plr, "Stand at your base counter.")
		return
	end
	local base = findBaseModel(pad)
	if not base then
		push(plr, "No base here.")
		return
	end
	local owner = base:FindFirstChild("OwnerUserId")
	if not owner or owner.Value ~= plr.UserId then
		push(plr, "That is not your base.")
		return
	end
	if p.carry < 1 then
		push(plr, "Carry a cooked meal first (F at Inn).")
		return
	end
	p.carry -= 1
	clearCarryVisual(plr)
	local payout = math.floor(Config.MealValue * (1 + 0.25 * p.rebirths))
	p.coins += payout
	p.didBank = true
	syncBaseStock(plr)
	push(plr, "Sold +" .. payout .. " (" .. p.coins .. "/" .. Config.BankGoal .. ")")
end

local function onSteal(plr, pad)
	local p = ensure(plr)
	if not night then
		push(plr, "Stealing is night only.")
		return
	end
	if not near(plr, pad, Config.StealRange) then
		push(plr, "Get closer to their base.")
		return
	end
	local base = findBaseModel(pad)
	if not base then
		return
	end
	local owner = base:FindFirstChild("OwnerUserId")
	if not owner or owner.Value == 0 then
		push(plr, "Empty base.")
		return
	end
	if owner.Value == plr.UserId then
		push(plr, "You cannot steal from yourself.")
		return
	end
	if p.carry >= Config.MaxCarry then
		push(plr, "Hands full. Bank your meal first.")
		return
	end
	local victimPlr = Players:GetPlayerByUserId(owner.Value)
	local victim = victimPlr and ensure(victimPlr) or nil
	if victim and victim.carry > 0 then
		victim.carry -= 1
		clearCarryVisual(victimPlr)
		p.carry += 1
		setCarryVisual(plr, true)
		push(plr, "Stole their carried meal!")
		push(victimPlr, plr.DisplayName .. " stole your meal!")
		return
	end
	if victim and victim.coins >= Config.MealValue then
		victim.coins -= Config.MealValue
		p.carry += 1
		setCarryVisual(plr, true)
		push(plr, "Stole from their till!")
		push(victimPlr, plr.DisplayName .. " robbed your base!")
		return
	end
	push(plr, "Nothing to steal.")
end

local function onRebirth(plr, pad)
	local p = ensure(plr)
	if not near(plr, pad, 18) then
		push(plr, "Stand at the chapel altar.")
		return
	end
	if p.coins < Config.BankGoal then
		push(plr, "Need " .. Config.BankGoal .. " coins to rebirth.")
		return
	end
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
	clearCarryVisual(plr)
	syncBaseStock(plr)
	push(plr, "Rebirth " .. p.rebirths .. "! Meals now pay more.")
	teleportToBase(plr)
end

Players.PlayerAdded:Connect(function(plr)
	ensure(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.4)
		assignBase(plr)
		teleportToBase(plr)
		local p = ensure(plr)
		setCarryVisual(plr, p.carry > 0)
		push(plr, "This base is yours. Follow the task list.")
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
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if kind == "E" then
		local best, bestDist, bestKind = nil, 20, nil
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("ProximityPrompt") and (d.Name == "HerbPrompt" or d.Name == "WoodPrompt") then
				local pad = d.Parent
				if pad and pad:IsA("BasePart") then
					local dist = (hrp.Position - pad.Position).Magnitude
					if dist < bestDist then
						best, bestDist, bestKind = pad, dist, d.Name
					end
				end
			end
		end
		if bestKind == "HerbPrompt" then onGatherHerbs(plr, best)
		elseif bestKind == "WoodPrompt" then onGatherWood(plr, best) end
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
		if best then onSteal(plr, best) else push(plr, "No rival base in range.") end
	elseif kind == "P" then
		local chapel = root:FindFirstChild("ChapelOfTheLastBell")
		local altar = chapel and chapel:FindFirstChild("Altar")
		if altar then onRebirth(plr, altar) end
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		if os.clock() >= phaseEnds then
			night = not night
			phaseEnds = os.clock() + (night and Config.NightSeconds or Config.DaySeconds)
			Lighting.ClockTime = night and 0.15 or 16.5
			Lighting.Brightness = night and 0.55 or 2.2
			Lighting.OutdoorAmbient = night and Color3.fromRGB(40, 44, 70) or Color3.fromRGB(140, 130, 110)
			for _, plr in ipairs(Players:GetPlayers()) do
				push(plr, night and "Night — steal from rival bases (R)." or "Day — bank at your base (Q).")
			end
		else
			for _, plr in ipairs(Players:GetPlayers()) do
				push(plr)
			end
		end
	end
end)

task.spawn(function()
	local root = workspace:WaitForChild("VillageBuild", 30)
	if not root then
		warn("[Village] VillageBuild missing")
		return
	end
	local function hook(inst)
		if not inst:IsA("ProximityPrompt") then return end
		inst.Triggered:Connect(function(plr)
			local pad = inst.Parent
			if inst.Name == "HerbPrompt" then onGatherHerbs(plr, pad)
			elseif inst.Name == "WoodPrompt" then onGatherWood(plr, pad)
			elseif inst.Name == "CookPrompt" then onCook(plr, pad)
			elseif inst.Name == "BankPrompt" then onBank(plr, pad)
			elseif inst.Name == "StealPrompt" then onSteal(plr, pad)
			elseif inst.Name == "RebirthPrompt" then onRebirth(plr, pad) end
		end)
	end
	for _, d in ipairs(root:GetDescendants()) do hook(d) end
	root.DescendantAdded:Connect(hook)
end)

print("[Village] VILLAGE-04 Game loop ready")
