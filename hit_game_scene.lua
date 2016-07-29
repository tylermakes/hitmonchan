require("hit_game")

-----------------------------------------------------------------------------------------
--
-- hit_game_scene.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local game

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view
	game = HitGame(display.contentWidth, display.contentHeight, event.params.createdByMe, composer)
	game:create(group)
end

-- Called immediately after scene has moved onscreen:
function scene:show( event )
	local group = self.view
	
end

-- Called when scene is about to move offscreen:
function scene:hide( event )
	local group = self.view
end

-- If scene's view is removed, scene:destroy() will be called just prior to:
function scene:destroy( event )
	local group = self.view

	if (game) then
		game:removeSelf()
		game = nil
	end
end

-----------------------------------------------------------------------------------------
scene:addEventListener( "create", scene ) -- "create" event is dispatched if scene's view does not exist
scene:addEventListener( "show", scene ) -- "show" event is dispatched whenever scene transition has finished
scene:addEventListener( "hide", scene ) -- "hide" event is dispatched whenever before next scene's transition begins
-- "destroy" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- composer.purgeScene() or composer.removeScene().
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene