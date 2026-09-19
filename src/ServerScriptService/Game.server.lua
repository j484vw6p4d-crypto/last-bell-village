--!nocheck
-- VILLAGE-17: explore-only. Harvest / steal / tasks disabled.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local function push(plr, note)
	Remotes.State:FireClient(plr, {
		build = Config.BuildId,
		night = false,
		seconds = 0,
		coins = 0,
		herbs = 0,
		wood = 0,
		carry = 0,
		stock = 0,
		rebirths = 0,
		goal = 0,
		objective = "Explore your shed (systems paused)",
		checklist = {
			"Sandbox mode",
			"Harvest / steal / tasks off",
			"Walk into the shed",
		},
		progress = 0,
	})
	if note then
		Remotes.Notify:FireClient(plr, note)
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		push(plr, "Welcome — only the shed is active for now.")
	end)
	if plr.Character then
		push(plr, "Welcome — only the shed is active for now.")
	end
end)

-- Ignore Act / prompts while systems are paused
Remotes.Act.OnServerEvent:Connect(function(plr)
	Remotes.Notify:FireClient(plr, "Gameplay systems are paused.")
end)

print("[Village] VILLAGE-17 explore-only (no harvest/steal)")
