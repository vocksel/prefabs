local t = require(script.Parent.Parent.lib.t)
local Roact = require(script.Parent.Parent.lib.Roact)
local constants = require(script.Parent.Parent.constants)
local playLocalSound = require(script.Parent.Parent.helpers.playLocalSound)

local Props = t.interface({
    color = t.optional(t.Color3),
    onClick = t.callback
})

local function CloseButton(props)
    assert(Props(props))

    return Roact.createElement("ImageButton", {
        Image = "rbxassetid://1432074468",
        ImageColor3 = props.color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        [Roact.Event.Activated] = function()
            playLocalSound(constants.sounds.click)
            props.onClick()
        end
    })
end

return CloseButton
