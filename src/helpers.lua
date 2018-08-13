--[[
  Generic helper functions that don't fit in any other module.
--]]

local SelectionService = game:GetService("Selection")
local SoundService = game:GetService("SoundService")

local constants = require(script.Parent.constants)

local exports = {}

--[[
  Creates a new copy of the first array, with all items from the second
  inserted at the end (in order)
--]]
function exports.append(arr1, arr2)
  local new = {}
  for _, arr in ipairs{ arr1, arr2 } do
    for _, v in ipairs(arr) do
      table.insert(new, v)
    end
  end
  return new
end

-- Taken from the Animation Editor's rig builder. Modified to fit our needs.
function exports.getCameraLookat(maxRange)
  maxRange = maxRange or 20

  local camera = workspace.CurrentCamera

  if camera then
    local ray = Ray.new(camera.CFrame.p, camera.CFrame.lookVector * maxRange)
    local _, pos = workspace:FindPartOnRay(ray)
    camera.Focus = CFrame.new(pos)
    return pos
  else
    --Default position if they did weird stuff
    print("Unable to find default camera.")
    return Vector3.new(0,5.2,0)
  end
end

--[[
  Creates a new folder, plain and simple.
--]]
function exports.newFolder(name, parent)
  local folder = Instance.new("Folder")
  folder.Name = name
  folder.Parent = parent

  return folder
end

--[[
  Creates folders one after the other.

  Every argument after the first is a string for a folder name. It also reuses
  existing folders. This is good for retroactively creating complex folder
  structures.

  Usage:

    mkdir(game.ServerStorage, "Foo", "Bar")

  The resulting hierarchy will look like:

    ServerStorage
      Foo
        Bar
--]]
function exports.mkdir(root, ...)
  assert(root, "argument #1 to mkdir missing, need an instance")

  local parent = root
  local lastFolder

  for _, name in pairs{ ... } do
    lastFolder = parent:FindFirstChild(name) or exports.newFolder(name, parent)
    parent = lastFolder
  end

  return lastFolder
end

-- Given a callback, runs it with the first instance selection as the argument.
--
-- This is used in conjunction with our API below to make selection-based
-- commands.
function exports.withSelection(callback)
  return function()
    local selection = SelectionService:Get()[1]

    assert(selection, constants.errors.NOTHING_SELECTED)

    return callback(selection)
  end
end

function exports.playLocalSound(soundId)
  local sound = Instance.new("Sound")
  sound.SoundId = soundId
  SoundService:PlayLocalSound(sound)
end

return exports
