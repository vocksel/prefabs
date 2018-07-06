--[[
  scale
  =====

  Changes the size of a list of parts by a percentage, maintaining positions
  relative to each other.

  Usage
  -----

  -- Scales up Part1 and Part2 by 120%
  scale({ Part1, Part2, ... }, 1.20)
]]

-- Gets all the BaseParts in a model, excluding the PrimaryPart
local function getParts(model)
  local found = {}
  for _, d in pairs(model:GetDescendants()) do
    if d:IsA("BasePart") and d ~= model.PrimaryPart then
      table.insert(found, d)
    end
  end
  return found
end

local function scale(model, percent)
  assert(model:IsA("Model"), "Can only scale models")
  assert(model.PrimaryPart, "The model to scale must have a PrimaryPart")

  local parts = getParts(model)

  -- Bottom middle on the PrimaryPart. This will scale the model up and away from it.
  local scaleFrom = model.PrimaryPart.Position-Vector3.new(0, model.PrimaryPart.Size.Y/2, 0)

  for _, part in pairs(parts) do
    local isAnchored = part.Anchored
    part.Anchored = true

    local dist = part.Position - scaleFrom
    local rotation = part.CFrame - part.Position
    local newSize = part.Size * percent

    part.Size = newSize
    part.CFrame = CFrame.new(dist * percent + scaleFrom) * rotation

    part.Anchored = isAnchored
  end
end

return scale
