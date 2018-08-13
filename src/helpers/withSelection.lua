--[[
  Given a callback, runs it with the first instance selection as the argument.

  This is used in conjunction with our API below to make selection-based
  commands.
--]]

local SelectionService = game:GetService("Selection")

local constants = require(script.Parent.Parent.constants)

local function withSelection(callback)
  return function()
    local selection = SelectionService:Get()[1]

    assert(selection, constants.errors.NOTHING_SELECTED)

    return callback(selection)
  end
end

return withSelection
