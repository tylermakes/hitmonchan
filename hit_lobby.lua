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
	c.roomButtonHeight = c.roomButtonWidth
	c.lobbyDisplay = nil
end)

function HitLobby:create(group)
	self.lobbyDisplay = display.newGroup()
	local background = display.newRect( 0, 0, self.width, self.height )
	background:setFillColor( 0.2, 0.2, 0.4 )
	
	background.anchorX = 0;
	background.anchorY = 0;
	background.x = 0;
	background.y = 0;
	self.background = background
	self.lobbyDisplay:insert(self.background)
	group:insert(self.lobbyDisplay)

	photonTool:addEventListener("connected", self)
	photonTool:connect()
end

function HitLobby:connected(evt)
	print("we are connected! ", #evt.rooms)
	self.rooms = evt.rooms
	self.roomButtons = {}
	local x, y, i, ri = 1
	for i=1, #evt.rooms do
		ri = i - 1
		x = ri % self.roomColumns * self.roomButtonWidth
		y = math.floor(ri/self.roomColumns) * self.roomButtonHeight
		local roomButton = HitRoomButton(evt.rooms[i].name, x, y, self.roomButtonWidth, self.roomButtonHeight)
		roomButton:create(self.lobbyDisplay)
		self.roomButtons[#self.roomButtons + 1] = roomButton
	end

	hitTools:printObject(evt.rooms, 4, "*")
end

function HitLobby:removeSelf()
	if (self.background) then
		self.background:removeSelf()
		self.background = nil
	end
	for i=1, #self.roomButtons do
		self.roomButtons[i]:removeSelf()
		self.roomButtons[i] = nil
	end
	if (self.lobbyDisplay) then
		self.lobbyDisplay:removeSelf()
		self.lobbyDisplay = nil
	end
end