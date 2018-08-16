local root = script.Parent.Parent.Parent.Parent

local Roact = require(root.lib.Roact)
local connect = require(root.lib.RoactRodux).UNSTABLE_connect2
local constants = require(root.src.constants)
local Toast = require(script.Parent.Toast)

local ToastList = Roact.PureComponent:extend("ToastList")

function ToastList:render()
  if not self.props.isShown then return end

  local children = {}

  children.layout = Roact.createElement("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, constants.ui.padding),
    VerticalAlignment = Enum.VerticalAlignment.Bottom
  })

  for index, toast in ipairs(self.props.toasts) do
    children[toast.id] = Roact.createElement(Toast, {
      toast = toast,
      layoutOrder = -index
    })
  end

  return Roact.createElement("Frame", {
    Size = UDim2.new(0, 400, 0, 0),
    Position = UDim2.new(1, -constants.ui.padding, 1, -constants.ui.padding),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1
  }, children)
end

local function mapStateToProps(state)
  local toasts = state.toasts

  return {
    isShown = #toasts > 0,
    toasts = toasts
  }
end

return connect(mapStateToProps)(ToastList)
