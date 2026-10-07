-- Checks formatting, lints, type-checks, and runs the offline tests.
local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")

local project = require("./lib/project")

local DEFINITIONS = "globalTypes.d.luau"

-- Roblox API type definitions matching the pinned luau-lsp version.
local function ensureDefinitions()
	if fs.isFile(DEFINITIONS) then
		return
	end

	local tool = serde.decode("toml", fs.readFile("rokit.toml")).tools["luau-lsp"]
	local version = string.match(tool, "@(.+)$")
	local url =
		`https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/{version}/scripts/globalTypes.d.luau`

	print(`> fetching {url}`)
	local response = net.request(url)
	if not response.ok then
		error(`Failed to download {DEFINITIONS}: {response.statusCode} {response.statusMessage}`)
	end
	fs.writeFile(DEFINITIONS, response.body)
end

ensureDefinitions()
project.sourcemap()

local analyze = {
	"analyze",
	`--sourcemap={project.SOURCEMAP}`,
	`--definitions={DEFINITIONS}`,
	"--base-luaurc=.luaurc",
	"--ignore=Packages/**",
	"--ignore=ServerPackages/**",
	table.unpack(project.SOURCES),
}

local steps = {
	{ name = "format", program = "stylua", args = { "--check", table.unpack(project.allLuau()) } },
	{ name = "lint", program = "selene", args = { project.TESTS, table.unpack(project.SOURCES) } },
	{ name = "types", program = "luau-lsp", args = analyze },
	{ name = "tests", program = "lune", args = { "run", "test" } },
}

local failed = {}
for _, step in steps do
	if not project.run(step.program, step.args) then
		table.insert(failed, step.name)
	end
end

if #failed > 0 then
	print(`\nCheck failed: {table.concat(failed, ", ")}`)
	process.exit(1)
end

print("\nAll checks passed.")
