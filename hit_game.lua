require("class")
require("photon_tool")

HitGame = class(function(c, width, height, composer)
	c.width = width
	c.height = height
	c.composer = composer
	c.background = background
end)

function HitGame:create(group)
	local background = display.newRect( 0, 0, self.width, self.height )
	background:setFillColor( 0.2, 0.2, 0.2 )
	
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