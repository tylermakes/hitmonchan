require("class")
require("photon_tool")

HitGame = class(function(c, width, height, createdByMe, composer)
	c.width = width
	c.height = height
	c.composer = composer
	c.background = background
	c.createdByMe = createdByMe
end)

function HitGame:create(group)
	local background = display.newRect( 0, 0, self.width, self.height )
	
	if (self.createdByMe) then
		background:setFillColor( 0.4, 0.8, 0.4 )
	else
		background:setFillColor( 0.2, 0.2, 0.2 )
	end
	
	background.anchorX = 0;
	background.anchorY = 0;
	background.x = 0;
	background.y = 0;
	self.background = background
	group:insert(self.background)
end

function HitGame:removeSelf()
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.photonTool) then
		self.photonTool:removeSelf()
		self.photonTool = nil
	end
end