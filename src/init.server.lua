local constants = require(script.constants)
local prefabs = require(script.prefabs)(plugin)
local store = require(script.store)
local addToastWithTimeout = require(script.toasts.actions.addToastWithTimeout)

local toolbar = plugin:CreateToolbar(constants.names.TOOLBAR)

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

local function wrapErrorsWithToast(callback)
  return function()
    local success, result = pcall(callback)

    if success then
      store:dispatch(addToastWithTimeout(3, result))
    else
      store:dispatch(addToastWithTimeout(3, result))
    end
  end
end

for _, info in pairs(actions) do
  local button = toolbar:CreateButton(info.name, info.tooltip, info.icon)
  button.Click:Connect(wrapErrorsWithToast(info.callback))

  -- The buttons are scoped under the toolbar, but the actions don't have that
  -- benefit. Prepending "Prefabs" makes them easily searchable.
  local actionName = "Prefabs: " .. info.name

  local action = plugin:CreatePluginAction(info.id, actionName, info.tooltip)
  action.Triggered:Connect(wrapErrorsWithToast(info.callback))
end

-- Expose the prefab API to _G for easy command line access.
_G.prefabs = prefabs
