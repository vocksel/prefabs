--[[
  soundsMiddleware
  ----------------

  Allows you to play sounds when dispatching.

  Usage:

  store:dispatch({
    type = "FOO",
    meta = {
      sound = game.ReplicatedStorage.Sound
    }
  })
--]]

local run = game:GetService("RunService")
local soundService = game:GetService("SoundService")

local function soundsMiddleware(nextDispatch)
  return function(action)
    if run:IsClient() and action.meta then
      local soundId = action.meta.soundId

      if soundId then
        assert(type(soundId) == "string")
        local sound = Instance.new("Sound")
        sound.SoundId = soundId

        soundService:PlayLocalSound(sound)
      end
    end

    return nextDispatch(action)
  end
end

return soundsMiddleware
