return function(plugin)
  local CollectionService = game:GetService("CollectionService")
  local HistoryService = game:GetService("ChangeHistoryService")
  local SelectionService = game:GetService("Selection")
  local ServerStorage = game:GetService("ServerStorage")

  local constants = require(script.Parent.constants)
  local PluginSettings = require(script.Parent.PluginSettings)(plugin)
  local helpers = require(script.Parent.helpers)
  local tagging = require(script.Parent.tagging)
  -- local scale = require(script.scale)

  local globalSettings = PluginSettings.new("global")

  local MAKE_PRIMARY_PART_INVISIBLE = constants.settings.MAKE_PRIMARY_PART_INVISIBLE
  local TAG_PREFIX = constants.settings.TAG_PREFIX
  local PREVENT_COLLISIONS = constants.settings.PREVENT_COLLISIONS

  local exports = {}

  local function isAPrefab(instance)
    return typeof(instance) == "Instance"
      and instance:IsA("Model")
      and instance.PrimaryPart
  end

  local function validatePrefab(prefab)
    local name = prefab.Name

    -- Ideally we could reuse isAPrefab() here, but because we need individual
    -- errors we have to rewrite some stuff.

    assert(typeof(prefab) == "Instance" and prefab:IsA("Model"),
      constants.errors.MUST_BE_MODEL:format(name, type(prefab)))
    assert(prefab.PrimaryPart, constants.errors.MUST_HAVE_PRIMARY_PART:format(name))
  end

  local function getPrefabTagPattern()
    return "^" .. globalSettings:Get(TAG_PREFIX)
  end

  local function getPrefabTags()
    local tagList = ServerStorage:FindFirstChild("TagList")
    local prefabTags = {}

    if tagList then
      for _, tag in pairs(tagList:GetChildren()) do
        local tagName = tag.Name
        if tagName:match(getPrefabTagPattern()) then
          table.insert(prefabTags, tagName)
        end
      end
    end

    return prefabTags
  end

  local function getPrefabs()
    local found = {}

    for _, tag in pairs(getPrefabTags()) do
      for _, prefab in pairs(CollectionService:GetTagged(tag)) do
        if isAPrefab(prefab) then
          table.insert(found, prefab)
        end
      end
    end

    return found
  end

  -- Finds the first prefab that is an ancestor of the given instance.
  --
  -- We use this so the user can have a part for the selection and still be able
  -- to update the prefab they're working on. Prior to this you had to select
  -- the model to update, which breaks your flow.
  local function getAncestorPrefab(instance)
    local all = getPrefabs()
    for _, prefab in pairs(all) do
      if prefab:IsAncestorOf(instance) then
        return prefab
      end
    end
  end

  -- Gets the tag for the prefab.
  --
  -- This tag is used to associate the prefab with placeholders in the workspace.
  --
  -- Each prefab can only have one of these tags. Having more than one "prefab"
  -- tag will only result in the first being picked up.
  local function getPrefabTag(prefab)
    for _, tag in pairs(CollectionService:GetTags(prefab)) do
      if tag:match(getPrefabTagPattern()) then
        return tag
      end
    end
  end

  local function getTagForName(name)
    return globalSettings:Get(TAG_PREFIX) .. ":" .. name
  end

  local function stripExistingTag(prefab)
    local tag = getPrefabTag(prefab)
    if tag then
      CollectionService:RemoveTag(prefab, tag)
    end
  end

  local function validateNameAvailable(name)
    for _, prefab in pairs(getPrefabs()) do
      assert(name ~= prefab.Name, constants.errors.NAME_ALREADY_EXISTS:format(name))
    end
  end

  local function applySettings(prefab)
    if globalSettings:Get(MAKE_PRIMARY_PART_INVISIBLE) then
      prefab.PrimaryPart.Transparency = 1
    end

    if globalSettings:Get(PREVENT_COLLISIONS) then
      prefab.PrimaryPart.CanCollide = false
    end

    -- TODO Add back support for scaling models
    -- if placeholder:FindFirstChild("Scale") and placeholder.Scale:IsA("NumberValue") then
    --   scale(newClone, placeholder.Scale.Value)
    -- end
  end

  -- Sets the parent of a cloned in prefab.
  local function setPrefabParent(newPrefab)
    local selection = SelectionService:Get()[1]
    if selection then
      newPrefab.Parent = selection.Parent
    else
      newPrefab.Parent = workspace
    end
  end

  local function renamePrefab(prefab)
    local tag = getPrefabTag(prefab)
    local newTag = getTagForName(prefab.Name)

    for _, model in pairs(CollectionService:GetTagged(tag)) do
      model.Name = prefab.Name
      tagging.replaceTag(model, tag, newTag)
    end
  end

  -- Replaces a prefab with an updated version of itself
  local function updatePrefab(oldPrefab, newPrefab)
    local newCopy = newPrefab:Clone()

    applySettings(newCopy)

    newCopy:SetPrimaryPartCFrame(oldPrefab.PrimaryPart.CFrame)
    newCopy.Parent = oldPrefab.Parent

    oldPrefab.Parent = nil
  end

  local function getPrefabByName(name)
    local tag = getTagForName(name)
    return CollectionService:GetTagged(tag)[1]
  end

  function exports.register(model)
    validatePrefab(model)
    validateNameAvailable(model.Name)
    stripExistingTag(model)

    local tag = getTagForName(model.Name)

    tagging.registerWithTagEditor(tag)
    CollectionService:AddTag(model, tag)

    applySettings(model)

    HistoryService:SetWaypoint(constants.waypoints.REGISTERED)

    print("Successfully registered", model)
  end

  exports.registerSelection = helpers.withSelection(exports.register)

  function exports.insert(name)
    local prefab = getPrefabByName(name)

    assert(prefab, constants.errors.PREFAB_NOT_FOUND:format(name))

    local newPrefab = prefab:Clone()

    applySettings(newPrefab)
    setPrefabParent(newPrefab)
    newPrefab:MoveTo(helpers.getCameraLookat())

    SelectionService:Set({ newPrefab })
    HistoryService:SetWaypoint(constants.waypoints.INSERTED)
    print("Successfully inserted", newPrefab)
  end

  function exports.update(prefab)
    if typeof(prefab) == "Instance" and not isAPrefab(prefab) then
      prefab = getAncestorPrefab(prefab)
      assert(prefab, constants.errors.COULD_NOT_FIND_PREFAB_FROM_SELECTION:format(tostring(prefab)))
    end

    validatePrefab(prefab)

    local tag = getPrefabTag(prefab)

    assert(tag, constants.errors.NO_PREFAB_TAG:format(prefab.Name))

    for _, oldPrefab in pairs(CollectionService:GetTagged(tag)) do
      if prefab ~= oldPrefab then
        updatePrefab(oldPrefab, prefab)
      end
    end

    renamePrefab(prefab)

    HistoryService:SetWaypoint(constants.waypoints.UPDATED)

    print("Successfully updated all copies of", prefab)
  end

  exports.updateWithSelection = helpers.withSelection(exports.update)

  function exports.clean(prefab)
    validatePrefab(prefab)

    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getPrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        CollectionService:RemoveTag(otherPrefab, tag)
      end
    end

    HistoryService:SetWaypoint(constants.waypoints.CLEAN)
    tagging.clean(tag)
  end

  exports.cleanSelection = helpers.withSelection(exports.clean)

  function exports.dangerouslyDelete(prefab)
    validatePrefab(prefab)

    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getPrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        otherPrefab.Parent = nil
      end
    end

    HistoryService:SetWaypoint(constants.waypoints.DANGEROUSLY_DELETED)
  end

  exports.dangerouslyDeleteSelection = helpers.withSelection(exports.dangerouslyDelete)

  return exports
end
