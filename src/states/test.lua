local playTest = {}

function playTest:update(dt)
    world:update(dt)
    updateGame(dt)

    -- shaders.light:send("firePosition", {fire.x + 90, fire.y - 90})

    cam:lookAt(player.x, player.y)
    local h, w = love.graphics.getHeight(), love.graphics.getWidth()
    if cam.x < w / 2 then cam.x = w / 2 end
    if cam.y < h / 2 then cam.y = h / 2 end
end

function playTest:draw()
    love.graphics.setColor(1, 1, 1, 1)
    cam:attach()
        love.graphics.push()
            love.graphics.scale(3, 3)
            drawBefore()
        love.graphics.pop()

        drawSort.draw(map, 3)
        player:drawSpell()
        world:draw()
        
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

    local debug = require 'src/debug'
    debug:player()
end
function playTest:keypressed(key)
    if key == "escape" then
        love.event.quit()
        return
    end

    if key == "t" then
        local GS            = require 'lib/hump/gamestate'
        local PlayState = require 'src/states/play'
        GS.push(PlayState)
        return
    end

    -- HP testing keys
    if key == 'p' then
        playerStat.maxHealthContainer = playerStat.maxHealthContainer + 1
    elseif key == 'o' then
        playerStat.maxHealthContainer = playerStat.maxHealthContainer - 1
    end
    if key == 'k' then
        playerStat.health = playerStat.health - 0.25
    elseif key == 'l' then
        playerStat.health = playerStat.health + 0.25
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
end

function playTest:mousepressed(x, y, button)
    if button == 1 and player.state == 1 and player.spell then
        player:startCharging()
    end
end

function playTest:mousereleased(x, y, button)
    if button == 1 and player.state == 2 and player.spell then
        if player.chargeTime > 0.7 then
            player:releaseCharging()
        else
            player.chargingSpell = nil
            player.state = 1
        end
    end
end

return playTest