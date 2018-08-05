--[[
  Contains helper functions for dealing with prefab tags
--]]

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local constants = require(script.Parent.constants)
local helpers = require(script.Parent.helpers)

local exports = {}

function exports.replaceTag(model, oldTag, newTag)
  CollectionService:RemoveTag(model, oldTag)
  CollectionService:AddTag(model, newTag)

  local tagFolder = helpers.mkdir(ServerStorage, constants.tagging.TAG_FOLDER_NAME, oldTag)
  if tagFolder then
    tagFolder.Name = newTag
  end
end

-- TODO Add support for removing tags from the editor
-- When no other prefab tags are present it should also remove the tag group
function exports.registerWithTagEditor(tag)
  helpers.mkdir(ServerStorage, constants.tagging.TAG_GROUP_FOLDER_NAME, constants.tagging.TAG_GROUP_NAME)

  local tagFolder = helpers.mkdir(ServerStorage, constants.tagging.TAG_FOLDER_NAME, tag)

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