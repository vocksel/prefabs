local combineReducers = require(script.Parent.lib.Rodux.combineReducers)
local toasts = require(script.Parent.toasts.reducer)

return combineReducers({
  toasts = toasts
})

