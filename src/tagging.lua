--[[
  Contains helper functions for dealing with prefab tags
--]]

local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(script.Parent.Constants)
local helpers = require(script.Parent.helpers)

local exports = {}

function exports.replaceTag(model, oldTag, newTag)
  CollectionService:RemoveTag(model, oldTag)
  CollectionService:AddTag(model, newTag)
end

-- TODO Add support for removing tags from the editor
-- When no other prefab tags are present it should also remove the tag group
function exports.registerWithTagEditor(tag)
  helpers.mkdir(ServerStorage, "TagGroupList", Constants.Tagging.TAG_GROUP_NAME)

  local tagFolder = helpers.mkdir(ServerStorage, Constants.Tagging.TAG_FOLDER_NAME, tag)

  local group = Instance.new("StringValue")
  group.Name = "Group"
  group.Value = Constants.Tagging.TAG_GROUP_NAME
  group.Parent = tagFolder
end

return exports
