function updateGame(dt)
    map:update(dt)
    transitions:update(dt)
    -- player
    player:update(dt)

    Shadowballs:update(dt)
    lightShards:update(dt)
    WindCharges:update(dt)
    Firecharges:update(dt)
    FireBurst:update(dt)
    --

    -- Object
    fire:update(dt)
    grass:update(dt)
    --

    -- entities
    wolf:update(dt)
    dummy:update(dt)
    --

    --
    playerStat:update()
    --
end