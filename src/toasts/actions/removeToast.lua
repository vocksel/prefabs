local root = script.Parent.Parent.Parent

local t = require(root.lib.t)

local check = t.string

local function removeToast(id)
     assert(check(id))

     return {
         type = "REMOVE_TOAST",
         id = id
     }
end

return removeToast
