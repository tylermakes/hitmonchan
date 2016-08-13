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
	c.initiative = -1
	c.enemyInitiative = -1
	c.id = -1
	c.enemyId = -1
	c.playerAction = nil
	c.enemyAction = nil

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
	c.PH_TAKE_ACTION = 103
	------ /PHOTON EVENTS ------

	c.gameState = c.INITIALIZING
	c.gameDisplay = nil
end)

function HitGame:create(group)
	self.composer.removeScene("hit_lobby_scene") -- Get rid of the lobby completely
	self.gameDisplay = display.newGroup()

	photonTool:setName(GLOBAL_NAME)
	photonTool:addEventListener("actorJoined", self)
	photonTool:addEventListener("receivedMessage", self)
	photonTool:addEventListener("onDisconnected", self)

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

	local playerUI = HitPlayerUI("player", true, 0, self.height - self.uiHeight, self.width, self.uiHeight)
	playerUI:create(self.gameDisplay)
	self.playerUI = playerUI
	self.playerUI:setName(photonTool:getName())
	self.playerUI:addEventListener("ready", self)
	self.playerUI:addEventListener("takeAction", self)

	local enemyUI = HitPlayerUI("enemy", false, 0, 0, self.width, self.uiHeight)
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
	-- print("MY ACTOR NAME:", GLOBAL_NAME, self.id, self.initiative)
	-- print("NEW ACTOR NAME:", evt.content.name, evt.content.id, evt.content.initiative)
	-- hitTools:printObject(evt, 4, "*")
	if (evt.code == self.PH_NAME) then
		self.enemyUI:setName(evt.content.name)
		self:enterReadyState()
	elseif (evt.code == self.PH_READY) then
		self.enemyInitiative = evt.content.initiative
		self.enemyId = evt.content.id
		self.enemyUI:showStatus("Ready!")
		self:startGameIfReady()
	elseif (evt.code == self.PH_TAKE_ACTION) then
		self:handleEnemyAction(evt.content.action)
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
	self.initiative = math.random()
	photonTool:sendData(self.PH_READY, {id = photonTool:getId(),
					status = "ready", initiative = self.initiative})
	self:startGameIfReady()
end

function HitGame:takeAction(evt)
	photonTool:sendData(self.PH_TAKE_ACTION, {id = photonTool:getId(),
					status = "action", action = evt.action})
	self.playerAction = evt.action
	local result = self:isRoundComplete()
	if (result) then
		self:handleGameOver(result)
	else
		-- NOT DONE, ENEMY'S TURN
		self.playerUI:showStatus(evt.action)
		self:setEnemyTurn()
	end

end

function HitGame:enterReadyState()
	self.gameState = self.READY
	self.playerUI:showReadyButton()
end

function HitGame:startGameIfReady( )
	if (self.initiative ~= -1 and self.enemyInitiative ~= -1) then
		self:startGame()
	end
end

function HitGame:startGame()
	print("STARTING GAME:", self.initiative, self.enemyInitiative, self.id, self.enemyId)
	if (self.initiative > self.enemyInitiative or
		(self.initiative == self.enemyInitiative and self.id > self.enemyId)) then
		self:setMyTurn()
		self.playerUI:showStatus("Take Action")
		self.enemyUI:showStatus("")
	else
		self:setEnemyTurn()
		self.enemyUI:showStatus("Taking Action")
		self.playerUI:showStatus("")
	end
end

function HitGame:handleEnemyAction( action )
	print("RECEIVED ENEMY ACTION:", self.gameState)
	if (self.gameState == self.ENEMY_TURN) then
		self.enemyAction = action
		local result = self:isRoundComplete()
		if (result) then
			print("handle enemy:", result)
			self:handleGameOver(result)
		else
			-- NOT DONE, PLAYER'S TURN
			self.enemyUI:showStatus("Action Chosen")
			self:setMyTurn()
		end
	else
		print("*** UNEXPECTED ACTION ***")
	end
end

function HitGame:handleGameOver(result)
	print("GAME OVER, winner:", self:isRoundComplete())
	if (result == "player") then
		self.playerUI:showStatus("Winner!")
		self.enemyUI:showStatus("Loser :(")
	elseif (result == "enemy") then
		self.enemyUI:showStatus("Winner!")
		self.playerUI:showStatus("Loser :(")
	else
		self.enemyUI:showStatus("TIE")
		self.playerUI:showStatus("TIE")
	end

	local function listener( event )
		photonTool:disconnect()
	end

	timer.performWithDelay( 3000, listener )
	
end

function HitGame:onDisconnected( evt )
	photonTool:reset()
	self.composer.gotoScene( "hit_lobby_scene", { params = evt } )
end

function HitGame:isRoundComplete()
	if (self.enemyAction ~= nil and self.playerAction ~=nil) then
		if (self.enemyAction == self.playerAction) then
			return "tie"
		elseif (self.enemyAction == "rock") then
			if (self.playerAction == "scissors") then
				return "enemy"
			elseif (self.playerAction == "paper") then
				return "player"
			end
		elseif (self.enemyAction == "paper") then
			if (self.playerAction == "scissors") then
				return "player"
			elseif (self.playerAction == "rock") then
				return "enemy"
			end
		elseif (self.enemyAction == "scissors") then
			if (self.playerAction == "rock") then
				return "player"
			elseif (self.playerAction == "paper") then
				return "enemy"
			end
		end
	else
		return false
	end
end

function HitGame:setMyTurn()
	self.gameState = self.MY_TURN
	self.playerUI:indicateMyTurn()
	self.enemyUI:indicateNotMyTurn()
end

function HitGame:setEnemyTurn()
	self.gameState = self.ENEMY_TURN
	self.enemyUI:indicateMyTurn()
	self.playerUI:indicateNotMyTurn()
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