-- Runs a cleanup exactly once when an instance is destroyed or leaves its root.
-- `bind` registers the cleanup and `watch` starts observing; they may be called in
-- either order. Call `watch` from a different script than the one being observed:
-- a handler connected by a script is cancelled together with that script.
local Lifetime = {}

type Entry = {
	connections: { RBXScriptConnection },
	cleanup: (() -> ())?,
	stopped: boolean,
}

local entries: { [Instance]: Entry } = {}

local function entryFor(owner: Instance): Entry
	local entry = entries[owner]
	if not entry then
		entry = { connections = {}, cleanup = nil, stopped = false }
		entries[owner] = entry
	end
	return entry
end

local function stop(owner: Instance, entry: Entry)
	if entry.stopped then
		return
	end
	entry.stopped = true

	for _, connection in entry.connections do
		connection:Disconnect()
	end
	table.clear(entry.connections)
	entries[owner] = nil

	local cleanup = entry.cleanup
	entry.cleanup = nil
	if cleanup then
		cleanup()
	end
end

--- Registers the cleanup for `owner` and returns a function that runs it early.
function Lifetime.bind(owner: Instance, root: Instance, cleanup: () -> ()): () -> ()
	local entry = entryFor(owner)
	assert(not entry.cleanup, "Lifetime already bound")
	entry.cleanup = cleanup

	if not owner:IsDescendantOf(root) then
		stop(owner, entry)
	end

	return function()
		stop(owner, entry)
	end
end

--- Starts observing `owner`; its cleanup runs once it is destroyed or leaves `root`.
function Lifetime.watch(owner: Instance, root: Instance)
	local entry = entryFor(owner)
	assert(#entry.connections == 0, "Lifetime already watched")

	table.insert(
		entry.connections,
		owner.Destroying:Connect(function()
			stop(owner, entry)
		end)
	)
	table.insert(
		entry.connections,
		owner.AncestryChanged:Connect(function()
			if not owner:IsDescendantOf(root) then
				stop(owner, entry)
			end
		end)
	)

	if not owner:IsDescendantOf(root) then
		stop(owner, entry)
	end
end

return Lifetime
