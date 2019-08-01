local createReducer = require(script.Parent.Parent.lib.Rodux).createReducer
local Cryo = require(script.Parent.Parent.lib.Cryo)

return createReducer({}, {
    ADD_TOAST = function(state, action)
        return Cryo.List.join(state, {
            id = action.id,
            body = action.body,
            isHovered = false
        })
    end,

    REMOVE_TOAST = function(state, action)
        return Cryo.List.filter(state, function(item)
            return item.id ~= action.id
        end)
    end,

    SET_HOVERED_TOAST = function(state, action)
        return Cryo.List.map(state, function(item)
            -- FIXME: this is mutating
            item.isHovered = item.id == action.id
            return item
        end)
    end
})
