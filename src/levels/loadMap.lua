function findSpawn(targetMap)
    for _, layer in ipairs(targetMap.layers) do
        if layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                if obj.name == "move" then
                    return obj.x * 3, obj.y * 3
                end
            end
        end
    end
    return nil, nil
end
function findRespawn(targetMap)
    for _, layer in ipairs(targetMap.layers) do
        if layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                if obj.name == "respawn" then
                    return obj.x * 3, obj.y * 3
                end
            end
        end
    end
    return nil, nil
end

function loadMap(mapPath)
    ScreenWipe:start(function()
        if collect and collect.destroy then collect:destroy() end
        if grass and grass.destroy then grass:destroy() end
        if wolf and wolf.destroy then wolf:destroy() end
        if slime and slime.destroy then slime:destroy() end
        if giantSlime and giantSlime.destroy then giantSlime:destroy() end

        map = sti(mapPath .. '.lua')
        mapCollider()
        transitions:init(map)

        collect = c_Collect(world, map)
        grass = c_Grass(world, map)
        wolf = c_wolf(world, map)
        slime = c_Slime(world, map)
        giantSlime = c_GiantSlime(world, map)

        local sx, sy = findSpawn(map)
        if sx then
            player.collider:setX(sx)
            player.collider:setY(sy)
            player.x, player.y = sx, sy
        end
    end)
end
function respawn(mapPath)
    ScreenWipe:start(function()
        if collect and collect.destroy then collect:destroy() end
        if grass and grass.destroy then grass:destroy() end
        if wolf and wolf.destroy then wolf:destroy() end
        if slime and slime.destroy then slime:destroy() end
        if giantSlime and giantSlime.destroy then giantSlime:destroy() end

        map = sti(mapPath .. '.lua')
        mapCollider()
        transitions:init(map)

        collect = c_Collect(world, map)
        grass = c_Grass(world, map)
        wolf = c_wolf(world, map)
        slime = c_Slime(world, map)
        giantSlime = c_GiantSlime(world, map)

        local sx, sy = findRespawn(map)
        if sx then
            player.collider:setX(sx)
            player.collider:setY(sy)
            player.x, player.y = sx, sy
        end
    end)
end