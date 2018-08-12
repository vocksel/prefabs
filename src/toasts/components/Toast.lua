local root = script.Parent.Parent.Parent

local Roact = require(root.lib.Roact)
local constants = require(root.constants)

local Toast = Roact.PureComponent:extend("Toast")

function Toast:render()
  return Roact.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    LayoutOrder = self.props.layoutOrder,
    BackgroundColor3 = constants.ui.backgroundColor,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
  }, {
    Roact.createElement("UIPadding", {
      PaddingTop = UDim.new(0, constants.ui.padding),
      PaddingRight = UDim.new(0, constants.ui.padding),
      PaddingBottom = UDim.new(0, constants.ui.padding),
      PaddingLeft = UDim.new(0, constants.ui.padding),
    }),

    Roact.createElement("TextLabel", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      Font = constants.ui.font,
      TextSize = constants.ui.textSize,
      Text = self.props.body,
      TextWrapped = true,
      TextColor3 = constants.ui.textColor,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
    })
  })
end

return Toast
