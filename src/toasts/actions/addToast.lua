local root = script.Parent.Parent.Parent

local action = require(root.action)
local constants = require(root.constants)

return action(script.Name, function(id, body)
  assert(id)
  assert(type(body) == "string")

  return {
    id = id,
    body = body,
    meta = {
      soundId = constants.sounds.notification
    }
  }
end)
