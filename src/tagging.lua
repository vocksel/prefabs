--[[
  Contains helper functions for dealing with prefab tags
--]]

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local constants = require(script.Parent.constants)
local mkdir = require(script.Parent.helpers.mkdir)

local exports = {}

local function getFolderForTag(name)
  local root = ServerStorage:FindFirstChild(constants.tagging.TAG_FOLDER_NAME)
  if root then
    return root:FindFirstChild(name)
  end
end

function exports.replaceTag(model, oldTag, newTag)
  CollectionService:RemoveTag(model, oldTag)
  CollectionService:AddTag(model, newTag)

  local tagFolder = getFolderForTag(oldTag)

  if tagFolder then
    tagFolder.Name = newTag
  end
end

function exports.registerWithTagEditor(tag)
  mkdir(ServerStorage, constants.tagging.TAG_GROUP_FOLDER_NAME, constants.tagging.TAG_GROUP_NAME)

  local tagFolder = mkdir(ServerStorage, constants.tagging.TAG_FOLDER_NAME, tag)

  local group = Instance.new("StringValue")
  group.Name = "Group"
  group.Value = constants.tagging.TAG_GROUP_NAME
  group.Parent = tagFolder
end

function exports.clean(tag)
  local existingTaggedModels = CollectionService:GetTagged(tag)
  if #existingTaggedModels == 0 then
    local mainTagFolder = ServerStorage:FindFirstChild(constants.tagging.TAG_FOLDER_NAME)
    if mainTagFolder then
      local tagFolder = mainTagFolder:FindFirstChild(tag)
      if tagFolder then
        tagFolder:Destroy()
      end

      if #mainTagFolder:GetChildren() == 0 then
        mainTagFolder:Destroy()
      end
    end
  end

  -- Additional clean up of TagEditor folders
  local tagGroupList = ServerStorage:FindFirstChild(constants.tagging.TAG_GROUP_FOLDER_NAME)
  if tagGroupList then
    local prefabGroup = tagGroupList:FindFirstChild(constants.tagging.TAG_GROUP_NAME)
    if prefabGroup then
      if #prefabGroup:GetChildren() == 0 then
        prefabGroup:Destroy()
      end
    end
  end
  if #tagGroupList:GetChildren() == 0 then
    tagGroupList:Destroy()
  end
end

return exports
