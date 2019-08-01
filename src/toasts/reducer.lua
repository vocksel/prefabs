local createReducer = require(script.Parent.Parent.lib.Rodux).createReducer
local functional = require(script.Parent.Parent.lib.functional)
local immutable = require(script.Parent.Parent.lib.immutable)

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
