--[[
    Creates folders one after the other.

    Every argument after the first is a string for a folder name. It also reuses
    existing folders. This is good for retroactively creating complex folder
    structures.

    Usage:

        mkdir(game.ServerStorage, "Foo", "Bar")

    The resulting hierarchy will look like:

        ServerStorage
            Foo
                Bar
--]]

local newFolder = require(script.Parent.newFolder)

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

return mkdir
