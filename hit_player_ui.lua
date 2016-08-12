require("class")

HitPlayerUI = class(function(c, name, isPlayer, x, y, width, height)
	c.width = width
	c.height = height
	c.x = x
	c.y = y
	c.name = name
	c.isPlayer = isPlayer
	c.nameView = nil
	c.statusView = nil
	c.readyButton = nil
	c.uiDisplay = nil
	c.rockButton = nil
	c.paperButton = nil
	c.scissorsButton = nil
	c.background = nil
	hitTools:makeEventDispatcher(c)
end)

function HitPlayerUI:create(group)
	self.uiDisplay = display.newGroup()

	self.background = display.newRect( 0, 0, self.width, self.height )
	self.background:setFillColor( 0, 0, 0 )
	self.background.anchorX = 0;
	self.background.anchorY = 0;
	self.background.x = self.x;
	self.background.y = self.y;
	self.uiDisplay:insert(self.background)

	self.nameView = display.newText( self.name, 0, 0, self.width, self.height, native.systemFont, 36 )
	self.nameView.anchorX = 0
	self.nameView.anchorY = 0
	self.nameView.y = self.y
	self.nameView.x = self.x
	self.nameView:setFillColor( 1, 0, 0.5 )
	self.uiDisplay:insert(self.nameView)

	self.statusView = display.newText( "Getting Started", 0, 0, self.width, self.height, native.systemFont, 36 )
	self.statusView.anchorX = 0
	self.statusView.anchorY = 0
	self.statusView.y = self.y
	self.statusView.x = self.x + self.width/2
	self.statusView:setFillColor( 1, 0, 0.5 )
	self.uiDisplay:insert(self.statusView)

	local playerUI = self

	function onButtonClick(evt)
		local actionEvent = {
			name = "takeAction",
			action = evt.target.id
		}
		playerUI:dispatchEvent(actionEvent)
		playerUI:hideOrShowActionButtons(0)
	end

	self.rockButton = self:makeGameButtons(self.uiDisplay, onButtonClick, "rock", 0)
	self.paperButton = self:makeGameButtons(self.uiDisplay, onButtonClick, "paper", 1)
	self.scissorsButton = self:makeGameButtons(self.uiDisplay, onButtonClick, "scissors", 2)

	function handleReady( )
		local readyEvent = {
			name = "ready"
		}
		playerUI:dispatchEvent(readyEvent)
		playerUI:hideReadyButton()
	end

	local readyButton = widget.newButton(
		{
			left = self.x + self.width/2,
			top = self.y,
			id = "readyButton",
			label = "READY!",
			labelColor = { default={ 0, 0.0, 0.0 }, over={ 0, 0.0, 0.0 } },
			onRelease = handleReady,
			fontSize = 24,
			shape = "roundedRect",
			fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
			width = self.width/2,
			height = self.height,
		}
	);
	self.readyButton = readyButton
	self.readyButton.alpha = 0
	self.uiDisplay:insert(self.readyButton)

	group:insert(self.uiDisplay)
end

function HitPlayerUI:makeGameButtons(uiDisplay, clickHandler, text, number)
	local gameButton = widget.newButton(
		{
			left = self.x + (number*self.width/3),
			top = self.y + self.height/2,
			id = text,
			label = text,
			labelColor = { default={ 0, 0.0, 0.0 }, over={ 0, 0.0, 0.0 } },
			onRelease = clickHandler,
			fontSize = 24,
			shape = "roundedRect",
			fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
			width = self.width/3,
			height = self.height/3,
		}
	);
	gameButton.alpha = 0
	return gameButton
end

function HitPlayerUI:showReadyButton( )
	self.readyButton.alpha = 1
end

function HitPlayerUI:showStatus(status)
	self.statusView.alpha = 1
	self.statusView.text = status
end

function HitPlayerUI:hideReadyButton( )
	self.readyButton.alpha = 0
end

function HitPlayerUI:setName(name)
	self.name = name
	self.nameView.text = name
end

function HitPlayerUI:indicateMyTurn()
	self.background:setFillColor( 1, 1, 1 )
	if (self.isPlayer) then
		self:hideOrShowActionButtons(1)
	end
end

function HitPlayerUI:indicateNotMyTurn()
	self.background:setFillColor( 0, 0, 0 )
	if (self.isPlayer) then
		self:hideOrShowActionButtons(0)
	end
end

function HitPlayerUI:hideOrShowActionButtons(alpha)
	self.rockButton.alpha = alpha
	self.paperButton.alpha = alpha
	self.scissorsButton.alpha = alpha
end

function HitPlayerUI:removeSelf()
	hitTools:removeEventDispatcher(self)
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.rockButton) then
		self.rockButton:removeSelf()
		self.rockButton = nil
	end
	if (self.paperButton) then
		self.paperButton:removeSelf()
		self.paperButton = nil
	end
	if (self.scissorsButton) then
		self.scissorsButton:removeSelf()
		self.scissorsButton = nil
	end
	if (self.nameView) then
		self.nameView:removeSelf()
		self.nameView = nil
	end
	if (self.statusView) then
		self.statusView:removeSelf()
		self.statusView = nil
	end
	if (self.readyButton) then
		self.readyButton:removeSelf()
		self.readyButton = nil
	end
	if (self.uiDisplay) then
		self.uiDisplay:removeSelf()
		self.uiDisplay = nil
	end
end