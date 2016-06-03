require("class")

-- PHOTON DOCUMENTATION:
-- http://doc-api.photonengine.com/en/corona/current/modules/loadbalancing.LoadBalancingClient.html
-- http://doc-api.photonengine.com/en/corona/current/modules/loadbalancing.constants.html
-- https://docs.coronalabs.com/plugin/photon/index.html

PhotonTool = class(function(c, cloudAppInfo)
    c.LoadBalancingClient = nil
    c.LoadBalancingConstants = nil
    c.tableutil = nil
    c.photon = nil
    c.client = nil
    c.cloudAppInfo = cloudAppInfo
    c.test = "TEST!"
end)

function PhotonTool:create()
    if pcall(require,"plugin.photon") then -- try to load Corona photon plugin
        -- print("Demo: main module:","Corona plugin used")
        self.photon = require "plugin.photon"    
        self.LoadBalancingClient = self.photon.loadbalancing.LoadBalancingClient
        self.LoadBalancingConstants = self.photon.loadbalancing.constants
        -- self.logger = self.photon.common.Logger
        self.tableutil = self.photon.common.util.tableutil    
    else  -- or load photon.lua module
        -- print("Demo: main module:","Lua lib used")
        self.photon = require("photon")
        self.LoadBalancingClient = require("photon.loadbalancing.LoadBalancingClient")
        self.LoadBalancingConstants = require("photon.loadbalancing.constants")
        -- self.logger = require("photon.common.Logger")
        self.tableutil = require("photon.common.util.tableutil")    
    end

    client = self.LoadBalancingClient.new(self.cloudAppInfo.MasterAddress,
                                            self.cloudAppInfo.AppId,
                                            self.cloudAppInfo.AppVersion)

    local tool = self
    function client:onOperationResponse(errorCode, errorMsg, code, content)
        print("**** onOperationResponse", "ERROR: " .. errorCode, errorMsg,
            "CODE: " .. code, tool.tableutil.toStringReq(content))
        if errorCode ~= 0 then
            for k,v in pairs(tool.LoadBalancingConstants.ErrorCode) do
                print(k,v)
            end
            for k,v in pairs(tool.LoadBalancingConstants.OperationCode) do
                print(k,v)
            end

            -- THIS MEANS WE COULDN'T CREATE A ROOM BECAUSE IT ALREADY EXISTS, SO WE JOIN IT
            if errorCode == tool.LoadBalancingConstants.ErrorCode.GameIdAlreadyExists then
                print("&&&&& id already exists!, joining!")
                tool.client:joinRoom("roomNumber1")
            end
            -- THIS MEANS WE GOT AN ERROR IN CREATING A GAME...
            if code == tool.LoadBalancingConstants.OperationCode.CreateGame then 
                print("&&&&& failed to creat game, joining!")
                -- tool:joinRoom("roomNumber1")
            end
            if code == tool.LoadBalancingConstants.OperationCode.JoinGame then -- game join room fail (probably removed while reconnected from master to game) - reconnect
                print("reconnect")
                tool:disconnect()
            end
        end
    end

    function client:onStateChange(state)
        print("onStateChange ", state, ": " , tostring(tool.LoadBalancingClient.StateToName(state)))
        if state == tool.LoadBalancingClient.State.ConnectingToMasterserver then
            self:service()
        end
        if state == tool.LoadBalancingClient.State.JoinedLobby then
            print("joinedLobby")
            tool.client:createRoom("roomNumber1")
        end
    end

    function client:onError(errorCode, errorMsg)
        if errorCode == tool.LoadBalancingClient.PeerErrorCode.MasterAuthenticationFailed then
            errorMsg = errorMsg .. " with appId = " .. tool.appId .. "\nCheck app settings in cloud-app-info.lua"
        end
        print("onERROR", errorCode, errorMsg)
        lastErrMess = errorMsg;
    end

    function client:onEvent(code, content, actorNr)
        print("onEvent:", code, tool.tableutil.toStringReq(content))
        local EVENT_CODE = 101
        local MAX_SENDCOUNT = 5
        if code == EVENT_CODE then
            tool.client.mReceiveCount = tool.client.mReceiveCount + 1
            tool.client.mLastReceiveEvent = content[2]
            if tool.client.mReceiveCount == MAX_SENDCOUNT then
                tool.mState = "Data Received"    
                tool.client:disconnect();
            end
        end
    end

    self.client = client
    self.client:connect()

    -- ANNOYINGLY, WE HAVE TO CALL THIS SEVERAL TIMES A SECOND TO KEEP THE CONNECTION ALIVE
    timer.performWithDelay( 100, function() self.client:service() end, 0)
end

function PhotonTool:removeSelf()
end