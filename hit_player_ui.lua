require("class")

HitPlayerUI = class(function(c, name, x, y, width, height)
	c.width = width
	c.height = height
	c.x = x
	c.y = y
	c.name = name
	c.nameView = nil
	c.readyView = nil
	c.readyButton = nil
	c.uiDisplay = nil
	hitTools:makeEventDispatcher(c)
end)

function HitPlayerUI:create(group)
	self.uiDisplay = display.newGroup()

	self.nameView = display.newText( self.name, 0, 0, self.width, self.height, native.systemFont, 36 )
	self.nameView.anchorX = 0
	self.nameView.anchorY = 0
	self.nameView.y = self.y
	self.nameView.x = self.x
	self.nameView:setFillColor( 1, 0, 0.5 )
	self.uiDisplay:insert(self.nameView)

	self.readyView = display.newText( self.name.." is ready", 0, 0, self.width, self.height, native.systemFont, 36 )
	self.readyView.anchorX = 0
	self.readyView.anchorY = 0
	self.readyView.y = self.y
	self.readyView.x = self.x + self.width/2
	self.readyView:setFillColor( 1, 0, 0.5 )
	self.readyView.alpha = 0
	self.uiDisplay:insert(self.readyView)

	local playerUI = self
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

function HitPlayerUI:showReadyButton( )
	self.readyButton.alpha = 1
end

function HitPlayerUI:showReady( )
	self.readyView.alpha = 1
end

function HitPlayerUI:hideReadyButton( )
	self.readyButton.alpha = 0
end

function HitPlayerUI:setName(name)
	self.name = name
	self.nameView.text = name
end

function HitPlayerUI:removeSelf()
	hitTools:removeEventDispatcher(self)
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.nameView) then
		self.nameView:removeSelf()
		self.nameView = nil
	end
	if (self.readyView) then
		self.readyView:removeSelf()
		self.readyView = nil
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