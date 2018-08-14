return function(plugin, initialState)
  print("loaded")

  local CoreGui = game:GetService("CoreGui")

  local Roact = require(script.Parent.lib.Roact)

  local constants = require(script.constants)
  local prefabs = require(script.prefabs)(plugin)
  local App = require(script.components.App)
  local toastOnError = require(script.toasts.toastOnError)

  local toolbar = plugin:toolbar(constants.names.TOOLBAR)

  local actions = {
    {
      id = "prefabs/add",
      name = "Add",
      tooltip = "Registers the selection as a prefab",
      icon = "rbxassetid://2190752357",
      callback = prefabs.registerSelection
    },

    {
      id = "prefabs/update",
      name = "Update",
      tooltip = "With a prefab selected, update all others of the same type to match",
      icon = "rbxassetid://2190753318",
      callback = prefabs.updateWithSelection
    }
  }

  for _, info in pairs(actions) do
    -- The buttons are scoped under the toolbar, but the actions don't have that
    -- benefit. Prepending "Prefabs" makes them easily searchable.
    local actionName = "Prefabs: " .. info.name

    local button = plugin:button(toolbar, info.name, info.tooltip, info.icon)
    local action = plugin:action(info.id, actionName, info.tooltip)

    local events = { button.Click, action.Triggered }

    for _, event in pairs(events) do
      event:Connect(toastOnError(info.callback))
    end
  end

  Roact.mount(Roact.createElement(App), CoreGui, "PrefabsUI")

  -- Expose the prefab API to _G for easy command line access.
  _G.prefabs = prefabs
end
