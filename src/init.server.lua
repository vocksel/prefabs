local resources = script:FindFirstChild("resources")

local Constants = require(resources:FindFirstChild("Constants"))
local prefabs = require(script.prefabs)(plugin)

local toolbar = plugin:CreateToolbar(Constants.Names.TOOLBAR)

local actions = {
  {
    name = "Register",
    tooltip = "Registers the selection as a prefab",
    icon = "rbxassetid://413367266",
    callback = prefabs.registerSelection
  }
}

for _, info in pairs(actions) do
  local button = toolbar:CreateButton(info.name, info.tooltip, info.icon)
  button.Click:Connect(info.callback)
end

-- Expose the prefab API to _G for easy command line access.
_G.prefabs = prefabs
