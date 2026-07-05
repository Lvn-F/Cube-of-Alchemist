local debug = {}
function debug:player()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 1100, 16, 400, 275)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Direction : " .. player.facing, 1130, 50, nil, 2)
    love.graphics.print("x : " .. math.floor(player.x), 1130, 75, nil, 2)
    love.graphics.print("y : " .. math.floor(player.y), 1130, 100, nil, 2)
    love.graphics.print("Frame : " .. love.timer.getFPS(), 1130, 125, nil, 2)
    love.graphics.print("speed : " .. player.speed, 1130, 150, nil, 2)
    love.graphics.print('Health : ' .. playerStat.health, 1130, 175, nil, 2)
    -- local time = 0
    -- local timeS = 0
    -- love.graphics.print("Time : " .. time .."(dt), " .. timeS .."(s)", 50, 175, nil, 2)
    love.graphics.print("isCharging : " .. tostring(player.isCharging),  1130, 200, nil, 2)
    love.graphics.print("Charge Time : " .. player.chargeTime,  1130, 225, nil, 2)
    -- love.graphics.print("Anim Pos : " .. WindCharges.animate.charge.position, 1130, 250, nil, 2)
    love.graphics.print("Anim Pos : " .. FireBurst.animate.releaseO.position, 1130, 250, nil, 2)
    -- love.graphics.print("Charge Time : " .. lightShards.flashTimer,  1130, 250, nil, 2)
    
    love.graphics.print("Player State : " .. player.state, 400, 50, nil, 2)
    love.graphics.print("Player Spell : " .. player.spell, 400, 75, nil, 2)
end
return debug