--[[
  Lua-side duplication of RBXScriptSignals.

  Allows you to use the same methods as RBXScriptSignal, along with arguments
  being passed by reference, rather than being copied by the BindableEvent.

  Modified from Stravant's Signal class.

  Usage:

    local event = Signal.new()

    event:Connect(function()
      print("Something happend!")
    end)

    event:Fire()

  Constructors:

    Signal.new()
      Returns a new Signal instance.

  Methods

    Connect(function listener)
      Connects `listener` to be run when Fire() is called.

      Returns an RBXScriptConnection that you can later disconnect if you don't
      want the listener to continue firing.

      http://wiki.roblox.com/index.php?title=RBXScriptConnection

    Fire(Variant ...)
      Fires all the connected functions, passing the arguments this method was
      called with to the function.

    Wait()
      Yields the curent thread until the event fires.

      Returns all the arguments passed to Fire()

    Disconnect()
      Disconnects all of the currently connected listeners.
--]]

local Signal = {}
Signal.__index = Signal

local function getArgumentCache()
  local cache = {}

  -- Makes the cache a weak table so storing the arguments doesn't prevent the
  -- garbage collector from cleaning things up.
  setmetatable(cache, { __mode = "k" })

  return cache
end

function Signal.new()
  local self = {}

  self._Signaler = Instance.new("BindableEvent")

  -- Stores all the arguments passed to Fire(). These are then unpacked and
  -- passed to the listeners connected to the event.
  --
  -- Sending arguments through a BindableEvent's Fire() method deep copies them.
  -- When working with tables, this means you won't get the same value in the
  -- listener.
  --
  -- Caching the arguments allows us to pass them by reference so get the same
  -- value in each listener.
  self._Args = getArgumentCache()

  -- Stores all the RBXScriptConnections so we can later disconnect them all.
  self._Connections = {}

  return setmetatable(self, Signal)
end

function Signal:Connect(f)
  assert(type(f) == "function", "Can only connect functions")

  local conn = self._Signaler.Event:Connect(function()
    f(unpack(self._Args))
  end)

  table.insert(self._Connections, conn)

  return conn
end

function Signal:Fire(...)
  self._Args = { ... }
  self._Signaler:Fire()
end

function Signal:Wait()
  self._Signaler.Event:Wait()
  return unpack(self._Args)
end

function Signal:Disconnect()
  for _, conn in ipairs(self._Connections) do
    conn:Disconnect()
  end
end

return Signal
