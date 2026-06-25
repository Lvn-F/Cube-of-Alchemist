local SpellCombine = require 'src/util/spellCombine'

local PlayState = {}

inventory    = require 'src/invensystem/inventory'
item         = require 'src/invensystem/item'
inv          = inventory.new(6, 3)
inventoryGui = require 'src/invensystem/gui'
inventoryGui:setInventory(inv, 50, 50)

local function getCombinedSpell()
    if not player.mainSpell or not player.secondSpell then return nil end
    return SpellCombine.getResult(player.mainSpell, player.secondSpell)
end
-- local Camera = require 'lib/hump/camera'
cam.smoother = cameraa.smooth.damped(8)
function PlayState:update(dt)
    world:update(dt)
    updateGame(dt)

    cam:lookAt(player.x, player.y)
    local scale = 3
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local mapW = map.width * map.tilewidth
    local mapH = map.height * map.tileheight
    if cam.x < w / 2 then 
        cam.x = w / 2
    end
    if cam.y < h / 2 then
        cam.y = h / 2
    end
    -- if cam.x > (mapW - w/2) then
    --     cam.x = (mapW - w/2)
    -- end
    -- if cam.y > (mapH - h/2) then
    --     cam.y = (mapH - h/2)
    -- end

    fog:update(dt)
end

function PlayState:draw()
    love.graphics.setColor(1, 1, 1, 1)

    cam:attach()
        love.graphics.push()
            love.graphics.scale(3, 3)
            drawBefore()
        love.graphics.pop()

        herbs:draw()
        drawSort.draw(map, 3)
        player:drawSpell()

        love.graphics.push()
            love.graphics.scale(3, 3)
            drawAfter()
        love.graphics.pop()
    cam:detach()

    playerStat:draw()

    if lightShards.flashActive then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", 0, 0,
            love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("[Tab] Spells   [Q/E] Cycle Main   [F] Loot", 10, love.graphics.getHeight() - 22)
    love.graphics.setColor(1, 1, 1, 1)
end

function PlayState:keypressed(key)
    local GS = require 'lib/hump/gamestate'

    if key == 'escape' then
        love.event.quit()
    end
    if player.state == 1 then
        if key == 'tab' then
            local SpellSelect = require 'src/states/spellSelect'
            GS.push(SpellSelect)

        elseif key == 'i' then
            local pauseState = require 'src/states/pause'
            GS.push(pauseState)

        elseif key == 't' then
            local playTest = require 'src/states/test'
            GS.push(playTest)
        elseif key == 'e' then
            local crafting = require 'src/states/crafting'
            GS.push(crafting)

        elseif key == 'space' and player.state == 1 then
            player.state = 3
        end
    end

    if key == 'f' then
        herbs:tryLoot(inv)
    end
end

function PlayState:mousepressed(x, y, button)
    if button == 1 then
        if player.state == 1 and player.mainSpell then
            player.spell = player.mainSpell
            player:startCharging()
        end

    elseif button == 2 then
        local combinedKey = getCombinedSpell()
        if combinedKey and player.state == 1 then
            player.spell = combinedKey
            player:startCharging()
        end
    end
end

function PlayState:mousereleased(x, y, button)
    if (button == 1 or button == 2) and player.state == 2 and player.spell then
        if player.chargeTime > 0.7 then
            player:releaseCharging()
        else
            player.chargingSpell = nil
            player.state = 1
        end
    end
end

return PlayState