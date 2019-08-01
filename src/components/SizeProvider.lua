--[[
  Supplies the height of a list layout to elements to make container frame's
  nice and responsive.

  Usage:

  local layoutRef = Roact.createRef()

  Roact.createElement(SizeProvider, {
    layoutRef = layoutRef,
    render = function(height)
      return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, height)
      }, {
        layout = Roact.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder,
          [Roact.Ref] = layoutRef
        }),

        text = Roact.createElement("TextLabel", {
          Size = UDim2.new(1, 0, 0, 16)
        })
      })
    end
  })
]]

local Roact = require(script.Parent.Parent.lib.Roact)

local SizeProvider = Roact.Component:extend("SizeProvider")

function SizeProvider:init()
  self.state = {
    height = 0
  }
end

function SizeProvider:render()
  return self.props.render(self.state.height)
end

function SizeProvider:didMount()
  local layout = self.props.layoutRef.current

  self.heightConn = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    spawn(function()
      if not self.isUnmounted then
        self:setState({ height = layout.AbsoluteContentSize.Y })
      end
    end)
  end)
end

function SizeProvider:willUnmount()
  self.isUnmounted = true
  self.heightConn:Disconnect()
end

return SizeProvider
