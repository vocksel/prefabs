local root = script.Parent.Parent.Parent.Parent

local http = game:GetService("HttpService")

local addToast = require(script.Parent.addToast)
local removeToast = require(script.Parent.removeToast)
local functional = require(root.lib.functional)

return function(timeout, body)
  return function(store)
    local id = http:GenerateGUID()

    store:dispatch(addToast(id, body))

    spawn(function()
      wait(timeout)

      local state = store:getState()
      local toast = functional.filter(state.toasts, function(toast)
        return toast.id == id
      end)[1]

      if toast then
        if toast.isHovered then
          repeat wait(1) until not toast.isHovered
        end

        store:dispatch(removeToast(id))
      end
    end)
  end
end
