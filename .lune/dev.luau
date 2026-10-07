-- Serves the project to Roblox Studio and keeps the sourcemap up to date.
-- Stops as soon as either process exits.
local process = require("@lune/process")
local task = require("@lune/task")

local project = require("./lib/project")

project.sourcemap()

-- Extra arguments go to `rojo serve`, e.g. `lune run dev --port 34873`.
local commands = {
	{ "serve", project.FILE, table.unpack(process.args) },
	{ "sourcemap", project.FILE, "--output", project.SOURCEMAP, "--watch" },
}

for _, args in commands do
	task.spawn(function()
		local ok = project.run("rojo", args)
		process.exit(if ok then 0 else 1)
	end)
end
