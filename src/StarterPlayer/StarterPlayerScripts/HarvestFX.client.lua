--!nocheck
-- Plays chop / gather feedback when the server fires FX.
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
	-- Tool slash = readable chop swing without a custom uploaded anim
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

	-- Temporary axe prop for the swing
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
		local base = p.CFrame
		task.spawn(function()
			for i = 1, 5 do
				local jitter = CFrame.new(
					(math.random() - 0.5) * 0.35,
					(math.random() - 0.5) * 0.2,
					(math.random() - 0.5) * 0.35
				) * CFrame.Angles(0, math.rad((math.random() - 0.5) * 12), 0)
				p.CFrame = base * jitter
				task.wait(0.04)
			end
			p.CFrame = base
		end)
	end
end

FX.OnClientEvent:Connect(function(kind, pad)
	local char = plr.Character
	if kind == "chop" then
		playChopAnim(char)
		shakePile(pad)
	elseif kind == "gather" then
		shakePile(pad)
		playChopAnim(char) -- short reach/pull using same swing track
	end
end)

print("[Village] HarvestFX ready (chop / gather)")
