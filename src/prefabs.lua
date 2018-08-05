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

  local function getStorage()
    return ServerStorage:FindFirstChild(constants.names.MODEL_CONTAINER)
  end

  local function getOrCreateStorage()
    return getStorage() or helpers.newFolder(constants.names.MODEL_CONTAINER, ServerStorage)
  end

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

  local function getPrefabs(parent)
    local found = {}
    for _, descendant in pairs(parent:GetDescendants()) do
      if isAPrefab(descendant) then
        table.insert(found, descendant)
      end
    end
    return found
  end

  local function getClonedPrefabs()
    return getPrefabs(workspace)
  end

  local function getSourcePrefabs()
    local storage = getOrCreateStorage()
    return getPrefabs(storage)
  end

  local function getAllPrefabs()
    return helpers.append(getSourcePrefabs(), getClonedPrefabs())
  end

  -- Finds the first prefab that is an ancestor of the given instance.
  --
  -- We use this so the user can have a part for the selection and still be able
  -- to update the prefab they're working on. Prior to this you had to select
  -- the model to update, which breaks your flow.
  local function getAncestorPrefab(instance)
    for _, prefab in pairs(getAllPrefabs()) do
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
    local prefabTagPattern = "^" .. globalSettings:Get(TAG_PREFIX)
    for _, tag in pairs(CollectionService:GetTags(prefab)) do
      if tag:match(prefabTagPattern) then
        return tag
      end
    end
  end

  local function getTagForName(name)
    return globalSettings:Get(TAG_PREFIX) .. ":" .. name
  end

  local function getSourcePrefab(prefab)
    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getSourcePrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        return otherPrefab
      end
    end
  end

  local function stripExistingTag(prefab)
    local tag = getPrefabTag(prefab)
    if tag then
      CollectionService:RemoveTag(prefab, tag)
    end
  end

  local function validateNameAvailable(name)
    for _, prefab in pairs(getSourcePrefabs()) do
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
  local function setCloneParent(clone)
    local selection = SelectionService:Get()[1]
    if selection then
      clone.Parent = selection.Parent
    else
      clone.Parent = workspace
    end
  end

  -- Replaces a cloned in prefab with an updated version of the prefab
  local function updateClone(clone, newModel)
    local newClone = newModel:Clone()

    applySettings(newClone)

    newClone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame)
    newClone.Parent = clone.Parent

    clone.Parent = nil
  end

  local function getPrefabByName(name)
    local tag = getTagForName(name)
    for _, prefab in pairs(getSourcePrefabs()) do
      if CollectionService:HasTag(prefab, tag) then
        return prefab
      end
    end
  end

  function exports.register(model)
    validatePrefab(model)
    validateNameAvailable(model.Name)
    stripExistingTag(model)

    local tag = getTagForName(model.Name)

    tagging.registerWithTagEditor(tag)
    CollectionService:AddTag(model, tag)

    local clone = model:Clone()
    clone.Name = model.Name
    clone.Parent = getOrCreateStorage()

    applySettings(model)

    HistoryService:SetWaypoint(constants.waypoints.REGISTERED)

    print("Successfully registered", model)
  end

  exports.registerSelection = helpers.withSelection(exports.register)

  function exports.rename(prefab)
    local tag = getPrefabTag(prefab)
    local newTag = getTagForName(prefab.Name)

    for _, model in pairs(CollectionService:GetTagged(tag)) do
      model.Name = prefab.Name
      tagging.replaceTag(model, tag, newTag)
    end

    print("Successfully renamed", prefab)
  end

  exports.renameSelection = helpers.withSelection(exports.rename)

  function exports.insert(name)
    local prefab = getPrefabByName(name)

    assert(prefab, constants.errors.PREFAB_NOT_FOUND:format(name))

    local clone = prefab:Clone()

    applySettings(clone)
    setCloneParent(clone)
    clone:MoveTo(helpers.getCameraLookat())

    SelectionService:Set({ clone })
    HistoryService:SetWaypoint(constants.waypoints.INSERTED)
    print("Successfully inserted", clone)
  end

  function exports.update(prefab)
    if typeof(prefab) == "Instance" and not isAPrefab(prefab) then
      prefab = getAncestorPrefab(prefab)
      assert(prefab, constants.errors.COULD_NOT_FIND_PREFAB_FROM_SELECTION:format(tostring(prefab)))
    end

    validatePrefab(prefab)

    local tag = getPrefabTag(prefab)

    assert(tag, constants.errors.NO_PREFAB_TAG:format(prefab.Name))

    for _, otherPrefab in pairs(CollectionService:GetTagged(tag)) do
      if prefab ~= otherPrefab then
        updateClone(otherPrefab, prefab)
      end
    end

    HistoryService:SetWaypoint(constants.waypoints.UPDATED)

    print("Successfully updated all copies of", prefab)
  end

  exports.updateWithSelection = helpers.withSelection(exports.update)

  function exports.clean(prefab)
    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getAllPrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        CollectionService:RemoveTag(otherPrefab, tag)
      end
    end

    HistoryService:SetWaypoint(constants.waypoints.CLEAN)
    tagging.clean(tag)
  end

  exports.cleanSelection = helpers.withSelection(exports.clean)

  function exports.dangerouslyDelete(prefab)
    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getAllPrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        otherPrefab.Parent = nil
      end
    end

    HistoryService:SetWaypoint(constants.waypoints.DANGEROUSLY_DELETED)
  end

  exports.dangerouslyDeleteSelection = helpers.withSelection(exports.dangerouslyDelete)

  return exports
end
