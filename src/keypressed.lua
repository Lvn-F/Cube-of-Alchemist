function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end


    -- for testing
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
    --

    --
    if key == 'space' then
        if player.state == 1 then
            player.state = 3
        end
    end

    if key == 'q' and player.isCharging == false then
        player.spell = player.spell - 1
    end
    if key == 'e' and player.isCharging == false then
        player.spell = player.spell + 1
    end
    --
end

function love.mousepressed(x, y, button)
    if button == 1 and player.state == 1 and player.spell then
        -- player.state = 2
        player:startCharging()
    end
end
function love.mousereleased(x, y, button)
    if button == 1 and player.state == 2 and player.spell then
        -- player.state = 1
        -- player:useSpell()
        if player.chargeTime > 0.1 then
            player:releaseCharging()
        else
            player.chargingSpell = nil
            -- player.isCharging = "false"
            -- player.chargeTime = 0
            player.state = 1
        end
        -- local px, py = player.collider:getX(), player.collider:getY()
        -- local dx, dy = x - px, y - py
        -- local power = math.min(chargeTime, 1.0)
        -- table.insert(Shadowballs, shadowball.new(world, px, py, dx, dy, power))
        -- player.chargeTime = 0
    end
end