local src = script.Parent.Parent.Parent

local action = require(src.helpers.action)
local constants = require(src.constants)

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
