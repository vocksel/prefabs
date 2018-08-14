local src = script.Parent.Parent.Parent

local action = require(src.helpers.action)

return action(script.Name, function(id)
  return { id = id }
end)
