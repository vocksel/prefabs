--[[
    toastOnError
    ------------

    Wraps a callback and automatically displays toasts if it error.
--]]

local root = script.Parent.Parent

local constants = require(root.constants)
local addToastWithTimeout = require(script.Parent.actions.addToastWithTimeout)

local function sanitizeErrorMessage(message)
    -- Matches everything after the traceback at the start.
    -- `Prefabs.prefabs:113: A prefab named "Model" already exists. Please rename and try again`
    return message:match(".+:%d+: (.+)")
end

local function toastOnError(store, callback)
    return function()
        local success, result = pcall(callback)

        if not success then
            result = sanitizeErrorMessage(result)
        end

        store:dispatch(addToastWithTimeout(constants.toasts.TIMEOUT, result))
    end
end

return toastOnError
