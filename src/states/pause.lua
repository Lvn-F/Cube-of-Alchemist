local pauseState = {}

local inventory = require 'src/invensystem/inventory'
local item = require 'src/invensystem/item'
local inv = inventory.new(6, 3)
local inventoryGui = require 'src/invensystem/gui'
inventoryGui:setInventory(inv, 50, 50)

inv:addItem(item.new("Red Potion", pathImg.consumable .. "potion.png", "Restore small amount of health"))
inv:addItem(item.new("herb", pathImg.collectible .. "herb.png", "Basic ingredient for healing potion"))
inv:addItem(item.new("Fire Herb", pathImg.collectible .. "fireHerb.png", "Hot enough to make fire"))
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
        playerStat:draw()
        drawSort.draw(map, 3)
        love.graphics.push()
            love.graphics.scale(3, 3)
            drawAfter()
        love.graphics.pop()
    cam:detach()
    playerStat:draw()
    love.graphics.push()
        love.graphics.translate(offsetX, offsetY)
        love.graphics.scale(3, 3)
        guiMap:drawLayer(guiMap.layers["inven"])
    love.graphics.pop()
    love.graphics.push()
        -- love.graphics.translate(offsetX, offsetY)
        inventoryGui:draw()
    love.graphics.pop()
end
function pauseState:keypressed(key)
    local GS = require 'lib/hump/gamestate'
    if key == 'tab' then
        local playState = require 'src/states/play'
        GS.push(playState)
        return
    end
end
function pauseState:mousepressed(x, y, b)
    inventoryGui:mousepressed(x, y, b)
end
return pauseState