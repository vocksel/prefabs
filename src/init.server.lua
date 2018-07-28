local constants = require(script.constants)
local prefabs = require(script.prefabs)(plugin)

local toolbar = plugin:CreateToolbar(constants.names.TOOLBAR)

local actions = {
  {
    id = "prefabs/register",
    name = "Register",
    tooltip = "Registers the selection as a prefab",
    icon = "rbxassetid://413367266",
    callback = prefabs.registerSelection
  },

  {
    id = "prefabs/update",
    name = "Update",
    tooltip = "With a prefab selected, update all others of the same type to match",
    icon = "", -- TODO Get an icon
    callback = prefabs.updateWithSelection
  },

  {
    id = "prefabs/rename",
    name = "Rename",
    tooltip = "With a prefab selected, updates the name and tag for all other copies to match",
    icon = "", -- TODO Get an icon
    callback = prefabs.renameSelection
  },
}

for _, info in pairs(actions) do
  local button = toolbar:CreateButton(info.name, info.tooltip, info.icon)
  button.Click:Connect(info.callback)

  -- The buttons are scoped under the toolbar, but the actions don't have that
  -- benefit. Prepending "Prefabs" makes them easily searchable.
  local actionName = "Prefabs: " .. info.name

  local action = plugin:CreatePluginAction(info.id, actionName, info.tooltip)
  action.Triggered:Connect(info.callback)
end

-- Expose the prefab API to _G for easy command line access.
_G.prefabs = prefabs
