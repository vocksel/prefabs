local root = script.Parent.Parent.Parent

local action = require(root.action)

return action(script.Name, function(id)
  return { id = id }
end)
