local root = script.Parent.Parent.Parent

local t = require(root.lib.t)

local check = t.string

local function setHoveredToast(id)
    assert(check(id))

    return {
        type = "SET_HOVERED_TOAST",
        id = id
    }
end

return setHoveredToast
