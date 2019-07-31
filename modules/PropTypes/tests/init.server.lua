local ServerScriptService = game:GetService("ServerScriptService")

local TestEZ = require(ServerScriptService.TestEZ)

local testRoots = script:GetChildren()
TestEZ.TestBootstrap:run(testRoots)