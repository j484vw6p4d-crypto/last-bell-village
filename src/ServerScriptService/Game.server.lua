--!nocheck
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local profiles = {}
local stallOwner = {}
local night = false
local phaseEnds = os.clock() + Config.DaySeconds

local TASKS = {
	"Pick herbs at WILLOW (E)",
	"Chop wood at ASH (E)",
	"Cook a meal at the INN (F)",
	"Bank coins at YOUR stall (Q)",
	"At night, steal from another stall (R)",
	"Rebirth at the CHAPEL at 80 coins (P)",
}

local function ensure(plr)
	local p = profiles[plr.UserId]
	if not p then
		p = {
			coins = 0,
			herbs = 0,
			wood = 0,
			meals = 0,
			rebirths = 0,
			stallId = nil,
			taskIndex = 1,
		}
		profiles[plr.UserId] = p
	end
	return p
end

local function assignStall(plr)
	local p = ensure(plr)
	if p.stallId then
		return
	end
	for i = 1, 4 do
		if not stallOwner[i] then
			stallOwner[i] = plr.UserId
			p.stallId = i
			return
		end
	end
	p.stallId = ((plr.UserId % 4) + 1)
end

local function push(plr, note)
	local p = ensure(plr)
	Remotes.State:FireClient(plr, {
		build = Config.BuildId,
		night = night,
		coins = p.coins,
		herbs = p.herbs,
		wood = p.wood,
		meals = p.meals,
		rebirths = p.rebirths,
		stallId = p.stallId,
		task = TASKS[math.min(p.taskIndex, #TASKS)],
		seconds = math.max(0, math.floor(phaseEnds - os.clock())),
	})
	if note then
		Remotes.Notify:FireClient(plr, note)
	end
end

local function bumpTask(p, idx)
	if p.taskIndex == idx then
		p.taskIndex = math.min(idx + 1, #TASKS)
	end
end

local function near(plr, inst, range)
	local char = plr.Character
	if not (char and inst) then
		return false
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end
	return (hrp.Position - inst.Position).Magnitude <= (range or Config.StealRange)
end

local function findPromptPart(name)
	local root = workspace:FindFirstChild("VillageBuild")
	if not root then
		return nil
	end
	return root:FindFirstChild(name, true)
end

Players.PlayerAdded:Connect(function(plr)
	assignStall(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.4)
		local spawn = workspace:FindFirstChild("VillageBuild") and workspace.VillageBuild:FindFirstChild("Plaza")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if spawn and hrp then
			hrp.CFrame = spawn.CFrame + Vector3.new(0, 6, 18)
		end
		push(plr, "Welcome to the village. Your stall is #" .. tostring(ensure(plr).stallId))
	end)
	push(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
	local p = profiles[plr.UserId]
	if p and p.stallId and stallOwner[p.stallId] == plr.UserId then
		stallOwner[p.stallId] = nil
	end
	profiles[plr.UserId] = nil
end)

local function onAct(plr, kind)
	local p = ensure(plr)
	if kind == "gather" or kind == "herb" then
		local inst = findPromptPart("Herbs")
		if inst and near(plr, inst, 16) then
			p.herbs += 1
			bumpTask(p, 1)
			push(plr, "Picked herbs (" .. p.herbs .. ")")
			return
		end
	end
	if kind == "gather" or kind == "wood" then
		local inst = findPromptPart("WoodBlock")
		if inst and near(plr, inst, 16) then
			p.wood += 1
			bumpTask(p, 2)
			push(plr, "Chopped wood (" .. p.wood .. ")")
		end
	elseif kind == "cook" then
		local inst = findPromptPart("Kitchen")
		if inst and near(plr, inst, 16) then
			if p.herbs < 1 or p.wood < 1 then
				push(plr, "Need 1 herb and 1 wood to cook")
				return
			end
			p.herbs -= 1
			p.wood -= 1
			p.meals += 1
			p.coins += Config.MealValue
			bumpTask(p, 3)
			push(plr, "Cooked a meal +" .. Config.MealValue .. " coins")
		end
	elseif kind == "bank" then
		local id = p.stallId
		local chest = nil
		local root = workspace:FindFirstChild("VillageBuild")
		if root then
			local stall = root:FindFirstChild("PlayerStalls") and root.PlayerStalls:FindFirstChild("Stall_" .. tostring(id))
			if stall then
				chest = stall:FindFirstChild("StallChest")
			end
		end
		if chest and near(plr, chest, 14) then
			local add = p.herbs * Config.HerbValue + p.wood * Config.WoodValue
			if add <= 0 then
				push(plr, "Satchel empty")
				return
			end
			p.coins += add
			p.herbs = 0
			p.wood = 0
			bumpTask(p, 4)
			push(plr, "Banked goods. Coins " .. p.coins)
		else
			push(plr, "Stand at YOUR stall chest (Q)")
		end
	elseif kind == "steal" then
		if not night then
			push(plr, "Steal is night only")
			return
		end
		local root = workspace:FindFirstChild("VillageBuild")
		local stalls = root and root:FindFirstChild("PlayerStalls")
		if not stalls then
			return
		end
		local stolen = false
		for _, stall in ipairs(stalls:GetChildren()) do
			local chest = stall:FindFirstChild("StallChest")
			if chest and near(plr, chest, 12) then
				local sid = chest:GetAttribute("StallId")
				local ownerId = stallOwner[sid]
				if ownerId == plr.UserId then
					push(plr, "That is your stall")
					return
				end
				if not ownerId then
					push(plr, "Empty stall")
					return
				end
				local victim = profiles[ownerId]
				if victim and victim.coins > 0 then
					local take = math.min(12, math.max(4, math.floor(victim.coins * 0.2)))
					victim.coins -= take
					p.coins += take
					stolen = true
					bumpTask(p, 5)
					push(plr, "Stole " .. take .. " coins")
					local vplr = Players:GetPlayerByUserId(ownerId)
					if vplr then
						push(vplr, plr.DisplayName .. " robbed your stall (-" .. take .. ")")
					end
				else
					push(plr, "Nothing to steal")
				end
				return
			end
		end
		if not stolen then
			push(plr, "Get closer to another player's stall")
		end
	elseif kind == "rebirth" then
		local altar = findPromptPart("Altar")
		if altar and near(plr, altar, 16) then
			if p.coins < Config.BankGoal then
				push(plr, "Need " .. Config.BankGoal .. " coins to rebirth")
				return
			end
			p.coins = 0
			p.herbs = 0
			p.wood = 0
			p.meals = 0
			p.rebirths += 1
			p.taskIndex = 1
			push(plr, "Rebirth " .. p.rebirths .. ". Loop resets.")
		end
	elseif kind == "notice" then
		push(plr, TASKS[math.min(p.taskIndex, #TASKS)])
	end
end

Remotes.Act.OnServerEvent:Connect(function(plr, kind)
	if type(kind) ~= "string" then
		return
	end
	onAct(plr, kind)
end)

task.spawn(function()
	while true do
		task.wait(1)
		if os.clock() >= phaseEnds then
			night = not night
			phaseEnds = os.clock() + (night and Config.NightSeconds or Config.DaySeconds)
			Lighting.ClockTime = night and 0.2 or 16.5
			Lighting.Brightness = night and 0.6 or 2.2
			Lighting.OutdoorAmbient = night and Color3.fromRGB(40, 44, 70) or Color3.fromRGB(140, 130, 110)
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			push(plr)
		end
	end
end)

task.spawn(function()
	local root = workspace:WaitForChild("VillageBuild", 20)
	if not root then
		return
	end
	local function hook(inst)
		if not inst:IsA("ProximityPrompt") then
			return
		end
		inst.Triggered:Connect(function(plr)
			if inst.Name == "HerbPrompt" then
				onAct(plr, "herb")
			elseif inst.Name == "WoodPrompt" then
				onAct(plr, "wood")
			elseif inst.Name == "CookPrompt" then
				onAct(plr, "cook")
			elseif inst.Name == "BankPrompt" then
				onAct(plr, "bank")
			elseif inst.Name == "StealPrompt" then
				onAct(plr, "steal")
			elseif inst.Name == "RebirthPrompt" then
				onAct(plr, "rebirth")
			elseif inst.Name == "NoticePrompt" then
				onAct(plr, "notice")
			end
		end)
	end
	for _, d in ipairs(root:GetDescendants()) do
		hook(d)
	end
	root.DescendantAdded:Connect(hook)
end)
