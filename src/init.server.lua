local CollectionService = game:GetService("CollectionService")
local PluginService = plugin

local resources = script:FindFirstChild("resources")

local Constants = require(resources:FindFirstChild("Constants"))

local MAKE_PRIMARY_PART_INVISIBLE = Constants.Settings.MAKE_PRIMARY_PART_INVISIBLE
local PREFAB_TAG_PATTERN = Constants.Settings.PREFAB_TAG_PATTERN
local SHIFT_DOWN_FROM_PLACEHOLDER = Constants.Settings.SHIFT_DOWN_FROM_PLACEHOLDER
local PREFAB_VISIBILITY_OBJECT_VALUE = Constants.Settings.PREFAB_VISIBILITY_OBJECT_VALUE

-- The location where all the prefabs are stored. Any models are considered to
-- be prefabs, and any folder will be looked through.
local PREFABS = CollectionService:GetTagged("prefabs")[1]

local toolbar = PluginService:CreateToolbar(Constants.Names.TOOLBAR)
local button = toolbar:CreateButton(
  Constants.Names.TOGGLE_BUTTON_TITLE,
  Constants.Names.TOGGLE_BUTTON_TOOLTIP,
  Constants.Images.TOOGLE_BUTTON_ICON
)

local function getOrCreatePrefabVisibilityState(parent)
  local shown = parent:FindFirstChild(name)

  if shown and shown:IsA("BoolValue") then
    return shown
  else
    shown = Instance.new("BoolValue")
    shown.Name = PREFAB_VISIBILITY_OBJECT_VALUE
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
  for _, tag in pairs(CollectionService:GetTags(prefab)) do
    if tag:match(PREFAB_TAG_PATTERN) then
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
  for _, placeholder in pairs(CollectionService:GetTagged(tag)) do
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
  for _, prefabOrPlaceholder in pairs(CollectionService:GetTagged(tag)) do
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
