-- UI components call Sfx.play(cue). The game binds real playback at runtime; while
-- unbound (UI Labs stories, offline tests) it is a silent no-op, so components stay
-- presentation-only.
local Sfx = {}

local player: ((cue: string) -> ())? = nil

--- Sets the function that plays a cue, or clears it with nil.
function Sfx.bind(callback: ((cue: string) -> ())?)
	player = callback
end

function Sfx.play(cue: string)
	if player then
		player(cue)
	end
end

return Sfx
