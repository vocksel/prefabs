local CollectionService = game:GetService("CollectionService")
local PluginService = plugin
local ServerStorage = game:GetService("ServerStorage")

local resources = script:FindFirstChild("resources")

local Constants = require(resources:FindFirstChild("Constants"))
local PluginSettings = require(resources:FindFirstChild("PluginSettings"))(PluginService)

local globalSettings = PluginSettings.new("global")

local MAKE_PRIMARY_PART_INVISIBLE = Constants.Settings.MAKE_PRIMARY_PART_INVISIBLE
local PREFAB_TAG_PATTERN = Constants.Settings.PREFAB_TAG_PATTERN
local SHIFT_DOWN_FROM_PLACEHOLDER = Constants.Settings.SHIFT_DOWN_FROM_PLACEHOLDER
local PREFAB_VISIBILITY_OBJECT_VALUE_NAME = Constants.Settings.PREFAB_VISIBILITY_OBJECT_VALUE_NAME
local PREVENT_COLLISIONS = Constants.Settings.PREVENT_COLLISIONS

local toolbar = PluginService:CreateToolbar(Constants.Names.TOOLBAR)
local button = toolbar:CreateButton(
  Constants.Names.TOGGLE_BUTTON_TITLE,
  Constants.Names.TOGGLE_BUTTON_TOOLTIP,
  Constants.Images.TOOGLE_BUTTON_ICON
)

-- Gets a folder, or creates it if it doesn't exist.
--
-- The word "grab" in this project means the same thing as "get or create." It's
-- just a way to cut down on the length of some functions.
local function grabFolder(name, parent)
  assert(name, "need to give a name to the folder")
  assert(parent, "need a parent for the folder")

  if parent:FindFirstChild(name) then
    return parent[name]
  else
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
  end
end

local function grabRootStorage()
  return grabFolder(Constants.Containers.ROOT, ServerStorage)
end

local function grabPlaceholderStorage()
  return grabFolder(Constants.Containers.PLACEHOLDERS, grabRootStorage())
end

local function grabPrefabStorage()
  return grabFolder(Constants.Containers.PREFABS, grabRootStorage())
end

local function getOrCreatePrefabVisibilityState()
  local storage = grabRootStorage()
  local objectValueName = globalSettings:Get(PREFAB_VISIBILITY_OBJECT_VALUE_NAME)
  local shown = storage:FindFirstChild(objectValueName)

  if shown and shown:IsA("BoolValue") then
    return shown
  else
    shown = Instance.new("BoolValue")
    shown.Name = objectValueName
    shown.Value = false
    shown.Parent = storage

    return shown
  end
end

local function setupContainers()
  grabRootStorage()
  grabPlaceholderStorage()
  grabPrefabStorage()
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
  local prefabTagPattern = globalSettings:Get(PREFAB_TAG_PATTERN)
  for _, tag in pairs(CollectionService:GetTags(prefab)) do
    if tag:match(prefabTagPattern) then
      return tag
    end
  end
end

-- Takes a callback to run on each prefab.
--
-- The callback is passed the prefab itself, and the tag associated with the
-- prefab.
local function createPrefabModifier(callback)
  return function()
    local storage = grabPrefabStorage()
    local prefabs = getPrefabs(storage)

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
    if placeholder:IsDescendantOf(workspace) then
      table.insert(found, placeholder)
    end
  end
  return found
end

local function showPrefab(prefab, tag)
  local shiftDownFromPlaceholder = globalSettings:Get(SHIFT_DOWN_FROM_PLACEHOLDER)
  local positionOffset = CFrame.new(0, -shiftDownFromPlaceholder, 0)
  local placeholders = getPlaceholdersForTag(tag)

  for _, placeholder in pairs(placeholders) do
    assert(placeholder:IsA("BasePart"), ("%s must be a BasePart to act as "..
      " a placeholder"):format(placeholder:GetFullName()))

    local clone = prefab:Clone()

    if globalSettings:Get(MAKE_PRIMARY_PART_INVISIBLE) then
      clone.PrimaryPart.Transparency = 1
    end

    clone:SetPrimaryPartCFrame(placeholder.CFrame * positionOffset)
    clone.Parent = placeholder.Parent

    placeholder.Transparency = 1
  end
end

local showAllPrefabs = createPrefabModifier(showPrefab)

local function hidePrefab(_, tag)
  for _, prefabOrPlaceholder in pairs(CollectionService:GetTagged(tag)) do
    if not prefabOrPlaceholder:IsDescendantOf(grabPrefabStorage()) then
      if prefabOrPlaceholder:IsA("Model") then -- prefab
        prefabOrPlaceholder:Destroy()
      else -- placeholder
        prefabOrPlaceholder.Transparency = 0

        -- This isn't smart enough to return CanCollide back to the value it was
        -- before showing prefabs, but that shouldn't be an issue.
        if globalSettings:Get(PREVENT_COLLISIONS) then
          prefabOrPlaceholder.CanCollide = true
        end
      end
    end
  end
end

local hideAllPrefabs = createPrefabModifier(hidePrefab)

local function togglePrefabs()
  local arePrefabsShown = getOrCreatePrefabVisibilityState()
  if arePrefabsShown.Value then
    hideAllPrefabs()
  else
    showAllPrefabs()
  end
  arePrefabsShown.Value = not arePrefabsShown.Value
end

setupContainers()
button.Click:Connect(togglePrefabs)
