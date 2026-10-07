local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Greeting = require(script.Parent.Greeting)
local UILabs = require(ReplicatedStorage.Packages.UILabs)
local Vide = require(ReplicatedStorage.Packages.Vide)

-- Fixture props only; a story never reads live game state.
return UILabs.CreateVideStory({
	vide = Vide,
	controls = {
		Message = "Hello from a story!",
	},
}, function(props)
	return Greeting({ Message = props.controls.Message })
end)
