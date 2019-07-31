# API Reference

## Primitive types
PropTypes allows you to check if a value's type is equal to any primitive type, including Roblox-specific ones:

```lua
local isString = PropTypes.string
local isVector3 = PropTypes.Vector3
```

!!! note
    Because `function` is a Lua keyword, you need to use `PropTypes.func` to check if a value is a function.

## Optional validators
By default, all validators **require** a value. To allow `nil`, wrap the validator in `PropTypes.optional`:

```lua
-- Checks if the value is a string, while allowing it to be nil.
local optionalString = PropTypes.optional(PropTypes.string),
```

## enumOf
To check if a value is an EnumItem of a specific Enum, you can use `PropTypes.enumOf`:

```lua
-- Checks if the value is an EnumItem of the Font enum.
local isFont = PropTypes.enumOf(Enum.Font),
```

## ofClass
If you're expecting an Instance, it can be useful to specify the instance's class name. You can do this with `PropTypes.ofClass`:

```lua
-- Checks if the value is an instance descended from GuiObject.
local isGuiObject = PropTypes.ofClass("GuiObject"),
```

## tableOf
If you want to guarantee that all the values in the table match the rule, you can use `PropTypes.tableOf`:

```lua
-- Checks if the value is a table composed solely of numbers.
local isNumberTable = PropTypes.tableOf(PropTypes.number)
```

## object
Checking if a value is a table is useful in and of itself, but for more complex tables you might want to check that its *shape* is correct, too. This can be done with `PropTypes.object`:

```lua
local validator = PropTypes.object({
    -- Check that the value contains a Key1 key with a number...
    Key1 = PropTypes.number,
    -- ...and a Key2 key with a string...
    Key2 = PropTypes.string,
    -- ...and a Key3 key with a BasePart.
    Key3 = PropTypes.ofClass("BasePart"),
})
```

### oneOf
If you make your own enums, `enumOf` may not be too useful. You can validate that a value is one of several possibilities with `PropTypes.oneOf`:

```lua
-- Checks if the value is either SomeValue or SomeOtherValue.
local validator = PropTypes.oneOf({ "SomeValue", "SomeOtherValue" })
```

### tuple
`tuple` lets you construct a validator for tuples, for validating function arguments easily:

```lua
local validator = PropTypes.tuple(
    PropTypes.number,
    PropTypes.string
)
```

## Combining validators
PropTypes provides two ways to combine validator functions: allowing a value if it matches any one validator with `PropTypes.any`, and allowing a value if it matches only all the validators with `PropTypes.all`.

### any
You can say that a value can be one of many types by using `PropTypes.any`:

```lua
-- Checks if the value is a string or a number.
local stringOrNumber = PropTypes.any(
    PropTypes.string,
    PropTypes.number
)
```

This function is more general than its React contemporary `oneOfType`. It allows matching on *any* arbitrary validator, making constructs like this possible:

```lua
-- Checks if the value is either a function or an EnumItem of SortOrder.
local validator = PropTypes.any(
    PropTypes.func,
    PropTypes.enumOf(Enum.SortOrder)
)
```

### all
PropTypes allows you to combine validator functions together with `PropTypes.all`. The returned validator will only pass if the value passes *all* the child validators. Validators are checked in the order they are given.

```lua
-- Checks if the value is both a number *and* an even number.
local isEven = PropTypes.all(
    PropTypes.number,
    function(value)
        return value % 2 == 0, ("%d was not even"):format(value)
    end
)
```

!!! warning
    When you use `PropTypes.all`, be sure to list your rules in order of restrictiveness. If you want to check if a value is a number and that it's greater than or equal to zero, you should write your validator like this:

    ```lua
    local isPositive = PropTypes.all(
        PropTypes.number,
        function(value)
            return value >= 0, "value was less than 0"
        end,
    )
    ```

    If you write it in the opposite order, like this:

    ```lua
    local isPositive PropTypes.all(
        function(value)
            return value >= 0, "value was less than 0"
        end,
        PropTypes.number,
    )
    ```

    You'll get a type error if you pass a non-number value to it!