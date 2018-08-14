local src = script.Parent
local root = src.Parent

local combineReducers = require(root.lib.Rodux.combineReducers)

local toasts = require(src.toasts.reducer)

return combineReducers({
  toasts = toasts
})

