--!nocheck
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local STEPS = {
	{
		id = "square",
		title = "Hear the Mayor",
		hint = "Go to Millbrook Square and talk to Mayor Alden.",
		prompt = "SquarePrompt",
		complete = "The chapel has been silent. Walk the village and gather what the bell needs.",
	},
	{
		id = "inn",
		title = "Ask at the Inn",
		hint = "Visit Last Bell Inn and speak with Mira.",
		prompt = "InnPrompt",
		complete = "Mira says the spare rope is in Old Bram's loft at Ash Cottage — after you see the smith.",
	},
	{
		id = "reeds",
		title = "Cut River Reeds",
		hint = "Pick 5 river reeds around Reed House.",
		prompt = "ReedPrompt",
		need = 5,
		item = "reeds",
		complete = "You bundled five river reeds for the smith.",
	},
	{
		id = "smithy",
		title = "Forge the Clapper",
		hint = "Bring the reeds to Smith Rowan at Millbrook Smithy.",
		prompt = "SmithyPrompt",
		needItem = "reeds",
		needCount = 5,
		give = "clapper",
		complete = "Rowan forged the Bell Clapper.",
	},
	{
		id = "willow",
		title = "Blessing Oil",
		hint = "Ask Willow at Willow Home for oil.",
		prompt = "WillowPrompt",
		give = "oil",
		complete = "Willow gave you Blessing Oil.",
	},
	{
		id = "ash",
		title = "The Spare Rope",
		hint = "Search the loft chest at Ash Cottage.",
		prompt = "AshPrompt",
		give = "rope",
		complete = "You recovered the spare bell rope.",
	},
	{
		id = "chapel",
		title = "Ring the Last Bell",
		hint = "Return to the Chapel with clapper, oil, and rope.",
		prompt = "ChapelPrompt",
		needAll = { "clapper", "oil", "rope" },
		ending = true,
		complete = "The Last Bell rings over Millbrook.",
	},
}

local profiles = {}
local night = false
local phaseEnds = os.clock() + Config.DaySeconds

local function ensure(plr)
	local p = profiles[plr.UserId]
	if not p then
		p = {
			step = 1,
			reeds = 0,
			clapper = 0,
			oil = 0,
			rope = 0,
			won = false,
			picked = {},
		}
		profiles[plr.UserId] = p
	end
	return p
end

local function stepOf(p)
	return STEPS[p.step]
end

local function push(plr, note)
	local p = ensure(plr)
	local st = stepOf(p)
	Remotes.State:FireClient(plr, {
		build = Config.BuildId,
		night = night,
		seconds = math.max(0, math.floor(phaseEnds - os.clock())),
		task = p.won and "Festival restored. Walk Millbrook." or (st and st.title or "Done"),
		hint = p.won and "The Last Bell is ringing." or (st and st.hint or ""),
		step = p.step,
		total = #STEPS,
		won = p.won,
		reeds = p.reeds,
		clapper = p.clapper,
		oil = p.oil,
		rope = p.rope,
	})
	if note then
		Remotes.Notify:FireClient(plr, note)
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
	return (hrp.Position - inst.Position).Magnitude <= (range or 16)
end

Players.PlayerAdded:Connect(function(plr)
	ensure(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.4)
		local spawn = workspace:FindFirstChild("VillageBuild") and workspace.VillageBuild:FindFirstChild("Plaza")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if spawn and hrp then
			hrp.CFrame = spawn.CFrame + Vector3.new(0, 6, 18)
		end
		push(plr, "The Last Bell is silent. Start at the square.")
	end)
	push(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
	profiles[plr.UserId] = nil
end)

local function advance(plr, p, st)
	if st.give then
		p[st.give] = 1
	end
	if st.ending then
		p.won = true
		push(plr, st.complete)
		return
	end
	p.step = math.min(p.step + 1, #STEPS)
	push(plr, st.complete)
end

local function onAct(plr, kind, inst)
	local p = ensure(plr)
	if p.won then
		push(plr, "The bell already rings.")
		return
	end
	local st = stepOf(p)
	if not st then
		return
	end

	if kind == "reed" then
		if st.id ~= "reeds" then
			push(plr, "You do not need reeds yet.")
			return
		end
		if inst and p.picked[inst] then
			return
		end
		if inst and not near(plr, inst, 14) then
			push(plr, "Get closer to the reed bed.")
			return
		end
		if inst then
			p.picked[inst] = true
		end
		p.reeds += 1
		if p.reeds >= (st.need or 5) then
			advance(plr, p, st)
		else
			push(plr, string.format("River Reed %d / %d", p.reeds, st.need or 5))
		end
		return
	end

	if kind ~= st.prompt and kind ~= st.id then
		push(plr, "Not yet. " .. st.hint)
		return
	end

	if st.needItem and (p[st.needItem] or 0) < (st.needCount or 1) then
		push(plr, "Bring the river reeds first.")
		return
	end

	if st.needAll then
		for _, id in ipairs(st.needAll) do
			if (p[id] or 0) < 1 then
				push(plr, "You are still missing a piece of the bell.")
				return
			end
		end
	end

	advance(plr, p, st)
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
			if inst.Name == "ReedPrompt" then
				onAct(plr, "reed", inst.Parent)
			else
				onAct(plr, inst.Name, inst.Parent)
			end
		end)
	end
	for _, d in ipairs(root:GetDescendants()) do
		hook(d)
	end
	root.DescendantAdded:Connect(hook)
end)
