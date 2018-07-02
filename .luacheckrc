files[".luacheckrc"].global = false

stds.roblox = {
  globals = {
    "script", "workspace", "plugin"
  },

  read_globals = {
    -- Roblox globals (http://wiki.roblox.com/index.php?title=Global_namespace/Roblox_namespace)

    -- variables
    "game", "Enum", math = { fields = { "clamp" } },
    -- functions
    "delay", "elapsedTime", "settings", "spawn", "tick", "time", "typeof",
    "UserSettings", "version", "wait", "warn",
    -- classes
    "CFrame", "Color3", "Instance", "PhysicalProperties", "Ray", "Rect",
    "Region3", "TweenInfo", "UDim", "UDim2", "Vector2", "Vector3", "Random"
  }
}

exclude_files = {
  "src/ReplicatedStorage/Lib/**"
}

ignore = {
  "self"
}

max_line_length = false

std = "lua51+roblox"
