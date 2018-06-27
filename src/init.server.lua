local collections = game:GetService("CollectionService")

-- Controls how far down (in studs) the prefab will be moved when cloning it in.
--
-- This is so the PrimaryPart can be below the prefab, while having the
-- placeholder in the workspace be above ground, so that it can be viewed.
--
-- This makes it easier to work with the prefab, as the PrimaryPart doesn't
-- have to be lodged into the model in any way.
local SHIFT_DOWN_FROM_PLACEHOLDER = 1

-- Turns the PrimaryParts of every prefab invisible when cloning it in.
--
-- This allows you to be aware of where you're positioner is while working,
-- while not having to worry about changing its visibility when it's cloned in.
local MAKE_PRIMARY_PART_INVISIBLE = true

-- The location where all the prefabs are stored. Any models are considered to
-- be prefabs, and any folder will be looked through.
local PREFABS = collections:GetTagged("prefabs")[1]

local toolbar = plugin:CreateToolbar("Race City")
local button = toolbar:CreateButton("Toggle Prefabs",
  "Toggles all of the prefabs between parts and real models",
  "rbxassetid://413367266")

local function getOrCreatePrefabVisibilityState(parent)
  local name = "ArePrefabsShown"
  local shown = parent:FindFirstChild(name)

  if shown and shown:IsA("BoolValue") then
    return shown
  else
    shown = Instance.new("BoolValue")
    shown.Name = name
    shown.Value = false
    shown.Parent = parent

    return shown
  end
end

local function validatePrefab(prefab)
  local name = prefab.Name

  assert(prefab:IsA("Model"), ("For %s to be a prefab it must be a Model instance"):format(name))
  assert(prefab.PrimaryPart, ("%s needs a PrimaryPart to be a prefab"):format(name))
end

-- Gets a flat list of all the prefabs
local function getPrefabs(location, found)
  found = found or {}

  for _, child in pairs(location:GetChildren()) do
    if child:IsA("Folder") then
      getPrefabs(child, found)
    elseif child:IsA("Model") then
      validatePrefab(child)
      table.insert(found, child)
    end
  end

  return found
end

-- Gets the tag for the prefab.
--
-- This tag is used to associate the prefab with placeholders in the workspace.
--
-- Each prefab can only have one of these tags. Having more than one "prefab"
-- tag will only result in the first being picked up.
local function getPrefabTag(prefab)
  for _, tag in pairs(collections:GetTags(prefab)) do
    if tag:match("^prefab") then
      return tag
    end
  end
end

-- Takes a callback to run on each prefab.
--
-- The callback is passed the prefab itself, and the tag associated with the
-- prefab.
local function createPrefabModifier(callback)
  return function(prefabs)
    for _, prefab in pairs(prefabs) do
      local tag = getPrefabTag(prefab)
      assert(tag, ("%s is missing a prefab tag"):format(prefab:GetFullName()))
      callback(prefab, tag)
    end
  end
end

local function getPlaceholdersForTag(tag)
  local found = {}
  for _, placeholder in pairs(collections:GetTagged(tag)) do
    if not placeholder:IsDescendantOf(PREFABS) then
      table.insert(found, placeholder)
    end
  end
  return found
end

local function showPrefab(prefab, tag)
  local positionOffset = CFrame.new(0, -SHIFT_DOWN_FROM_PLACEHOLDER, 0)
  local placeholders = getPlaceholdersForTag(tag)

  for _, placeholder in pairs(placeholders) do
    assert(placeholder:IsA("BasePart"), ("%s must be a BasePart to act as "..
      " a placeholder"):format(placeholder:GetFullName()))

      local clone = prefab:Clone()

    if MAKE_PRIMARY_PART_INVISIBLE then
      clone.PrimaryPart.Transparency = 1
    end

    clone:SetPrimaryPartCFrame(placeholder.CFrame * positionOffset)

    -- The prefab is parented inside of the placeholder so that when moving
    -- things around with prefabs enabled to align them, the placeholder
    -- will follow along.
    clone.Parent = placeholder

    placeholder.Transparency = 1
  end
end

local showAllPrefabs = createPrefabModifier(showPrefab)

local function hidePrefab(_, tag)
  for _, prefabOrPlaceholder in pairs(collections:GetTagged(tag)) do
    if not prefabOrPlaceholder:IsDescendantOf(PREFABS) then
      if prefabOrPlaceholder:IsA("Model") then -- prefab
        prefabOrPlaceholder:Destroy()
      else -- placeholder
        prefabOrPlaceholder.Transparency = 0
      end
    end
  end
end

local hideAllPrefabs = createPrefabModifier(hidePrefab)

local function togglePrefabs()
  assert(PREFABS, "No folder containing prefabs found. Tag a folder with "..
    "\"prefabs\" and try again")

  local arePrefabsShown = getOrCreatePrefabVisibilityState(PREFABS)
  local prefabs = getPrefabs(PREFABS)

  if arePrefabsShown.Value then
    hideAllPrefabs(prefabs)
  else
    showAllPrefabs(prefabs)
  end

  arePrefabsShown.Value = not arePrefabsShown.Value
end

button.Click:Connect(togglePrefabs)
