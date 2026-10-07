local core = {}

--- Creates the shared greeting used by the starter game.
function core.createGreeting(projectName: string): string
	return `Hello from {projectName}!`
end

return core
