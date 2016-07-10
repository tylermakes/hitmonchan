-- Built on Photon Cloud
-- Docs: http://doc-api.photonengine.com/en/corona/current/modules/loadbalancing.LoadBalancingClient.html
-- Site: https://www.photonengine.com/en-US/Realtime
-- CoronaDocs: https://docs.coronalabs.com/plugin/photon/#syntax

PhotonTool = class(function(c)
	c.LoadBalancingClient = nil
	c.LoadBalancingConstants = nil
	c.tableutil = nil
	c.Logger = nil
	c.photon = nil
	c.client = nil
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
	self.client = self.LoadBalancingClient.new(photonAppInfo.MasterAddress, photonAppInfo.AppId, photonAppInfo.AppVersion)
	self.client:connect()


	local EVENT_CODE = 101 -- TODO: actually make this communicate useful information

	-- send data doesn't work yet, we need to join a room
	function self.client:sendData()
		print("is joined?", self:isJoinedToRoom())
		if self:isJoinedToRoom() then
			local data = {}
			data[2] = "This is our data!"
			data[3] = string.rep("x", 160)
			self:raiseEvent(EVENT_CODE, data, { receivers = LoadBalancingConstants.ReceiverGroup.All } ) 
		end
	end

	-- on event isn't triggered yet because our data isn't being sent
	function self.client:onEvent(code, content, actorNr)
		self.logger:debug("on event", code, tableutil.toStringReq(content))
		if code == EVENT_CODE then
			print("received1:", content[1])
			print("received2:", content[2])
			print("received3:", content[3])
			self:disconnect();
		else
			print("received unknown event")
		end
	end

	self.client.logger:info("Start")
	self.client:sendData();
end

function PhotonTool:removeSelf()
end