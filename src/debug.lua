local debug = {}
function debug:player()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 790, 16, 400, 275)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Direction : " .. player.facing, 830, 50, nil, 2)
    love.graphics.print("x : " .. math.floor(player.x), 830, 75, nil, 2)
    love.graphics.print("y : " .. math.floor(player.y), 830, 100, nil, 2)
    love.graphics.print("Frame : " .. love.timer.getFPS(), 830, 125, nil, 2)
    love.graphics.print("speed : " .. player.speed, 830, 150, nil, 2)
    love.graphics.print('Health : ' .. playerStat.health, 830, 175, nil, 2)
    -- love.graphics.print("Time : " .. time .."(dt), " .. timeS .."(s)", 50, 175, nil, 2)
    love.graphics.print("isCharging : " .. player.isCharging,  830, 200, nil, 2)
    love.graphics.print("Charge Time : " .. player.chargeTime,  830, 225, nil, 2)
    -- love.graphics.print("Charge Time : " .. lightShards.flashTimer,  830, 250, nil, 2)
    
    love.graphics.print("Player State : " .. player.state, 400, 50, nil, 2)
    love.graphics.print("Player Spell : " .. player.spell, 400, 75, nil, 2)
end
return debug