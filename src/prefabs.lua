return function(plugin)
  local CollectionService = game:GetService("CollectionService")
  local HistoryService = game:GetService("ChangeHistoryService")
  local SelectionService = game:GetService("Selection")
  local ServerStorage = game:GetService("ServerStorage")

  local resources = script.Parent:FindFirstChild("resources")

  local Constants = require(resources:FindFirstChild("Constants"))
  local PluginSettings = require(resources:FindFirstChild("PluginSettings"))(plugin)
  -- local scale = require(script.scale)

  local globalSettings = PluginSettings.new("global")

  local MAKE_PRIMARY_PART_INVISIBLE = Constants.Settings.MAKE_PRIMARY_PART_INVISIBLE
  local TAG_PREFIX = Constants.Settings.TAG_PREFIX
  local PREVENT_COLLISIONS = Constants.Settings.PREVENT_COLLISIONS

  local exports = {}

  -- Creates a new copy of the first array, with all items from the second
  -- inserted at the end (in order)
  local function append(arr1, arr2)
    local new = {}
    for _, arr in ipairs{ arr1, arr2 } do
      for _, v in ipairs(arr) do
        table.insert(new, v)
      end
    end
    return new
  end

  -- Taken from the Animation Editor's rig builder. Modified to fit our needs.
  local function getCameraLookat(maxRange)
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

  local function newFolder(name, parent)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent

    return folder
  end

  local function mkdir(root, ...)
    assert(root, "argument #1 to mkdir missing, need an instance")

    local parent = root
    local lastFolder

    for _, name in pairs{ ... } do
      lastFolder = parent:FindFirstChild(name) or newFolder(name, parent)
      parent = lastFolder
    end

    return lastFolder
  end

  -- Given a callback, runs it with the first instance selection as the argument.
  --
  -- This is used in conjunction with our API below to make selection-based
  -- commands.
  local function withSelection(callback)
    return function()
      local selection = SelectionService:Get()[1]

      assert(selection, Constants.Errors.NOTHING_SELECTED)

      return callback(selection)
    end
  end

  local function replaceTag(model, oldTag, newTag)
    CollectionService:RemoveTag(model, oldTag)
    CollectionService:AddTag(model, newTag)
  end

  -- TODO Add support for removing tags from the editor
  -- When no other prefab tags are present it should also remove the tag group
  local function registerWithTagEditor(tag)
    mkdir(ServerStorage, "TagGroupList", Constants.Tagging.TAG_GROUP_NAME)

    local tagFolder = mkdir(ServerStorage, Constants.Tagging.TAG_FOLDER_NAME, tag)

    local group = Instance.new("StringValue")
    group.Name = "Group"
    group.Value = Constants.Tagging.TAG_GROUP_NAME
    group.Parent = tagFolder
  end

  local function getStorage()
    return ServerStorage:FindFirstChild(Constants.Names.MODEL_CONTAINER)
  end

  local function getOrCreateStorage()
    return getStorage() or newFolder(Constants.Names.MODEL_CONTAINER, ServerStorage)
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
      Constants.Errors.MUST_BE_MODEL:format(name, type(prefab)))
    assert(prefab.PrimaryPart, Constants.Errors.MUST_HAVE_PRIMARY_PART:format(name))
  end

  -- Gets a flat list of all the prefabs
  local function getPrefabs(location, found)
    found = found or {}

    for _, child in pairs(location:GetChildren()) do
      if child:IsA("Folder") then
        getPrefabs(child, found)
      elseif isAPrefab(child) then
        table.insert(found, child)
      end
    end

    return found
  end

  local function getClonedPrefabs()
    return getPrefabs(workspace)
  end

  local function getSourcePrefabs()
    local storage = getStorage()

    assert(storage, Constants.Errors.NO_PREFABS_YET)

    return getPrefabs(storage)
  end

  local function getAllPrefabs()
    return append(getSourcePrefabs(), getClonedPrefabs())
  end

  -- Finds the first prefab that is an ancestor of the given instance.
  --
  -- We use this so the user can have a part for the selection and still be able
  -- to update the prefab they're working on. Prior to this you had to select
  -- the model to update, which breaks your flow.
  local function getAncestorPrefab(instance)
    for _, prefab in pairs(getAllPrefabs()) do
      if instance:IsDescendantOf(prefab) then
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

  -- Takes a callback to run on each prefab.
  --
  -- The callback is passed the prefab itself, and the tag associated with the
  -- prefab.
  local function forEachPrefab(callback)
    local prefabs = getSourcePrefabs()

    for _, prefab in pairs(prefabs) do
      local tag = getPrefabTag(prefab)

      assert(tag, Constants.Errors.NO_PREFAB_TAG:format(prefab:GetFullName()))

      -- If the callback returns anything we want to exit out of the loop and
      -- return that result.
      local result = callback(prefab, tag)
      if result then return result end
    end
  end

  local function validateNameAvailable(name)
    forEachPrefab(function(prefab)
      assert(name ~= prefab.Name, Constants.Errors.NAME_ALREADY_EXISTS:format(name))
    end)
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
    return forEachPrefab(function(prefab)
      if CollectionService:HasTag(prefab, tag) then
        return prefab
      end
    end)
  end

  function exports.register(model)
    validatePrefab(model)
    validateNameAvailable(model.Name)
    stripExistingTag(model)

    local tag = getTagForName(model.Name)

    registerWithTagEditor(tag)
    CollectionService:AddTag(model, tag)

    local clone = model:Clone()
    clone.Name = model.Name
    clone.Parent = getOrCreateStorage()

    applySettings(model)

    HistoryService:SetWaypoint(Constants.Waypoints.REGISTERED)

    print("Successfully registered", model)
  end

  exports.registerSelection = withSelection(exports.register)

  -- Updates the prefab's name across all other copies, taking care of changing
  -- the internal tag as well.
  function exports.rename(prefab)
    local tag = getPrefabTag(prefab)
    local newTag = getTagForName(prefab.Name)

    for _, model in pairs(CollectionService:GetTagged(tag)) do
      model.Name = prefab.Name
      replaceTag(model, tag, newTag)
    end

    print("Successfully renamed", prefab)
  end

  exports.renameSelection = withSelection(exports.rename)

  function exports.insert(name)
    local prefab = getPrefabByName(name)

    assert(prefab, Constants.Errors.PREFAB_NOT_FOUND:format(name))

    local clone = prefab:Clone()

    applySettings(clone)
    setCloneParent(clone)
    clone:MoveTo(getCameraLookat())

    SelectionService:Set({ clone })
    HistoryService:SetWaypoint(Constants.Waypoints.INSERTED)
    print("Successfully inserted", clone)
  end

  function exports.update(prefab)
    if typeof(prefab) == "Instance" and not isAPrefab(prefab) then
      prefab = getAncestorPrefab(prefab)
      assert(prefab, Constants.Errors.COULD_NOT_FIND_PREFAB_FROM_SELECTION:format(tostring(prefab)))
    end

    validatePrefab(prefab)

    local tag = getPrefabTag(prefab)

    assert(tag, Constants.Errors.NO_PREFAB_TAG:format(prefab.Name))

    for _, otherPrefab in pairs(CollectionService:GetTagged(tag)) do
      if prefab ~= otherPrefab then
        updateClone(otherPrefab, prefab)
      end
    end

    HistoryService:SetWaypoint(Constants.Waypoints.UPDATED)

    print("Successfully updated all copies of", prefab)
  end

  exports.updateWithSelection = withSelection(exports.update)

  -- DEPRECATED Use `update` instead to update prefabs of the same type, instead
  -- of every single prefab in the game
  function exports.refresh()
    for _, clone in pairs(getClonedPrefabs()) do
      local source = getSourcePrefab(clone)
      updateClone(clone, source)
    end

    HistoryService:SetWaypoint(Constants.Waypoints.REFRESHED)
  end

  function exports.delete(prefab)
    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getSourcePrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        otherPrefab.Parent = nil
      end
    end

    HistoryService:SetWaypoint(Constants.Waypoints.DELETED)
  end

  exports.deleteSelection = withSelection(exports.delete)

  function exports.dangerouslyDelete(prefab)
    local tag = getPrefabTag(prefab)

    for _, otherPrefab in pairs(getAllPrefabs()) do
      if CollectionService:HasTag(otherPrefab, tag) then
        otherPrefab.Parent = nil
      end
    end

    HistoryService:SetWaypoint(Constants.Waypoints.DANGEROUSLY_DELETED)
  end

  exports.dangerouslyDeleteSelection = withSelection(exports.dangerouslyDelete)

  return exports
end
