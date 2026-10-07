local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Greeting = require(script.Parent.UI.Greeting.Greeting)
local ReactiveState = require(script.Parent.UI.ReactiveState)
local Vide = require(ReplicatedStorage.Packages.Vide)
local constants = require(ReplicatedStorage.Shared.constants)

local state = ReactiveState.new(Vide, { Message = constants.STARTER_MESSAGE })

print(`[Client] {constants.STARTER_MESSAGE}`)

Vide.mount(function()
	return Vide.create("ScreenGui")({
		Name = "Starter",
		ResetOnSpawn = false,
		Greeting({
			Message = function()
				return state().Message
			end,
		}),
	})
end, Players.LocalPlayer:WaitForChild("PlayerGui"))
