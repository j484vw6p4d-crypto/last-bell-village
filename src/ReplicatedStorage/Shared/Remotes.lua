--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folder = ReplicatedStorage:FindFirstChild("VillageRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "VillageRemotes"
	folder.Parent = ReplicatedStorage
end

local function ev(name)
	local r = folder:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = folder
	end
	return r
end

return {
	folder = folder,
	State = ev("State"),
	Notify = ev("Notify"),
	Act = ev("Act"),
	FX = ev("FX"),
}
