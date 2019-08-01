local root = script.Parent.Parent.Parent

local PropTypes = require(root.lib.PropTypes)
local Roact = require(root.lib.Roact)
local connect = require(root.lib.RoactRodux).UNSTABLE_connect2
local constants = require(root.constants)
local SizeProvider = require(root.components.SizeProvider)
local TextLabel = require(root.components.TextLabel)
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

  local layoutRef = Roact.createRef()

  return Roact.createElement(SizeProvider, {
    layoutRef = layoutRef,
    render = function(height)
      return Roact.createElement("Frame", {
        -- Padding the height to offset the top and bottom UIPadding
        Size = UDim2.new(1, 0, 0, height+(constants.ui.padding*2)),

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
        Layout = Roact.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder,
          [Roact.Ref] = layoutRef
        }),

        Padding = Roact.createElement("UIPadding", {
          PaddingTop = UDim.new(0, constants.ui.padding),
          PaddingRight = UDim.new(0, constants.ui.padding),
          PaddingBottom = UDim.new(0, constants.ui.padding),
          PaddingLeft = UDim.new(0, constants.ui.padding),
        }),

        TopBar = Roact.createElement(TopBar, {
          toast = toast
        }),

        Body = Roact.createElement(TextLabel, {
          Text = toast.body,
          TextWrapped = true
        })
      })
    end
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
