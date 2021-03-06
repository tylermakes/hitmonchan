require("photon_tool")
require("hit_tools")

-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"
widget = require( "widget" )

hitTools = HitTools(display.width, display.height, composer)

-- load app info for Photon Cloud
photonAppInfo = require("cloud-app-info")
photonTool = PhotonTool()
photonTool:create()

	-- TODO: get rid of this
	GLOBAL_NAME = "name"..math.random()*1000

-- load menu screen
composer.gotoScene( "hit_lobby_scene" )