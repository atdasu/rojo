local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local project = {}

project.FILE = "default.project.json"
project.SOURCEMAP = "sourcemap.json"
-- Directories holding first-party Luau that is synced into the game.
project.SOURCES = { "src", "libraries" }
project.TESTS = "tests"
project.PACKAGE_DIRECTORIES = { "Packages", "ServerPackages" }

--- Runs a tool with inherited output and reports whether it succeeded.
function project.run(program: string, args: { string }): boolean
	print(`> {program} {table.concat(args, " ")}`)
	return process.exec(program, args, { stdio = "inherit" }).ok
end

--- Runs a tool and stops the script with a failing exit code if it fails.
function project.must(program: string, args: { string })
	if not project.run(program, args) then
		process.exit(1)
	end
end

--- The project name from the Rojo project file.
function project.name(): string
	return serde.decode("json", fs.readFile(project.FILE)).name
end

--- Regenerates the sourcemap that luau-lsp uses to resolve instance requires.
function project.sourcemap()
	project.must("rojo", { "sourcemap", project.FILE, "--output", project.SOURCEMAP })
end

--- Every Luau directory in the repository, including tooling and tests.
function project.allLuau(): { string }
	return { ".lune", project.TESTS, table.unpack(project.SOURCES) }
end

return project
