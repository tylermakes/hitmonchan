require("class")

HitRoomButton = class(function(c, label, x, y, width, height, composer)
	c.width = width
	c.height = height
	c.x = x
	c.y = y
	c.label = label
	c.labelView = nil
	c.buttonDisplay = nil
end)

function HitRoomButton:create(group)
	self.buttonDisplay = display.newGroup()

	local background = display.newRect( 0, 0, self.width, self.height )
	background:setFillColor( hitTools:randomColor(), hitTools:randomColor(), hitTools:randomColor() )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0
	background.y = 0
	self.background = background
	self.buttonDisplay:insert(self.background)

	-- ADD LABEL TEXT
	local labelOptions = {
		text = self.label,
		x = 0,
		y = 0,
		width = self.width,
		height = self.height,
		font = native.systemFont,
		fontSize = 24, 
		align = "left"
	}
	local labelView = display.newText( labelOptions )
	labelView:setFillColor( 0, 0, 0 )
	labelView.anchorX = 0
	labelView.anchorY = 0
	labelView.x = 0
	labelView.y = 0
	self.labelView = labelView
	self.buttonDisplay:insert(self.labelView)


	self.buttonDisplay.anchorX = 0;
	self.buttonDisplay.anchorY = 0;
	self.buttonDisplay.x = self.x;
	self.buttonDisplay.y = self.y;
end

function HitRoomButton:removeSelf()
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.labelView) then
		self.labelView:removeSelf()
		self.labelView = nil
	end
	if (self.buttonDisplay) then
		self.buttonDisplay:removeSelf()
		self.buttonDisplay = nil
	end
end