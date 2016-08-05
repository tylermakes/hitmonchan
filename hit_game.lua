require("class")
require("photon_tool")
require("hit_player_ui")

HitGame = class(function(c, width, height, createdByMe, composer)
	c.width = width
	c.height = height
	c.uiHeight = height/8
	c.composer = composer
	c.createdByMe = createdByMe
	c.background = nil
	c.playerUI = nil
	c.enemyUI = nil
end)

function HitGame:create(group)
	photonTool:setName(GLOBAL_NAME)
	photonTool:addEventListener("actorJoined", self)

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

	local playerUI = HitPlayerUI("player", 0, self.height - self.uiHeight, self.width, self.uiHeight)
	playerUI:create(group)
	self.playerUI = playerUI
	self.playerUI:setName(photonTool:getName())

	local enemyUI = HitPlayerUI("enemy", 0, 0, self.width, self.uiHeight)
	enemyUI:create(group)
	self.enemyUI = enemyUI

	local otherActor = photonTool:getOtherActor()
	if (otherActor ~= nil) then
	print("GOT ACTOR:", otherActor.actorNr)
	hitTools:printObject(otherActor, 3)
		self.enemyUI:setName(otherActor.name)
	end
end

function HitGame:actorJoined(evt)
	self.enemyUI:setName(evt.actorName)
end

function HitGame:removeSelf()
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.playerUI) then
		self.playerUI:removeSelf()
		self.playerUI = nil
	end
	if (self.enemyUI) then
		self.enemyUI:removeSelf()
		self.enemyUI = nil
	end
end