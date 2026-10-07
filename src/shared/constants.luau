local ReplicatedStorage = game:GetService("ReplicatedStorage")

local core = require(ReplicatedStorage.InternalLibraries.core)

return {
	STARTER_MESSAGE = core.createGreeting("StarterGame"),
}
