-- Built on Photon Cloud
-- Docs: http://doc-api.photonengine.com/en/corona/current/modules/loadbalancing.LoadBalancingClient.html
-- Site: https://www.photonengine.com/en-US/Realtime
-- CoronaDocs: https://docs.coronalabs.com/plugin/photon/#syntax
require("class")

PhotonTool = class(function(c)
	c.LoadBalancingClient = nil
	c.LoadBalancingConstants = nil
	c.tableutil = nil
	c.Logger = nil
	c.photon = nil
	c.client = nil
	c.state = "none"
	c.events = {}
	c.ENDCONNECTION = false -- TODO: get rid of this
	c.basicRoomOptions = {
		maxPlayers = 2
	}
end)

function PhotonTool:create()
	if pcall(require,"plugin.photon") then -- try to load Corona photon plugin
	    print("Demo: main module:","Corona plugin used")
	    self.photon = require "plugin.photon"    
	    self.LoadBalancingClient = self.photon.loadbalancing.LoadBalancingClient
	    self.LoadBalancingConstants = self.photon.loadbalancing.constants
	    self.Logger = self.photon.common.Logger
	    self.tableutil = self.photon.common.util.tableutil  
	else  -- or load photon.lua module
	    print("Demo: main module:","Lua lib used")
	    self.photon = require("photon")
	    self.LoadBalancingClient = require("photon.loadbalancing.LoadBalancingClient")
	    self.LoadBalancingConstants = require("photon.loadbalancing.constants")
	    self.Logger = require("photon.common.Logger")
	    self.tableutil = require("photon.common.util.tableutil")    
	end

	-- Reference to PhotonTool used for client functions
	local tool = self
	
	local client = self.LoadBalancingClient.new(photonAppInfo.MasterAddress, photonAppInfo.AppId, photonAppInfo.AppVersion)
	client:setLogLevel(self.Logger.Level.FATAL) -- limits to fatal logs, remove to see what Photon is doing

	local EVENT_CODE = 101 -- TODO: actually make this communicate useful information

	-- send data doesn't work yet, we need to join a room
	function client:sendData()
		--print("is joined?", self:isJoinedToRoom())
		if self:isJoinedToRoom() then
			local data = {}
			data[2] = "This is our data!"
			data[3] = string.rep("x", 160)
			self:raiseEvent(EVENT_CODE, data, { receivers = tool.LoadBalancingConstants.ReceiverGroup.All } ) 
		end
	end

	function client:onOperationResponse(errorCode, errorMsg, code, content)
		print("========OPERATION RESPONSE ec:", errorCode, " er:", errorMsg, " c:", code, " table:", tool.tableutil.toStringReq(content))
    end

	-- on event isn't triggered yet because our data isn't being sent
	function client:onEvent(code, content, actorNr)
		self.logger:debug("on event", code, tool.tableutil.toStringReq(content))
		if code == EVENT_CODE then
			print("received1:", content[1])
			print("received2:", content[2])
			print("received3:", content[3])
			self:disconnect();
			tool.ENDCONNECTION = true;
		else
			print("received unknown event")
		end
	end

	function client:onRoomList(rooms)
		-- print("==== GOT ROOMS LIST?")
		-- for k,v in pairs(rooms) do
		-- 	print(k,v)
		-- end

		-- Following code auto joins room if available, else creates a room
		local roomArray = {}
		for k,v in pairs(rooms) do
			print("JOINING:", k)
			self:joinRoom(k)
			roomArray[#roomArray + 1] = v
		end

		if (#roomArray >= 1) then
			local connectedEvent = {
				name = "connected",
				rooms = roomArray
			}
			tool:dispatchEvent(connectedEvent)
			return
		end
		
		local name = "helloworld"..(math.random()*100)
		print("CREATING:", name)
		self:createRoom(name, self.basicRoomOptions)
	end

	function client:onStateChange(state)
		print("state:", state, tostring(tool.LoadBalancingClient.StateToName(state)))
		if (state == tool.LoadBalancingClient.State.JoinedLobby) then
			print("joined lobby")
		end
		if (state == tool.LoadBalancingClient.State.Joined) then
		end
	end

	self.client = client
	self.state = "created"
end

function PhotonTool:connect()
	if (self.state == "created") then
		self.client.logger:info("Start")
		self.client:connect()
		self.runTimes = 0
		self.timerTable = timer.performWithDelay( 100, self, 0)	-- TODO: test that table can be used to cancel timer
		self.state = "connecting"
	end
end

function PhotonTool:printAvailableRooms()
	local availableRooms = self.client:availableRooms()
	print("==========available rooms:")
	for k,v in pairs(availableRooms) do
		print("kv:",k,v)
	end
	if (#availableRooms > 0) then
		print("availRoom:",availableRooms[0])
	end
end

function PhotonTool:update()
    --self.client:sendData()
    self.client:service()
	--print(self.client:availableRooms())
end

function PhotonTool:timer(event)
	local str = nil
	self:update()
	if (self.ENDCONNECTION) then
		timer.cancel(event.source)
	end
end

function PhotonTool:addEventListener(type, object)
	if (not self.events[type]) then
		self.events[type] = {}
	end
	self.events[type][#self.events[type] + 1] = object
end

function PhotonTool:dispatchEvent(data)
	if (self.events[data.name]) then
		for i=1, #self.events[data.name] do
			self.events[data.name][i][data.name](self.events[data.name][i], data)
		end
	end
end

function PhotonTool:removeSelf()
	-- TODO: remove events
end