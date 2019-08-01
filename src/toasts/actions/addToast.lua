local root = script.Parent.Parent.Parent

local t = require(root.lib.t)
local constants = require(root.constants)

local check = t.tuple(t.string, t.string)

local function addToast(id, body)
    assert(check(id, body))

    return {
        type = "ADD_TOAST",
        id = id,
        body = body,
        meta = {
            soundId = constants.sounds.notification
        }
    }
end

return addToast
