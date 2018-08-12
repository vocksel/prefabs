local root = script.Parent

local Rodux = require(root.lib.Rodux)
local reducer = require(root.reducer)

local store = Rodux.Store.new(reducer, nil, { Rodux.thunkMiddleware })

return store
