local createReducer = require(script.Parent.Parent.lib.Rodux).createReducer
local Cryo = require(script.Parent.Parent.lib.Cryo)

local addToast = require(script.Parent.actions.addToast)
local removeToast = require(script.Parent.actions.removeToast)
local setHoveredToast = require(script.Parent.actions.setHoveredToast)

return createReducer({}, {
    [addToast.name] = function(state, action)
        return Cryo.List.join(state, {
            id = action.id,
            body = action.body,
            isHovered = false
        })
    end,

    [removeToast.name] = function(state, action)
        return Cryo.List.filter(state, function(item)
            return item.id ~= action.id
        end)
    end,

    [setHoveredToast.name] = function(state, action)
        return Cryo.List.map(state, function(item)
            -- FIXME: this is mutating
            item.isHovered = item.id == action.id
            return item
        end)
    end
})
