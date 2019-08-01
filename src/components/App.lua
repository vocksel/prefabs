local Roact = require(script.Parent.Parent.lib.Roact)
local ToastList = require(script.Parent.Parent.toasts.components.ToastList)

local function App()
    return Roact.createElement("ScreenGui", nil, {
        Roact.createElement(ToastList)
    })
end

return App
