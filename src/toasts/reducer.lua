local root = script.Parent.Parent

local createReducer = require(root.lib.Rodux).createReducer
local functional = require(root.lib.functional)
local immutable = require(root.lib.immutable)

local addToast = require(script.Parent.actions.addToast)
local removeToast = require(script.Parent.actions.removeToast)
local setHoveredToast = require(script.Parent.actions.setHoveredToast)

return createReducer({}, {
  [addToast.name] = function(state, action)
    return immutable.append(state, {
      id = action.id,
      body = action.body,
      isHovered = false
    })
  end,

  [removeToast.name] = function(state, action)
    return functional.filter(state, function(item)
      return item.id ~= action.id
    end)
  end,

  [setHoveredToast.name] = function(state, action)
    return functional.map(state, function(item)
      item.isHovered = item.id == action.id
      return item
    end)
  end
})
