--!nocheck
-- Chop / gather / BANKED spectacle FX.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VillageRemotes")
local FX = remotes:WaitForChild("FX")

local function playChopAnim(character)
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://522635514"
	local ok, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	if ok and track then
		track.Priority = Enum.AnimationPriority.Action
		track:Play(0.05, 1, 1.15)
		task.delay(0.7, function()
			if track.IsPlaying then
				track:Stop(0.15)
			end
			anim:Destroy()
		end)
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local right = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if hrp then
		local axe = Instance.new("Model")
		axe.Name = "TempAxe"
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.35, 2.4, 0.35)
		handle.Color = Color3.fromRGB(92, 62, 32)
		handle.Material = Enum.Material.Wood
		handle.CanCollide = false
		handle.Massless = true
		handle.Parent = axe
		local head = Instance.new("Part")
		head.Size = Vector3.new(1.4, 0.9, 0.25)
		head.Color = Color3.fromRGB(140, 145, 155)
		head.Material = Enum.Material.Metal
		head.CanCollide = false
		head.Massless = true
		head.CFrame = handle.CFrame * CFrame.new(0, 1.3, 0)
		head.Parent = axe
		local weldHead = Instance.new("WeldConstraint")
		weldHead.Part0 = handle
		weldHead.Part1 = head
		weldHead.Parent = handle
		axe.PrimaryPart = handle
		axe.Parent = character
		local attachTo = right or hrp
		local weld = Instance.new("Weld")
		weld.Part0 = attachTo
		weld.Part1 = handle
		if right and right.Name == "RightHand" then
			weld.C0 = CFrame.new(0, -0.2, -0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(90))
		else
			weld.C0 = CFrame.new(1.2, 0.4, -0.8) * CFrame.Angles(0, 0, math.rad(90))
		end
		weld.Parent = handle
		task.delay(0.85, function()
			axe:Destroy()
		end)
	end
end

local function shakePile(pad)
	if not (pad and pad.Parent) then
		return
	end
	local model = pad:FindFirstAncestorOfClass("Model") or pad.Parent
	local parts = {}
	if model and model:IsA("Model") then
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") and (d.Name:find("Log") or d.Name:find("Leaf") or d.Name == pad.Name) then
				table.insert(parts, d)
			end
		end
	end
	if #parts == 0 and pad:IsA("BasePart") then
		table.insert(parts, pad)
	end
	for _, p in ipairs(parts) do
		local baseCF = p.CFrame
		task.spawn(function()
			for _ = 1, 5 do
				local jitter = CFrame.new(
					(math.random() - 0.5) * 0.35,
					(math.random() - 0.5) * 0.2,
					(math.random() - 0.5) * 0.35
				) * CFrame.Angles(0, math.rad((math.random() - 0.5) * 12), 0)
				p.CFrame = baseCF * jitter
				task.wait(0.04)
			end
			p.CFrame = baseCF
		end)
	end
end

local function bankedSpectacle(pad, playerName)
	local pos
	if pad and pad:IsA("BasePart") then
		pos = pad.Position + Vector3.new(0, 4, 0)
	else
		local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
		pos = hrp and hrp.Position or Vector3.new(0, 10, 0)
	end
	local anchor = Instance.new("Part")
	anchor.Name = "BankedFX"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = pos
	anchor.Parent = workspace

	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.fromOffset(320, 80)
	bill.StudsOffset = Vector3.new(0, 3, 0)
	bill.AlwaysOnTop = true
	bill.Parent = anchor
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.fromScale(1, 1)
	lab.BackgroundTransparency = 1
	lab.Font = Enum.Font.GothamBold
	lab.TextScaled = true
	lab.TextColor3 = Color3.fromRGB(255, 230, 120)
	lab.TextStrokeTransparency = 0.3
	lab.Text = "BANKED!"
	lab.Parent = bill

	local att = Instance.new("Attachment")
	att.Parent = anchor
	local p = Instance.new("ParticleEmitter")
	p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	p.Rate = 0
	p.Lifetime = NumberRange.new(0.6, 1.2)
	p.Speed = NumberRange.new(8, 18)
	p.SpreadAngle = Vector2.new(180, 180)
	p.Color = ColorSequence.new(Color3.fromRGB(255, 200, 80), Color3.fromRGB(255, 140, 40))
	p.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.2),
		NumberSequenceKeypoint.new(1, 0),
	})
	p.Parent = att
	p:Emit(40)

	TweenService:Create(lab, TweenInfo.new(1.2), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(1.5, function()
		anchor:Destroy()
	end)
end

FX.OnClientEvent:Connect(function(payload, maybePad)
	local kind, pad
	if type(payload) == "table" then
		kind = payload.kind
		pad = payload.pad
	else
		kind = payload
		pad = maybePad
	end
	local char = plr.Character
	if kind == "chop" then
		playChopAnim(char)
		shakePile(pad)
	elseif kind == "gather" then
		shakePile(pad)
		playChopAnim(char)
	elseif kind == "banked" then
		bankedSpectacle(pad, type(payload) == "table" and payload.playerName or nil)
	end
end)

print("[Village] HarvestFX ready (chop / gather / banked)")
