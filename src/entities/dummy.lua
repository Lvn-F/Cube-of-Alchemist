local function c_Dummy(world)
    dummy = {
        sprite = love.graphics.newImage('assets/sprite/entities/dummy.png'),
        x = 500,
        y = 500
    }

    dummy.collider = world:newBSGRectangleCollider(dummy.x, dummy.y, 40, 80, 8)
    dummy.collider:setCollisionClass("Enemy")
    dummy.collider:setFixedRotation(true)
    dummy.collider:setType('static')

    function dummy:draw()
        love.graphics.draw(dummy.sprite, dummy.x, dummy.y, nil, 3, 3)
    end
    return dummy
end
return c_Dummy