require("class")

HitPlayerUI = class(function(c, name, x, y, width, height)
	c.width = width
	c.height = height
	c.x = x
	c.y = y
	c.name = name
	c.nameView = nil
end)

function HitPlayerUI:create(group)
	self.nameView = display.newText( self.name, 0, 0, self.width, self.height, native.systemFont, 36 )
	self.nameView.anchorX = 0
	self.nameView.anchorY = 0
	self.nameView.y = self.y
	self.nameView.x = self.x
	self.nameView:setFillColor( 1, 0, 0.5 )

	group:insert(self.nameView)
end

function HitPlayerUI:setName(name)
	self.name = name
	self.nameView.text = name
end

function HitPlayerUI:removeSelf()
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.nameView) then
		self.nameView:removeSelf()
		self.nameView = nil
	end
end