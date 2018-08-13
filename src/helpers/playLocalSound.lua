local SoundService = game:GetService("SoundService")

local function playLocalSound(soundId)
  local sound = Instance.new("Sound")
  sound.SoundId = soundId
  SoundService:PlayLocalSound(sound)
end

return playLocalSound
