rbx-prop-types is a Roblox version of React's [prop-types](github.com/facebook/prop-types) library. It allows for robust type checking across a table. Here's a quick example:

```lua
local PropTypes = require(game.ReplicatedStorage.PropTypes)

local validator = PropTypes.object {
    requiredString = PropTypes.string,
    optionalString = PropTypes.optional(PropTypes.string),
    shaped = PropTypes.object {
        num = PropTypes.number,
        udim = PropTypes.UDim,
        sub = PropTypes.object {
            a = PropTypes.string,
            b = PropTypes.boolean
        }
    }
}

local someData = {
    requiredString = "hello, world!",
    -- optionalString not specified - it's optional!

    shaped = {
        num = 1,
        udim = UDim.new(0, 1),
        sub = {
            a = "hi",
            b = 1,
        }
    },
}

-- you can use `assert` to throw errors when validation fails
assert(validator(someData))
```

All PropTypes validators are functions with this signature:

```lua
value -> success, reason
```

Here's an example!

```lua
local function exampleValidator(value)
    return value > 3, "value was not greater than 3"
end
```

This validator returns `true` if it is called with a number that is greater than `3`; otherwise it returns `false`. This is how every validator in PropTypes works, and it's how you can write your own.
