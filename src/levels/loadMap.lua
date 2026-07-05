local function findSpawn(targetMap)
    for _, layer in ipairs(targetMap.layers) do
        if layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                if obj.name == "player" then
                    return obj.x * 3, obj.y * 3
                end
            end
        end
    end
    return nil, nil
end

function loadMap(mapPath)
    ScreenWipe:start(function()
        if herbs and herbs.destroy then herbs:destroy() end
        if grass and grass.destroy then grass:destroy() end
        if wolf and wolf.destroy then wolf:destroy() end
        if slime and slime.destroy then slime:destroy() end

        map = sti(mapPath .. '.lua')
        mapCollider()
        transitions:init(map)

        herbs = c_Herb(world, map)
        grass = c_Grass(world, map)
        wolf = c_wolf(world, map)
        slime = c_Slime(world, map)

        local sx, sy = findSpawn(map)
        if sx then
            player.collider:setX(sx)
            player.collider:setY(sy)
            player.x, player.y = sx, sy
        end
    end)
end