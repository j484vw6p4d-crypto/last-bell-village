--!nocheck
-- Keeps Test 1 map. Never Terrain:Clear / Workspace wipe.
print("[Village] VILLAGE-15 keep Test 1 terrain")
local ok, World = pcall(function()
	return require(script.Parent:WaitForChild("World"))
end)
if ok and World and World.build then
	local built, err = pcall(World.build)
	if not built then
		warn("[Village] World.build error", err)
	end
else
	warn("[Village] World require failed", World)
end
