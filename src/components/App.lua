local Roact = require(script.Parent.Parent.lib.Roact)
local ToastList = require(script.Parent.Parent.toasts.components.ToastList)

local App = Roact.PureComponent:extend("App")

function App:render()
  return Roact.createElement("ScreenGui", nil, {
    Roact.createElement(ToastList)
  })
end

return App
