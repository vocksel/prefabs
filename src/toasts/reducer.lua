local root = script.Parent.Parent

local createReducer = require(root.lib.Rodux).createReducer
local functional = require(root.lib.functional)
local immutable = require(root.lib.immutable)

local addToast = require(script.Parent.actions.addToast)
local removeToast = require(script.Parent.actions.removeToast)

return createReducer({}, {
  [addToast.name] = function(state, action)
    return immutable.append(state, {
      id = action.id,
      body = action.body
    })
  end,

  [removeToast.name] = function(state, action)
    return functional.filter(state, function(item)
      return item.id ~= action.id
    end)
  end
})
