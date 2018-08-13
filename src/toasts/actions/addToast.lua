local root = script.Parent.Parent.Parent

local action = require(root.action)

return action(script.Name, function(id, body)
  assert(id)
  assert(type(body) == "string")

  return {
    id = id,
    body = body,
    meta = {
      soundId = "rbxasset://intuition.ogg"
    }
  }
end)
