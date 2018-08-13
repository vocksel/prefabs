local root = script.Parent

local Rodux = require(root.lib.Rodux)
local reducer = require(root.reducer)
local soundsMiddleware = require(root.middleware.soundsMiddleware)

local store = Rodux.Store.new(reducer, nil, {
  Rodux.thunkMiddleware,
  soundsMiddleware
})

return store
