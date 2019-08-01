local root = script.Parent.Parent.Parent

local Roact = require(root.lib.Roact)
local constants = require(root.constants)
local ToastCloseButton = require(script.Parent.ToastCloseButton)

local TopBar = Roact.PureComponent:extend("TopBar")

function TopBar:render()
  return Roact.createElement("Frame", {
    Size = UDim2.new(1, 0, 0, constants.ui.textSize),
    BackgroundTransparency = 1,
}, {
    Title = Roact.createElement("TextLabel", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      Text = constants.names.TOOLBAR,
      TextColor3 = constants.ui.textColor,
      TextSize = constants.ui.textSize,
      Font = Enum.Font.SourceSansBold,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
      LayoutOrder = 1
    }),

    Close = Roact.createElement(ToastCloseButton, {
      toast = self.props.toast,
      layoutOrder = 2
    })
  })
end

return TopBar
