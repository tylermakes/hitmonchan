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

	------ STATES ------
	c.INITIALIZING = "initializing"
	c.READY = "ready"
	c.MY_TURN = "myturn"
	c.ENEMY_TURN = "enemyturn"
	c.GAME_OVER = "gameover"
	------ /STATES ------

	------ PHOTON EVENTS ------
	c.PH_NAME = 101
	c.PH_READY = 102
	------ /PHOTON EVENTS ------

	c.gameState = c.INITIALIZING
	c.gameDisplay = nil
end)

function HitGame:create(group)
	self.gameDisplay = display.newGroup()

	photonTool:setName(GLOBAL_NAME)
	photonTool:addEventListener("actorJoined", self)
	photonTool:addEventListener("receivedMessage", self)

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
	self.gameDisplay:insert(self.background)

	local playerUI = HitPlayerUI("player", 0, self.height - self.uiHeight, self.width, self.uiHeight)
	playerUI:create(self.gameDisplay)
	self.playerUI = playerUI
	self.playerUI:setName(photonTool:getName())
	self.playerUI:addEventListener("ready", self)

	local enemyUI = HitPlayerUI("enemy", 0, 0, self.width, self.uiHeight)
	enemyUI:create(self.gameDisplay)
	self.enemyUI = enemyUI

	local otherActor = photonTool:getOtherActor()
	if (otherActor ~= nil) then
		print("GOT ACTOR:", otherActor.actorNr, " name:", otherActor.name)
		self.enemyUI:setName(otherActor.name)
	end

	group:insert(self.gameDisplay)
end

function HitGame:receivedMessage(evt)
	print("NEW ACTOR NAME:", evt.content.name, evt.content.id)
	if (evt.code == self.PH_NAME) then
		self.enemyUI:setName(evt.content.name)
		self:enterReadyState()
	elseif (evt.code == self.PH_READY) then
		self:startGame()
	end
end

function HitGame:actorJoined(evt)
	-- Setting the property name after new user joined, inconsistently sent name to user
	-- photonTool:setName(GLOBAL_NAME)
	-- instead, we're going to manually send it
	photonTool:sendData(self.PH_NAME, {id = photonTool:getId(), name = GLOBAL_NAME})
	self.enemyUI:setName(evt.actorName)
	self:enterReadyState()
end

function HitGame:ready(evt)
	photonTool:sendData(self.PH_READY, {id = photonTool:getId(), status = "ready"})
end

function HitGame:enterReadyState()
	self.gameState = self.READY
	self.playerUI:showReadyButton()
end

function HitGame:startGame()
	self.gameState = self.MY_TURN	-- TODO: make this correct
	self.enemyUI:showReady()
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
	if (self.gameDisplay) then
		self.gameDisplay:removeSelf()
		self.gameDisplay = nil
	end
end