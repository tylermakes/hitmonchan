require("class")

HitRoomButton = class(function(c, label, x, y, width, height, composer)
	c.width = width
	c.height = height
	c.x = x
	c.y = y
	c.label = label
	c.labelView = nil
	c.buttonDisplay = nil
	hitTools:makeEventDispatcher(c)
end)

function HitRoomButton:create(group)
	self.buttonDisplay = display.newGroup()

	local roomButton = self
	function handleJoinRoom( )
		local joinEvent = {
			name = "joinRoom",
			room = roomButton.label
		}
		roomButton:dispatchEvent(joinEvent)
	end

	local mainButton = widget.newButton(
		{
			left = 0,
			top = 0,
			id = "mainButton",
			label = self.label,
			labelColor = { default={ 0, 0.0, 0.0 }, over={ 0, 0.0, 0.0 } },
			onRelease = handleJoinRoom,
			fontSize = 24,
			shape = "roundedRect",
			fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
			width = self.width,
			height = self.height,
		}
	);

	self.mainButton = mainButton
	self.buttonDisplay:insert(self.mainButton)

	self.buttonDisplay.anchorX = 0;
	self.buttonDisplay.anchorY = 0;
	self.buttonDisplay.x = self.x;
	self.buttonDisplay.y = self.y;
	group:insert(self.buttonDisplay)
end

function HitRoomButton:removeSelf()
	hitTools:removeEventDispatcher(self)
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.mainButton) then
		self.mainButton:removeSelf()
		self.mainButton = nil
	end
	if (self.buttonDisplay) then
		self.buttonDisplay:removeSelf()
		self.buttonDisplay = nil
	end
end