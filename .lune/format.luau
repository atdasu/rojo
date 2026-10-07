-- Formats all Luau source with StyLua.
local project = require("./lib/project")

project.must("stylua", project.allLuau())
