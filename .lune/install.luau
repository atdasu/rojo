-- Installs Wally dependencies and re-exports their types for luau-lsp.
local fs = require("@lune/fs")

local project = require("./lib/project")

project.must("wally", { "install" })
project.sourcemap()

-- Wally only creates a package directory when its realm has dependencies.
for _, directory in project.PACKAGE_DIRECTORIES do
	if fs.isDir(directory) then
		project.must("wally-package-types", { "--sourcemap", project.SOURCEMAP, directory })
	end
end
