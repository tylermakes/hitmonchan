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

	------ STATES ------
	c.INITIALIZED = "initialized"
	c.CREATED = "created"
	c.CONNECTING = "connecting"
	c.CONNECTED = "connected"
	c.DISCONNECTED = "disconnected"
	------ /STATES ------

	c.state = c.INITIALIZED
	hitTools:makeEventDispatcher(c)

	c.END_CONNECTION_CODE = 100 -- TODO: get rid of this
	c.ENDCONNECTION = false -- TODO: get rid of this
	c.basicRoomOptions = {
		--createIfNotExists = true -- see NOTE under createRoom
	}
	c.basicRoomCreateOptions = {
		maxPlayers = 2
		--uniqueUserId = true
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

	function client:onOperationResponse(errorCode, errorMsg, code, content)
		print("========OPERATION RESPONSE ec:", errorCode, " er:", errorMsg, " c:", code, " table:", tool.tableutil.toStringReq(content))
    end

	-- on event isn't triggered yet because our data isn't being sent
	function client:onEvent(code, content, actorNr)
		print("on event", code, tool.tableutil.toStringReq(content))
		if code == self.END_CONNECTION_CODE then
			self:disconnect();
			tool.ENDCONNECTION = true;
		else
			local messageEvent = {
				name = "receivedMessage",
				code = code,
				content = content,
				actorNr = actorNr
			}
			tool:dispatchEvent(messageEvent)
		end
	end

	function client:onRoomList(rooms)
		local roomArray = {}
		for k,v in pairs(rooms) do
			roomArray[#roomArray + 1] = v
		end

		if (#roomArray >= 1) then
			local connectedEvent = {
				name = "handleRoomList",
				rooms = roomArray
			}
			--self.state = self.CONNECTED
			tool:dispatchEvent(connectedEvent)
			return
		end
	end

	function client:onStateChange(state)
		print("state:", state, tostring(tool.LoadBalancingClient.StateToName(state)))
		if (state == tool.LoadBalancingClient.State.JoinedLobby) then
			--print("joined lobby")
			local joinedEvent = {
				name = "joinedLobby"
			}
			tool:dispatchEvent(joinedEvent)
		elseif (state == tool.LoadBalancingClient.State.Disconnected) then
			local disconnectedEvent = {
				name = "onDisconnected"
			}
			self.state = self.DISCONNECTED
			tool:dispatchEvent(disconnectedEvent)
		elseif (state == tool.LoadBalancingClient.State.Error) then
			print("ERROR!!!")
			hitTools:printObject(state,4)
		end
		-- using onJoinRoom instead
		-- if (state == tool.LoadBalancingClient.State.Joined) then
		-- 	local joinedEvent = {
		-- 		name = "joined"
		-- 	}
		-- 	tool:dispatchEvent(joinedEvent)
		-- end
	end

	function client:onJoinRoom(createdByMe)
		print("JOINED:",createdByMe)
		local joinedEvent = {
			name = "joined",
			createdByMe = createdByMe
		}
		tool:dispatchEvent(joinedEvent)
	end

	function client:onActorJoin(actor)
		print("ACTOR JOINING:")
		local joinedEvent = {
			name = "actorJoined",
			actorName = actor.name
		}
		--hitTools:printObject(actor, 3)
		tool:dispatchEvent(joinedEvent)
	end

	function client:onActorPropertiesChange (actor)
		print("ACTOR PROP CHANGED:", actor.id);
		print("ACTOR PROP CHANGED:", actor.name);
	end

	function client:onRoomListUpdate( rooms, roomsUpdated, roomsAdded, roomsRemoved )
		self:onRoomList(rooms)
	end

	self.client = client
	self.state = self.CREATED
end

function PhotonTool:connect()
	print("calling connect:", self.state)
	if (self.state == self.CREATED) then
		self.client.logger:info("Start")
		self.client:connect()
		self.runTimes = 0
		self.timerTable = timer.performWithDelay( 100, self, 0)	-- TODO: test that table can be used to cancel timer
		self.state = self.CONNECTING
	end
end

function PhotonTool:disconnect()
	self.client:disconnect()
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

function PhotonTool:sendData(eventCode, data)
	if self.client:isJoinedToRoom() then
		self.client:raiseEvent(eventCode, data, { receivers = self.LoadBalancingConstants.ReceiverGroup.Others } ) 
	end
end

function PhotonTool:timer(event)
	local str = nil
	self:update()
	if (self.ENDCONNECTION) then
		timer.cancel(event.source)
	end
end

function PhotonTool:joinRoom(roomName)
	self.client:joinRoom(roomName, self.basicRoomOptions, self.basicRoomCreateOptions)
end

function PhotonTool:createRoom(roomName)
	-- NOTE: joinRoom with the option "createIfNotExists" will join the room, but will
	-- NOT say that it was created by this user, so we're using the separate creatRoom
	-- and joinRoom methods.
	self.client:createRoom(roomName, self.basicRoomOptions, self.basicRoomCreateOptions)
end

function PhotonTool:setName(name)
	self.client:myActor():setName(name)
end

function PhotonTool:getName()
	return self.client:myActor().name
end

function PhotonTool:getId()
	return self.client:myActor().actorNr
end

function PhotonTool:getOtherActor()
	local actors = self.client:myRoomActors()
	local myActorNumber = self.client:myActor().actorNr
	print("myActorNum:", myActorNumber)
	for i=1,#actors do
		print("actors in room:", actors[i].actorNr, ", ", actors[i].name)
		if (actors[i].actorNr ~= myActorNumber) then
			return actors[i]
		end
	end
	return nil
end

function PhotonTool:getRoomActors()
	print("ACTORS:")
	hitTools:printObject(self.client:myRoomActors(), 5)
end

function PhotonTool:reset()
	hitTools:removeEventDispatcher(self)
	self.client:reset()
	self.state = self.CREATED
end

function PhotonTool:removeSelf()
	hitTools:removeEventDispatcher(self)
end