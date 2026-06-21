local pauseState = {}

guiMap = sti('map/gui2.lua')
function pauseState:load()
    -- local inventoryGui = require 'src/invensystem/inventoryGui'
    -- inventoryGui:init()
    
end
local w, h = love.graphics.getDimensions()
local guiW = guiMap.width  * guiMap.tilewidth  * 3
local guiH = guiMap.height * guiMap.tileheight * 3
local offsetX = (w - guiW) / 2
local offsetY = (h - guiH) / 2
function pauseState:update(dt)
    -- world:update(dt)
    -- updateGame(dt)

    cam:lookAt(player.x, player.y)
    local h = love.graphics.getHeight()
    local w = love.graphics.getWidth()
    if cam.x < w / 2 then cam.x = w /2 end
    if cam.y < h / 2 then cam.y = h /2 end
    love.graphics.push()
        -- love.graphics.translate(offsetX, offsetY)
        inventoryGui:update()
    love.graphics.pop()
end
function pauseState:draw()
    -- love.graphics.setColor(1, 1, 1, 1)
    
    cam:attach()
        love.graphics.push()
        love.graphics.scale(3, 3)
            drawBefore()
        love.graphics.pop()
        herbs:draw()
        playerStat:draw()
        drawSort.draw(map, 3)
        love.graphics.push()
            love.graphics.scale(3, 3)
            drawAfter()
        love.graphics.pop()
    cam:detach()
    playerStat:draw()
    love.graphics.push()
        shaders:darken()
        love.graphics.translate(offsetX + 50, offsetY + 50)
        love.graphics.scale(2.5, 2.5)
        guiMap:drawLayer(guiMap.layers["inven"])
    love.graphics.pop()
    love.graphics.push()
        -- love.graphics.translate(offsetX, offsetY)
        
        inventoryGui:draw()
    love.graphics.pop()
    
end
function pauseState:keypressed(key)
    local GS = require 'lib/hump/gamestate'
    if key == 'e' then
        local playState = require 'src/states/play'
        GS.push(playState)
        return
    end
end
function pauseState:mousepressed(x, y, b)
    inventoryGui:mousepressed(x, y, b)
end
return pauseState