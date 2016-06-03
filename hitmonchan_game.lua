require("class")

HitmonchanGame = class(function(c, width, height, composer)
    c.width = width
    c.height = height
    c.composer = composer
end)

function HitmonchanGame:create(group)
    print("============= START PHOTON ================")
    photonTool:create()
    Runtime:addEventListener("enterFrame", self)
end

function HitmonchanGame:entered(group)
end

function HitmonchanGame:left( )
end

function HitmonchanGame:enterFrame()
end

function HitmonchanGame:update()
end


function HitmonchanGame:removeSelf()
    Runtime:removeEventListener("enterFrame", self)
end