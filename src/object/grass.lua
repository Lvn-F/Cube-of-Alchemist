local function c_Grass(world, map)
    local grass = {
        spriteSheet = love.graphics.newImage('assets/sprite/object/smallGrass.png'),
        animSpeed = 0.28,
        x = 0,  -- kept for drawSort compatibility (uses first instance or 0)
        y = 0,
        instances = {}
    }
    grass.grid = anim8.newGrid(16, 16, grass.spriteSheet:getWidth(), grass.spriteSheet:getHeight())
    grass.animate = {
        idle = anim8.newAnimation(grass.grid('1-4', 1), grass.animSpeed)
    }
    grass.anim = grass.animate.idle

    -- Read spawn positions from the "objects" layer
    local objLayer = map and map.layers["objects"]
    if objLayer then
        for _, obj in ipairs(objLayer.objects) do
            -- Match "grasss" (with or without trailing space, as in the map)
            if obj.name:match("^grasss") then
                local wx = obj.x * 3
                local wy = obj.y * 3
                table.insert(grass.instances, { x = wx, y = wy })
            end
        end
    end

    -- Fallback so drawSort doesn't crash if no instances exist
    if #grass.instances > 0 then
        grass.x = grass.instances[1].x
        grass.y = grass.instances[1].y
    end

    function grass:update(dt)
        self.anim = self.animate.idle
        self.anim:update(dt)
    end

    -- function grass:draw()
    --     for _, inst in ipairs(self.instances) do
    --         self.anim:draw(self.spriteSheet, inst.x, inst.y, nil, 2, nil, 8, 8)
    --     end
    -- end

    return grass
end
return c_Grass