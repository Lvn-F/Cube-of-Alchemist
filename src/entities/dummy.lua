local function c_Dummy(world)
    dummy = {
        sprite = love.graphics.newImage('assets/sprite/entities/dummy.png'),
        x = 500,
        y = 500,
        flashTimer = 0
    }

    dummy.collider = world:newBSGRectangleCollider(dummy.x, dummy.y, 40, 80, 8)
    dummy.collider:setCollisionClass("Enemy")
    dummy.collider:setFixedRotation(true)
    dummy.collider:setType('static')
    dummy.collider:setObject(dummy) -- lets queryCircleArea hits resolve back to this table

    function dummy:hit()
        self.flashTimer = 0.15
    end

    function dummy:update(dt)
        if self.flashTimer > 0 then
            self.flashTimer = self.flashTimer - dt
            if self.flashTimer < 0 then self.flashTimer = 0 end
        end
    end

    function dummy:draw()
        require 'src/shaders'
        if self.flashTimer > 0 then
            love.graphics.setShader(shaders.whiteout)
            -- shader:whiten()
        end
        love.graphics.draw(dummy.sprite, dummy.x, dummy.y, nil, 3, 3)
        love.graphics.setShader()
    end
    return dummy
end
return c_Dummy