--!nocheck
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local profiles = {}
local stallByUser = {}
local night = false
local phaseEnds = os.clock() + Config.DaySeconds

local function ensure(plr)
	local p = profiles[plr.UserId]
	if not p then
		p = { coins = 0, herbs = 0, wood = 0, carry = 0, stock = 0, rebirths = 0 }
		profiles[plr.UserId] = p
	end
	return p
end

local function objective(p)
	if p.coins >= Config.BankGoal then
		return "Rebirth at the Chapel (P)"
	end
	if p.carry > 0 then
		return "Bank your meal at your stall (Q)"
	end
	if p.herbs > 0 and p.wood > 0 then
		return "Cook a meal at the Inn (F)"
	end
	if p.herbs <= 0 then
		return "Gather herbs at Willow / Reed dock (E)"
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

local function findStallModel(inst)
	local cur = inst
	while cur and cur ~= workspace do
		if cur:IsA("Model") and string.sub(cur.Name, 1, 5) == "Stall" then
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
		t.Text = string.upper(name) .. " STALL  ·  Q bank / R steal"
	end
end

local function syncStallStock(plr)
	local m = stallByUser[plr.UserId]
	local p = ensure(plr)
	if m then
		local stock = m:FindFirstChild("Stock")
		if stock then
			stock.Value = p.stock
		end
	end
end

local function assignStall(plr)
	local root = workspace:FindFirstChild("VillageBuild")
	if not root then
		return nil
	end
	local stalls = root:FindFirstChild("Stalls")
	if not stalls then
		return nil
	end
	for _, m in ipairs(stalls:GetChildren()) do
		local owner = m:FindFirstChild("OwnerUserId")
		if owner and owner.Value == plr.UserId then
			stallByUser[plr.UserId] = m
			return m
		end
	end
	for _, m in ipairs(stalls:GetChildren()) do
		local owner = m:FindFirstChild("OwnerUserId")
		if owner and owner.Value == 0 then
			owner.Value = plr.UserId
			stallByUser[plr.UserId] = m
			local bank = m:FindFirstChild("BankPad")
			if bank then
				signRefresh(bank, plr.DisplayName)
			end
			return m
		end
	end
	return nil
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
	push(plr, "Meal cooked. Take it to your stall.")
end

local function onBank(plr, pad)
	local p = ensure(plr)
	if night then
		push(plr, "Banking is daytime only.")
		return
	end
	if not near(plr, pad, 14) then
		push(plr, "Stand at your stall counter.")
		return
	end
	local stall = findStallModel(pad)
	if not stall then
		push(plr, "No stall here.")
		return
	end
	local owner = stall:FindFirstChild("OwnerUserId")
	if not owner or owner.Value ~= plr.UserId then
		push(plr, "That is not your stall.")
		return
	end
	if p.carry < 1 then
		push(plr, "Carry a cooked meal first (F at Inn).")
		return
	end
	p.carry -= 1
	local payout = math.floor(Config.MealValue * (1 + 0.25 * p.rebirths))
	p.coins += payout
	push(plr, "Sold meal +" .. payout .. " coins")
end

local function onSteal(plr, pad)
	local p = ensure(plr)
	if not night then
		push(plr, "Stealing is night only.")
		return
	end
	if not near(plr, pad, Config.StealRange) then
		push(plr, "Get closer to their stall.")
		return
	end
	local stall = findStallModel(pad)
	if not stall then
		return
	end
	local owner = stall:FindFirstChild("OwnerUserId")
	if not owner or owner.Value == 0 then
		push(plr, "Empty stall.")
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
		p.carry += 1
		push(plr, "Stole their carried meal!")
		push(victimPlr, plr.DisplayName .. " stole your meal!")
		return
	end
	if victim and victim.coins >= Config.MealValue then
		victim.coins -= Config.MealValue
		p.carry += 1
		push(plr, "Stole a meal's worth from their till!")
		push(victimPlr, plr.DisplayName .. " robbed your stall!")
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
	syncStallStock(plr)
	push(plr, "Rebirth " .. p.rebirths .. "! Meals now pay more.")
end

Players.PlayerAdded:Connect(function(plr)
	ensure(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.35)
		assignStall(plr)
		local plaza = workspace:FindFirstChild("VillageBuild") and workspace.VillageBuild:FindFirstChild("Plaza")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if plaza and hrp then
			hrp.CFrame = plaza.CFrame + Vector3.new(0, 6, 18)
		end
		push(plr, "VILLAGE-03 — gather, cook, bank. Steal only at night.")
	end)
	task.defer(function()
		assignStall(plr)
		push(plr)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	local m = stallByUser[plr.UserId]
	if m then
		local owner = m:FindFirstChild("OwnerUserId")
		if owner then
			owner.Value = 0
		end
		local stock = m:FindFirstChild("Stock")
		if stock then
			stock.Value = 0
		end
		local bank = m:FindFirstChild("BankPad")
		if bank then
			signRefresh(bank, "Open")
		end
	end
	stallByUser[plr.UserId] = nil
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
	local char = plr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
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
		if bestKind == "HerbPrompt" then
			onGatherHerbs(plr, best)
		elseif bestKind == "WoodPrompt" then
			onGatherWood(plr, best)
		end
	elseif kind == "F" then
		local kitchen = root:FindFirstChild("LastBellInn") and root.LastBellInn:FindFirstChild("Kitchen")
		if kitchen then
			onCook(plr, kitchen)
		end
	elseif kind == "Q" then
		local m = stallByUser[plr.UserId] or assignStall(plr)
		local bank = m and m:FindFirstChild("BankPad")
		if bank then
			onBank(plr, bank)
		end
	elseif kind == "R" then
		local stalls = root:FindFirstChild("Stalls")
		if not stalls then
			return
		end
		local best, bestDist = nil, Config.StealRange
		for _, m in ipairs(stalls:GetChildren()) do
			local owner = m:FindFirstChild("OwnerUserId")
			local bank = m:FindFirstChild("BankPad")
			if owner and owner.Value ~= plr.UserId and bank then
				local dist = (hrp.Position - bank.Position).Magnitude
				if dist < bestDist then
					best, bestDist = bank, dist
				end
			end
		end
		if best then
			onSteal(plr, best)
		else
			push(plr, "No rival stall in range.")
		end
	elseif kind == "P" then
		local chapel = root:FindFirstChild("ChapelOfTheLastBell")
		local altar = chapel and chapel:FindFirstChild("Altar")
		if altar then
			onRebirth(plr, altar)
		end
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
				push(plr, night and "Night falls — steal is open (R)." or "Day returns — bank meals (Q).")
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
		if not inst:IsA("ProximityPrompt") then
			return
		end
		inst.Triggered:Connect(function(plr)
			local pad = inst.Parent
			if inst.Name == "HerbPrompt" then
				onGatherHerbs(plr, pad)
			elseif inst.Name == "WoodPrompt" then
				onGatherWood(plr, pad)
			elseif inst.Name == "CookPrompt" then
				onCook(plr, pad)
			elseif inst.Name == "BankPrompt" then
				onBank(plr, pad)
			elseif inst.Name == "StealPrompt" then
				onSteal(plr, pad)
			elseif inst.Name == "RebirthPrompt" then
				onRebirth(plr, pad)
			end
		end)
	end
	for _, d in ipairs(root:GetDescendants()) do
		hook(d)
	end
	root.DescendantAdded:Connect(hook)
end)

print("[Village] VILLAGE-03 Game loop ready")
