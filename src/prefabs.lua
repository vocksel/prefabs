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

  local function getStorage()
    return ServerStorage:FindFirstChild(Constants.Names.MODEL_CONTAINER)
  end

  local function getOrCreateStorage()
    local storage = getStorage()

    if not storage then
      storage = Instance.new("Folder")
      storage.Name = Constants.Names.MODEL_CONTAINER
      storage.Parent = ServerStorage
    end

    return storage
  end

  local function validatePrefab(prefab)
    local name = prefab.Name

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
    local prefabTagPattern = "^" .. globalSettings:Get(TAG_PREFIX)
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
  local function forEachPrefab(callback)
    local storage = getStorage()

    assert(storage, Constants.Errors.NO_PREFABS_YET)

    local prefabs = getPrefabs(storage)

    for _, prefab in pairs(prefabs) do
      local tag = getPrefabTag(prefab)

      assert(tag, Constants.Errors.NO_PREFAB_TAG:format(prefab:GetFullName()))

      -- If the callback returns anything we want to exit out of the loop and
      -- return that result.
      local result = callback(prefab, tag)
      if result then return result end
    end
  end

  local function getClones(tag)
    local found = {}
    for _, model in pairs(CollectionService:GetTagged(tag)) do
      if model:IsDescendantOf(workspace) then
        table.insert(found, model)
      end
    end
    return found
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

  local function getTagForName(name)
    return globalSettings:Get(TAG_PREFIX) .. ":" .. name
  end

  local function getPrefab(name)
    local tag = getTagForName(name)
    return forEachPrefab(function(prefab)
      if CollectionService:HasTag(prefab, tag) then
        return prefab
      end
    end)
  end

  function exports.register(name, model)
    validatePrefab(model)

    CollectionService:AddTag(model, getTagForName(name))

    local clone = model:Clone()
    clone.Name = name
    clone.Parent = getOrCreateStorage()

    applySettings(model)

    HistoryService:SetWaypoint(Constants.Waypoints.REGISTERED)
  end

  function exports.registerSelection(name)
    local selection = SelectionService:Get()[1]
    exports.register(name, selection)
  end

  local function replaceTag(model, oldTag, newTag)
    CollectionService:RemoveTag(model, oldTag)
    CollectionService:AddTag(model, newTag)
  end

  function exports.rename(oldName, newName)
    local oldTag = getTagForName(oldName)
    local newTag = getTagForName(newName)

    for _, model in pairs(CollectionService:GetTagged(oldTag)) do
      model.Name = newName
      replaceTag(model, oldTag, newTag)
    end
  end

  function exports.insert(name)
    local prefab = getPrefab(name)

    assert(prefab, Constants.Errors.PREFAB_NOT_FOUND:format(name))

    local clone = prefab:Clone()

    applySettings(clone)
    setCloneParent(clone)
    clone:MoveTo(getCameraLookat())

    SelectionService:Set({ clone })
    HistoryService:SetWaypoint(Constants.Waypoints.INSERTED)
  end

  function exports.refresh()
    forEachPrefab(function(prefab, prefabTag)
      local clones = getClones(prefabTag)

      for _, clone in pairs(clones) do
        local newClone = prefab:Clone()

        applySettings(newClone)

        newClone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame)
        newClone.Parent = clone.Parent

        clone.Parent = nil
      end
    end)

    HistoryService:SetWaypoint(Constants.Waypoints.REFRESHED)
  end

  return exports
end