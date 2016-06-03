-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"
local cloudAppInfo = require("cloud-app-info")

require("photon_tool")
photonTool = PhotonTool(cloudAppInfo)

-- load menu screen
composer.gotoScene( "hitmonchan_game_scene" )