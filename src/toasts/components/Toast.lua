local root = script.Parent.Parent.Parent

local t = require(root.lib.t)
local Roact = require(root.lib.Roact)
local connect = require(root.lib.RoactRodux).UNSTABLE_connect2
local constants = require(root.constants)
local SizeProvider = require(root.components.SizeProvider)
local TextLabel = require(root.components.TextLabel)
local TopBar = require(script.Parent.TopBar)
local setHoveredToast = require(script.Parent.Parent.actions.setHoveredToast)

local Props = t.interface({
    toast = t.interface({
        body = t.string
    }),
    layoutOrder = t.number
})

local function Toast(props)
    assert(Props(props))

    local layoutRef = Roact.createRef()

    return Roact.createElement(SizeProvider, {
        layoutRef = layoutRef,
        render = function(height)
            return Roact.createElement("Frame", {
                -- Padding the height to offset the top and bottom UIPadding
                Size = UDim2.new(1, 0, 0, height+(constants.ui.padding*2)),

                LayoutOrder = props.layoutOrder,
                BackgroundColor3 = constants.ui.backgroundColor,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,

                [Roact.Event.InputBegan] = function(_, input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        props.onMouseEnter(props.toast.id)
                    end
                end,

                [Roact.Event.InputEnded] = function(_, input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        props.onMouseLeave()
                    end
                end
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    [Roact.Ref] = layoutRef
                }),

                Padding = Roact.createElement("UIPadding", {
                    PaddingTop = UDim.new(0, constants.ui.padding),
                    PaddingRight = UDim.new(0, constants.ui.padding),
                    PaddingBottom = UDim.new(0, constants.ui.padding),
                    PaddingLeft = UDim.new(0, constants.ui.padding),
                }),

                TopBar = Roact.createElement(TopBar, {
                    toast = props.toast
                }),

                Body = Roact.createElement(TextLabel, {
                    Text = props.toast.body,
                    TextWrapped = true
                })
            })
        end
    })
end

local function mapDispatchToProps(dispatch)
    return {
        onMouseEnter = function(id)
            dispatch(setHoveredToast(id))
        end,
        onMouseLeave = function()
            dispatch(setHoveredToast(nil))
        end
    }
end

return connect(nil, mapDispatchToProps)(Toast)
