local CoreGui = game:GetService("CoreGui")

local Roact = require(script.Parent.lib.Roact)
local Rodux = require(script.Parent.lib.Rodux)
local StoreProvider = require(script.Parent.lib.RoactRodux).StoreProvider
local Maid = require(script.Parent.lib.Maid)

local constants = require(script.Parent.constants)
local prefabs = require(script.Parent.prefabs)(plugin)
local App = require(script.Parent.components.App)
local toastOnError = require(script.Parent.toasts.toastOnError)
local reducer = require(script.Parent.reducer)
local soundsMiddleware = require(script.Parent.middleware.soundsMiddleware)

local maid = Maid.new()

local store = Rodux.Store.new(reducer, nil, {
  Rodux.thunkMiddleware,
  soundsMiddleware
})

do
  local toolbar = plugin:CreateToolbar(constants.names.TOOLBAR)

  local actions = {
    {
      id = "prefabs/add",
      name = "Add",
      tooltip = "Registers the selection as a prefab",
      icon = "rbxassetid://2256271239",
      callback = prefabs.registerSelection
    },

    {
      id = "prefabs/update",
      name = "Update",
      tooltip = "With a prefab selected, update all others of the same type to match",
      icon = "rbxassetid://2256271848",
      callback = prefabs.updateWithSelection
    },

    {
      id = "prefabs/unlink",
      name = "Unlink",
      tooltip = "Unlinks a model from being considered a prefab",
      icon = "rbxassetid://2256271578",
      callback = prefabs.unlinkSelection
    }
  }

  for _, info in pairs(actions) do
    -- The buttons are scoped under the toolbar, but the actions don't have that
    -- benefit. Prepending "Prefabs" makes them easily searchable.
    local actionName = "Prefabs: " .. info.name

    local button = toolbar:CreateButton(info.name, info.tooltip, info.icon)
    local action = plugin:CreatePluginAction(info.id, actionName, info.tooltip)

    local events = { button.Click, action.Triggered }

    for _, event in pairs(events) do
      maid[event] = event:Connect(toastOnError(store, info.callback))
    end
  end
end

local instance do
  local element = Roact.createElement(StoreProvider, {
    store = store
  }, {
    App = Roact.createElement(App)
  })

  instance = Roact.mount(element, CoreGui, "PrefabsUI")
end

prefabs.listenForLastPrefabRemoval()
prefabs.cleanOnRemoval()

plugin.Unloading:Connect(function()
  Roact.unmount(instance)
  maid:clean()
  prefabs._connections:clean()
end)

-- Expose the prefab API to _G for easy command line access.
_G.prefabs = prefabs
