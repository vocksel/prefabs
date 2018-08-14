local root = script.Parent.Parent.Parent

local Roact = require(root.lib.Roact)
local StoreProvider = require(root.lib.RoactRodux).StoreProvider
local store = require(root.src.store)
local ToastList = require(root.src.toasts.components.ToastList)

local App = Roact.PureComponent:extend("App")

function App:render()
  return Roact.createElement("ScreenGui", nil, {
    Roact.createElement(StoreProvider, { store = store }, {
      Roact.createElement(ToastList)
    })
  })
end

return App
