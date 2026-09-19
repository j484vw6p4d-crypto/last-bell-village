--!nocheck
-- Review fly: press F to toggle. WASD + Space/LeftControl while flying.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local flying = false
local speed = 90
local conn = nil
local bodyGyro = nil
local bodyVel = nil

local keys = {
	W = false, A = false, S = false, D = false,
	Up = false, Down = false,
}

local function cleanup()
	if conn then
		conn:Disconnect()
		conn = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	if bodyVel then
		bodyVel:Destroy()
		bodyVel = nil
	end
	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
	end
end

local function startFly()
	local char = plr.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then
		return
	end
	cleanup()
	hum.PlatformStand = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVel.Velocity = Vector3.zero
	bodyVel.Parent = hrp

	conn = RunService.RenderStepped:Connect(function()
		if not (flying and hrp and hrp.Parent and bodyVel and bodyGyro) then
			return
		end
		local cam = workspace.CurrentCamera
		local move = Vector3.zero
		if keys.W then
			move += cam.CFrame.LookVector
		end
		if keys.S then
			move -= cam.CFrame.LookVector
		end
		if keys.A then
			move -= cam.CFrame.RightVector
		end
		if keys.D then
			move += cam.CFrame.RightVector
		end
		if keys.Up then
			move += Vector3.yAxis
		end
		if keys.Down then
			move -= Vector3.yAxis
		end
		if move.Magnitude > 0 then
			move = move.Unit * speed
		end
		bodyVel.Velocity = move
		bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
	end)
end

local function setFlying(on)
	flying = on
	if flying then
		startFly()
		print("[Village] Fly ON - F to stop. WASD move, Space up, Ctrl down.")
	else
		cleanup()
		print("[Village] Fly OFF")
	end
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	if input.KeyCode == Enum.KeyCode.F then
		setFlying(not flying)
	elseif input.KeyCode == Enum.KeyCode.W then
		keys.W = true
	elseif input.KeyCode == Enum.KeyCode.A then
		keys.A = true
	elseif input.KeyCode == Enum.KeyCode.S then
		keys.S = true
	elseif input.KeyCode == Enum.KeyCode.D then
		keys.D = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		keys.Up = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		keys.Down = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then
		keys.W = false
	elseif input.KeyCode == Enum.KeyCode.A then
		keys.A = false
	elseif input.KeyCode == Enum.KeyCode.S then
		keys.S = false
	elseif input.KeyCode == Enum.KeyCode.D then
		keys.D = false
	elseif input.KeyCode == Enum.KeyCode.Space then
		keys.Up = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		keys.Down = false
	end
end)

plr.CharacterAdded:Connect(function()
	if flying then
		task.wait(0.4)
		startFly()
	end
end)

print("[Village] Press F to fly (map review)")
