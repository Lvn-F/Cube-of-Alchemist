function updateGame(dt)
    -- player
    player:update(dt)

    Shadowballs:update(dt)
    lightShards:update(dt)
    --

    -- Object
    fire:update(dt)
    --

    -- entities
    wolf:update(dt)
    --

    --
    playerStat:update()
    --
end