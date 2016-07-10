-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load app info for Photon Cloud
photonAppInfo = require("cloud-app-info")

-- load menu screen
composer.gotoScene( "hit_game_scene" )