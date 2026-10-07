-- A stable read view with one Vide source per field. Reading state().Ammo only
-- subscribes to Ammo, so publishing a clock cannot invalidate unrelated UI.
-- Published tables are immutable snapshots that replace the whole state: fields
-- missing from the next snapshot become nil. Deeply equal values are not
-- republished, and each publish is batched so observers see an atomic view.
--
-- Vide is passed in rather than required so this module also runs offline.
local ReactiveState = {}

export type Reactivity = {
	source: (initial: any) -> any,
	batch: (update: () -> ()) -> (),
}

local function equal(a: any, b: any): boolean
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for key, value in a do
		if not equal(value, b[key]) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end

--- Returns a function: call it with no argument to read, or with the next snapshot
--- to publish. Both forms return the read view.
function ReactiveState.new<T>(vide: Reactivity, initial: T): (nextValue: T?) -> T
	local values: { [any]: any } = table.clone(initial :: any)
	local cells: { [any]: any } = {}

	local function cell(key: any): any
		if not cells[key] then
			cells[key] = vide.source(values[key])
		end
		return cells[key]
	end

	local view: any = setmetatable({}, {
		__index = function(_, key)
			return cell(key)()
		end,
		__newindex = function()
			error("ReactiveState views are read-only")
		end,
	})

	return function(nextValue: T?): T
		local snapshot: any = nextValue
		if snapshot == nil then
			return view
		end

		vide.batch(function()
			for key, value in snapshot do
				if not equal(values[key], value) then
					values[key] = value
					cell(key)(value)
				end
			end
			for key in values do
				if snapshot[key] == nil then
					values[key] = nil
					cell(key)(nil)
				end
			end
		end)

		return view
	end
end

return ReactiveState
