return function(plugin)
  local CollectionService = game:GetService("CollectionService")
  local HistoryService = game:GetService("ChangeHistoryService")
  local SelectionService = game:GetService("Selection")
  local ServerStorage = game:GetService("ServerStorage")

  local constants = require(script.Parent.constants)
  local PluginSettings = require(script.Parent.PluginSettings)(plugin)
  local tagging = require(script.Parent.tagging)
  local withSelection = require(script.Parent.helpers.withSelection)
  local getCameraLookat = require(script.Parent.helpers.getCameraLookat)
  local Maid = require(script.Parent.lib.Maid)
  local Signal = require(script.Parent.lib.Signal)
  -- local scale = require(script.scale)

  local globalSettings = PluginSettings.new("global")

  local MAKE_PRIMARY_PART_INVISIBLE = constants.settings.MAKE_PRIMARY_PART_INVISIBLE
  local TAG_PREFIX = constants.settings.TAG_PREFIX
  local PREVENT_COLLISIONS = constants.settings.PREVENT_COLLISIONS

  local lastPrefabRemoved = Signal.new()

  local exports = {
    _connections = Maid.new()
  }

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

  local function validateNameAvailable(prefab)
    local name = prefab.Name
    for _, otherPrefab in pairs(getPrefabs()) do
      if prefab ~= otherPrefab then
        assert(name ~= otherPrefab.Name, constants.errors.NAME_ALREADY_EXISTS:format(name))
      end
    end
  end

  local function applySettings(prefab)
    -- TODO These settings need to be made opt-in. See here for more info:
    -- https://github.com/vocksel/prefabs/issues/50
    --
    -- if globalSettings:Get(MAKE_PRIMARY_PART_INVISIBLE) then
    --   prefab.PrimaryPart.Transparency = 1
    -- end
    --
    -- if globalSettings:Get(PREVENT_COLLISIONS) then
    --   prefab.PrimaryPart.CanCollide = false
    -- end

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

  -- Cleans out any prefab-specific objects that shouldn't be present in a new
  -- copy of the prefab.
  local function cleanPrefab(newCopy)
    local config = newCopy:FindFirstChildOfClass("Configuration")

    if config then
      config.Parent = nil
    end
  end

  -- Copies the Configuration instance from one prefab to the new one. This
  -- allows each prefab to have its own properties.
  local function copyConfig(oldPrefab, newCopy)
    local config = oldPrefab:FindFirstChildOfClass("Configuration")

    if config then
      local copy = config:Clone()
      copy.Parent = newCopy
    end
  end

  -- Replaces a prefab with an updated version of itself
  local function updatePrefab(oldPrefab, newPrefab)
    local newCopy = newPrefab:Clone()

    applySettings(newCopy)
    cleanPrefab(newCopy)
    copyConfig(oldPrefab, newCopy)

    newCopy:SetPrimaryPartCFrame(oldPrefab.PrimaryPart.CFrame)
    newCopy.Parent = oldPrefab.Parent

    oldPrefab.Parent = nil
  end

  local function getPrefabByName(name)
    local tag = getTagForName(name)
    return CollectionService:GetTagged(tag)[1]
  end

  -- Listens for the last prefab with the given tag to be removed.
  --
  -- When this happens, the _lastPrefabRemoved event is fired. This allows us to
  -- clean things up when the last prefab of a certain type is removed from the game.
  local function listenForLastRemoval(tag)
    local maid = exports._connections

    if not maid[tag] then
      maid[tag] = CollectionService:GetInstanceRemovedSignal(tag):Connect(function()
        if #CollectionService:GetTagged(tag) == 0 then
          lastPrefabRemoved:Fire(tag)
        end
      end)
    end
  end

  function exports.register(model)
    validatePrefab(model)
    validateNameAvailable(model)
    stripExistingTag(model)

    local tag = getTagForName(model.Name)

    tagging.registerWithTagEditor(tag)
    CollectionService:AddTag(model, tag)

    applySettings(model)
    listenForLastRemoval(tag)

    HistoryService:SetWaypoint(constants.waypoints.REGISTERED)

    return constants.messages.SUCCESSFULLY_ADDED:format(tostring(model))
  end

  exports.registerSelection = withSelection(exports.register)

  function exports.insert(name)
    local prefab = getPrefabByName(name)

    assert(prefab, constants.errors.PREFAB_NOT_FOUND:format(name))

    local newPrefab = prefab:Clone()

    applySettings(newPrefab)
    setPrefabParent(newPrefab)
    newPrefab:MoveTo(getCameraLookat())

    SelectionService:Set({ newPrefab })
    HistoryService:SetWaypoint(constants.waypoints.INSERTED)

    return constants.messages.SUCCESSFULLY_INSERTED:format(tostring(newPrefab))
  end

  function exports.update(prefab)
    if typeof(prefab) == "Instance" and not isAPrefab(prefab) then
      prefab = getAncestorPrefab(prefab)
      assert(prefab, constants.errors.COULD_NOT_FIND_PREFAB_FROM_SELECTION:format(tostring(prefab)))
    end

    print(prefab)

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

    return constants.messages.SUCCESSFULLY_UPDATED:format(tostring(prefab))
  end

  exports.updateWithSelection = withSelection(exports.update)

  function exports.unlink(prefab)
    validatePrefab(prefab)

    local tag = getPrefabTag(prefab)

    CollectionService:RemoveTag(prefab, tag)
    tagging.clean(tag)

    HistoryService:SetWaypoint(constants.waypoints.CLEAN)

    return constants.messages.SUCCESSFULLY_UNLINKED:format(tostring(prefab))
  end

  exports.unlinkSelection = withSelection(exports.unlink)

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

  exports.dangerouslyDeleteSelection = withSelection(exports.dangerouslyDelete)

  function exports.listenForLastPrefabRemoval()
    for _, tag in pairs(getPrefabTags()) do
      listenForLastRemoval(tag)
    end
  end

  function exports.cleanOnRemoval()
    local conn = lastPrefabRemoved:Connect(function(tag)
      local tagList = ServerStorage:FindFirstChild("TagList")

      if tagList then
        local tagFolder = tagList:FindFirstChild(tag)

        -- The tag folder will not exist if the last prefab was renamed, in
        -- which case we're reusing the tag folder to just give it a new name.
        if tagFolder then
          tagFolder.Parent = nil
        end
      end
    end)

    exports._connections:give(conn)
  end

  return exports
end
