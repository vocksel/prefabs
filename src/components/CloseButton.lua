local PropTypes = require(script.Parent.Parent.lib.PropTypes)
local Roact = require(script.Parent.Parent.lib.Roact)
local constants = require(script.Parent.Parent.constants)
local playLocalSound = require(script.Parent.Parent.helpers.playLocalSound)

local CloseButton = Roact.PureComponent:extend("CloseButton")

local validate = PropTypes.object({
  color = PropTypes.optional(PropTypes.Color3),
  onClick = PropTypes.callback
})

function CloseButton:render()
  assert(validate(self.props))

  return Roact.createElement("ImageButton", {
    Image = "rbxassetid://1432074468",
    ImageColor3 = self.props.color or Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    [Roact.Event.Activated] = function()
      playLocalSound(constants.sounds.click)
      self.props.onClick()
    end
  })
end

return CloseButton
