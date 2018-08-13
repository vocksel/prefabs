local root = script.Parent.Parent.Parent

local PropTypes = require(root.lib.PropTypes)
local Roact = require(root.lib.Roact)
local connect = require(root.lib.RoactRodux).UNSTABLE_connect2
local constants = require(root.constants)
local TopBar = require(script.Parent.TopBar)
local setHoveredToast = require(script.Parent.Parent.actions.setHoveredToast)

local Toast = Roact.PureComponent:extend("Toast")

local validate = PropTypes.object({
  toast = PropTypes.object({
    body = PropTypes.string
  }),
  layoutOrder = PropTypes.number
})

function Toast:render()
  local toast = self.props.toast

  assert(validate(self.props))

  return Roact.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    LayoutOrder = self.props.layoutOrder,
    BackgroundColor3 = constants.ui.backgroundColor,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,

    [Roact.Event.InputBegan] = function(_, input)
      if input.UserInputType == Enum.UserInputType.MouseMovement then
        self.props.onMouseEnter(toast.id)
      end
    end,

    [Roact.Event.InputEnded] = function(_, input)
      if input.UserInputType == Enum.UserInputType.MouseMovement then
        self.props.onMouseLeave()
      end
    end
  }, {
    Padding = Roact.createElement("UIPadding", {
      PaddingTop = UDim.new(0, constants.ui.padding),
      PaddingRight = UDim.new(0, constants.ui.padding),
      PaddingBottom = UDim.new(0, constants.ui.padding),
      PaddingLeft = UDim.new(0, constants.ui.padding),
    }),

    Layout = Roact.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder
    }),

    TopBar = Roact.createElement(TopBar, {
      toast = toast
    }),

    Body = Roact.createElement("TextLabel", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      Font = constants.ui.font,
      TextSize = constants.ui.textSize,
      Text = toast.body,
      TextWrapped = true,
      TextColor3 = constants.ui.textColor,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
    })
  })
end

local function mapDispatchToProps(dispatch)
  return {
    onMouseEnter = function(id)
      dispatch(setHoveredToast(id))
    end,
    onMouseLeave = function()
      dispatch(setHoveredToast(nil))
    end
  }
end

return connect(nil, mapDispatchToProps)(Toast)
