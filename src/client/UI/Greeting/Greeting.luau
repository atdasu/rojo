local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	Message: () -> string,
}

--- A centered line of text. Presentation only: all state arrives through props.
local function Greeting(props: Props): Instance
	return Vide.create("TextLabel")({
		Name = "Greeting",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansBold,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 32,
		Text = props.Message,
	})
end

return Greeting
