local PlayState = {}
inventory = require 'src/invensystem/inventory'
item = require 'src/invensystem/item'
inv = inventory.new(6, 3)
inventoryGui = require 'src/invensystem/gui'
inventoryGui:setInventory(inv, 50, 50)
function PlayState:update(dt)
    world:update(dt)
    updateGame(dt)

    cam:lookAt(player.x, player.y)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    if cam.x < w / 2 then cam.x = w / 2 end
    if cam.y < h / 2 then cam.y = h / 2 end

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
    -- shaders:whiten()

    playerStat:draw()

    if lightShards.flashActive then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", 0, 0,
            love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function PlayState:keypressed(key)
    if key == "escape" then
        love.event.quit()
        return
    end
    
    local GS = require 'lib/hump/gamestate'
    if key == "t" then
        local playTest = require 'src/states/test'
        GS.push(playTest)
        return
    end
    if key == 'tab' then
        local pauseState = require 'src/states/pause'
        GS.push(pauseState)
        return
    end

    if key == 'space' and player.state == 1 then
        player.state = 3
    end

    if key == 'q' and not player.isCharging then
        player.spell = player.spell - 1
    end
    if key == 'e' and not player.isCharging then
        player.spell = player.spell + 1
    end

    if key == 'f' then
        herbs:tryLoot(inv)
    end
end

function PlayState:mousepressed(x, y, button)
    if button == 1 and player.state == 1 and player.spell then
        player:startCharging()
    end
end

function PlayState:mousereleased(x, y, button)
    if button == 1 and player.state == 2 and player.spell then
        if player.chargeTime > 0.7 then
            player:releaseCharging()
        else
            player.chargingSpell = nil
            player.state = 1
        end
    end
end

return PlayState