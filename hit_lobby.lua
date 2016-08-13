require("class")
require("hit_room_button")

HitLobby = class(function(c, width, height, composer)
	c.width = width
	c.height = height
	c.composer = composer
	c.background = background
	c.rooms = nil
	c.roomRows = 3
	c.roomColumns = 3
	c.roomButtons = nil
	c.roomButtonWidth = c.width/3
	c.roomButtonHeight = c.height/10
	c.lobbyDisplay = nil
end)

function HitLobby:create(group)
	self.composer.removeScene("hit_game_scene") -- Get rid of the previous game if there is one
	self.lobbyDisplay = display.newGroup()
	local background = display.newRect( 0, 0, self.width, self.height )
	background:setFillColor( 0.2, 0.2, 0.4 )
	
	background.anchorX = 0;
	background.anchorY = 0;
	background.x = 0;
	background.y = 0;
	self.background = background
	self.lobbyDisplay:insert(self.background)
	

	local lobby = self
	function handleCreateRoom( )
		local name = "room:"..(math.random()*100)
		print("CREATING:", name)
		photonTool:createRoom(name)
	end


	-- Create the widget
	local createRoomButton = widget.newButton(
		{
			left = 0,
			top = 0,
			id = "createRoomButton",
			shape = "roundedRect",
			fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
			labelColor = { default={ 0, 0.0, 0.0 }, over={ 0, 0.0, 0.0 } },
			label = "Create New Room",
			width = self.width,
			height = self.roomButtonHeight,
			onRelease = handleCreateRoom,
			fontSize = 24
		}
	);

	self.createRoomButton = createRoomButton
	self.createRoomButton.alpha = 0
	self.lobbyDisplay:insert(self.createRoomButton)

	group:insert(self.lobbyDisplay)

	photonTool:addEventListener("handleRoomList", self) -- Note: the first one of these indicates that we've successfully connected
	photonTool:addEventListener("joined", self)
	photonTool:addEventListener("joinedLobby", self)
	photonTool:connect()
end

function HitLobby:handleRoomList(evt)
	print("we are connected! ", #evt.rooms)
	self:removeRoomButtons()
	self.rooms = evt.rooms
	self.roomButtons = {}
	local x, y, i, ri = 1
	for i=1, #evt.rooms do
		ri = i - 1
		x = ri % self.roomColumns * self.roomButtonWidth
		y = math.floor(ri/self.roomColumns) * self.roomButtonHeight + self.roomButtonHeight
		local roomButton = HitRoomButton(evt.rooms[i].name, x, y, self.roomButtonWidth, self.roomButtonHeight)
		roomButton:create(self.lobbyDisplay)
		roomButton:addEventListener("joinRoom", self)
		self.roomButtons[#self.roomButtons + 1] = roomButton
	end
	photonTool:setName(GLOBAL_NAME)

	-- hitTools:printObject(evt.rooms, 4, "*")
end

function HitLobby:joined(evt)
	self.composer.gotoScene( "hit_game_scene", { params = evt } )
end

function HitLobby:joinedLobby(evt)
	self.createRoomButton.alpha = 1
end

function HitLobby:joinRoom(evt)
	self.createRoomButton.alpha = 0
	self:removeRoomButtons() -- TODO: Make sure we get them again if joining the room fails
	photonTool:joinRoom(evt.room)
end

function HitLobby:removeRoomButtons()
	if (self.roomButtons) then
		for i=1, #self.roomButtons do
			self.roomButtons[i]:removeSelf()
			self.roomButtons[i] = nil
		end
	end
	self.rooms = nil
end

function HitLobby:removeSelf()
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	if (self.createRoomButton) then
		self.createRoomButton:removeSelf()
		self.createRoomButton = nil
	end
	self:removeRoomButtons()
	if (self.lobbyDisplay) then
		self.lobbyDisplay:removeSelf()
		self.lobbyDisplay = nil
	end
end