local function c_Grass(world, map)
    local grass = {
        spriteSheet = love.graphics.newImage('assets/sprite/object/smallGrass.png'),
        animSpeed = 0.23,
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

                -- Each instance gets its own cloned animation, started on a
                -- random frame, so tufts don't all pulse in lockstep.
                local instAnim = grass.animate.idle:clone()
                instAnim:gotoFrame(math.random(1, #instAnim.frames))

                table.insert(grass.instances, { x = wx, y = wy, anim = instAnim })
            end
        end
    end

    -- Fallback so drawSort doesn't crash if no instances exist
    if #grass.instances > 0 then
        grass.x = grass.instances[1].x
        grass.y = grass.instances[1].y
    end

    function grass:update(dt)
        for _, inst in ipairs(self.instances) do
            inst.anim:update(dt)
        end
    end

    function grass:draw()
        -- for _, inst in ipairs(self.instances) do
        --     inst.anim:draw(self.spriteSheet, inst.x, inst.y, nil, 2, nil, 4, 4)
        -- end
    end

    return grass
end
return c_Grass