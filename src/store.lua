local src = script.Parent
local root = src.Parent

local Rodux = require(root.lib.Rodux)
local reducer = require(src.reducer)
local soundsMiddleware = require(src.middleware.soundsMiddleware)

local store = Rodux.Store.new(reducer, nil, {
  Rodux.thunkMiddleware,
  soundsMiddleware
})

return store
