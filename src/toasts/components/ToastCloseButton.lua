local root = script.Parent.Parent.Parent

local t = require(root.lib.t)
local Roact = require(root.lib.Roact)
local connect = require(root.lib.RoactRodux).UNSTABLE_connect2
local CloseButton = require(root.components.CloseButton)
local removeToast = require(script.Parent.Parent.actions.removeToast)

local Props = t.interface({
    layoutOrder = t.number,
    onClick = t.callback
})

local function ToastCloseButton(props)
    assert(Props(props))

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        LayoutOrder = self.props.layoutOrder,
        BackgroundTransparency = 1
    }, {
        Roact.createElement(CloseButton, {
            onClick = function()
                self.props.onClick(self.props.toast.id)
            end
        })
    })
end

local function mapDispatchToProps(dispatch)
    return {
        onClick = function(id)
            dispatch(removeToast(id))
        end
    }
end

return connect(nil, mapDispatchToProps)(ToastCloseButton)
