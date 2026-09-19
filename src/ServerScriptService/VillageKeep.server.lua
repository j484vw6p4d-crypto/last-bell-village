--!nocheck
print("[Village] keep Test 1 map — no Terrain:Clear, no Workspace wipe")
local ok, World = pcall(function()
	return require(script.Parent:WaitForChild("World"))
end)
if ok and World and World.build then
	pcall(World.build)
else
	warn("[Village] World failed", World)
end
