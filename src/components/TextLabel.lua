local TextService = game:GetService("TextService")

local Roact = require(script.Parent.Parent.lib.Roact)
local immutable = require(script.Parent.Parent.lib.immutable)
local constants = require(script.Parent.Parent.constants)

local function TextLabel(props)
	local defaultProps = {
		BackgroundTransparency = 1,
		Font = constants.ui.font,
    TextSize = constants.ui.textSize,
    TextColor3 = constants.ui.textColor,
    Size = props.Size or props.TextWrapped and UDim2.new(1, 0, 0, 0) or nil,
		Text = "N/A",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,

		[Roact.Ref] = not props.Size and function(rbx)
			if not rbx then return end

			if props.TextWrapped then
				local function update()
					local width = rbx.AbsoluteSize.x
					local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(width - 2, 100000))
					rbx.Size = UDim2.new(1, 0, 0, tb.y)
				end
				rbx:GetPropertyChangedSignal("TextBounds"):Connect(update)
				local oldX = rbx.AbsoluteSize.x
				rbx:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if oldX ~= rbx.AbsoluteSize.x then
						oldX = rbx.AbsoluteSize.x
						update()
					end
				end)
				rbx:GetPropertyChangedSignal("Parent"):Connect(update)
				update()
			else
				local function update()
					local tb = rbx.TextBounds
					rbx.Size = UDim2.new(props.Width or UDim.new(0, tb.x), UDim.new(0, tb.y))
				end
				rbx:GetPropertyChangedSignal("TextBounds"):Connect(update)
				update()
			end
		end or nil
	}

	props = immutable.joinDictionaries(defaultProps, props)

	return Roact.createElement("TextLabel", props)
end

return TextLabel
