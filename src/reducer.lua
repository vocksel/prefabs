local root = script.Parent

local combineReducers = require(root.lib.Rodux.combineReducers)

local toasts = require(root.toasts.reducer)

return combineReducers({
  toasts = toasts
})
