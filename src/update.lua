function updateGame(dt)
    map:update(dt)
    -- player
    player:update(dt)

    Shadowballs:update(dt)
    lightShards:update(dt)
    WindCharges:update(dt)
    Firecharges:update(dt)
    --

    -- Object
    fire:update(dt)
    grass:update(dt)
    --

    -- entities
    wolf:update(dt)
    --

    --
    playerStat:update()
    --
end