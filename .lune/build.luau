-- Builds the place file into build/<ProjectName>.rbxl.
local fs = require("@lune/fs")

local project = require("./lib/project")

if not fs.isDir("build") then
	fs.writeDir("build")
end

project.must("rojo", { "build", project.FILE, "--output", `build/{project.name()}.rbxl` })
