local root = script.Parent.Parent.Parent

local action = require(root.action)

return action(script.Name, function(id, title, body)
  assert(id)
  assert(type(title) == "string")
  assert(type(body) == "string")

  return {
    id = id,
    title = title,
    body = body
  }
end)
