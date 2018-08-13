--[[
  Creates a new folder, plain and simple.
--]]

local function newFolder(name, parent)
  local folder = Instance.new("Folder")
  folder.Name = name
  folder.Parent = parent

  return folder
end

return newFolder
