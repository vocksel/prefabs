--[[
  Supplies the height of a list layout to elements to make container frame's
  nice and responsive.

  Usage:

  Roact.createElement(SizeProvider, {
    layout = Roact.createElement("UIListLayout"),

    -- `layout` is the UIListLayout element.
    -- `height` is the height of the content.
    render = function(layout, height)
      return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, height)
      }, {
        layout = layout,

        text = Roact.createElement("TextLabel", {
          Size = UDim2.new(1, 0, 0, 16)
        })
      })
    end
  })
]]

local root = script.Parent.Parent.Parent

local Roact = require(root.lib.Roact)

local SizeProvider = Roact.PureComponent:extend("SizeProvider")

function SizeProvider:init()
  self.state = {
    height = 0
  }
end

function SizeProvider:render()
  self.props.layout.props[Roact.Ref] = function(rbx)
    if not rbx then return end

    self.heightConn = rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
      self:setState({ height = rbx.AbsoluteContentSize.Y })
    end)
  end

  return self.props.render(self.props.layout, self.state.height)
end

function SizeProvider:willUnmount()
  self.heightConn:Disconnect()
end

return SizeProvider
