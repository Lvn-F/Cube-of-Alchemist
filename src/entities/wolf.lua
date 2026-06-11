local function c_wolf()
    wolf = {
        spriteSheet = love.graphics.newImage('assets/sprite/entities/wolf.png'),
        animSpeed = 0.1,
        idleSpeed = 0.2
    }
    wolf.grid = anim8.newGrid(32, 32, wolf.spriteSheet:getWidth(), wolf.spriteSheet:getHeight())
    
    wolf.animate = {
        idleRight = anim8.newAnimation(wolf.grid('1-4', 1), wolf.idleSpeed),
        right = anim8.newAnimation(wolf.grid('1-4', 2), wolf.animSpeed),
        idleLeft = anim8.newAnimation(wolf.grid('1-4', 3), wolf.idleSpeed),
        left = anim8.newAnimation(wolf.grid('1-4', 4), wolf.animSpeed),
        idleDown = anim8.newAnimation(wolf.grid('1-4', 5), wolf.idleSpeed),
        down = anim8.newAnimation(wolf.grid('1-4', 6), wolf.animSpeed),
        idleUp = anim8.newAnimation(wolf.grid('1-4', 7), wolf.idleSpeed),
        up = anim8.newAnimation(wolf.grid('1-4', 8), wolf.animSpeed)
    }

    wolf.instance = {}
    for i = 1, 3 do
        local wolfs = {
            x = math.random(200, 600),
            y = math.random(1000, 1250),
            speed = 170,
            dirX = 0,
            dirY = 0
        }
        
        wolfs.animate = {
            idleRight = wolf.animate.idleRight:clone(),
            right     = wolf.animate.right:clone(),
            idleLeft  = wolf.animate.idleLeft:clone(),
            left      = wolf.animate.left:clone(),
            idleDown  = wolf.animate.idleDown:clone(),
            down      = wolf.animate.down:clone(),
            idleUp    = wolf.animate.idleUp:clone(),
            up        = wolf.animate.up:clone()
        }
        wolfs.anim = wolfs.animate.idleDown 

        wolfs.collider = world:newBSGRectangleCollider(wolfs.x, wolfs.y, 55, 70, 16)
        wolfs.collider:setCollisionClass("Enemy")
        wolfs.collider:setFixedRotation(true)
        wolfs.collider:setType('dynamic')
        wolfs.collider:setLinearVelocity(wolfs.dirX * wolfs.speed, wolfs.dirY * wolfs.speed)
        wolfs.x, wolfs.y = wolfs.collider:getPosition()
        table.insert(wolf.instance, wolfs)
    end

    function wolf:dirAnim(wolfs)
        if wolfs.dirX == 1 then
            wolfs.anim = wolfs.animate.right
        elseif wolfs.dirX == -1 then
            wolfs.anim = wolfs.animate.left
        elseif wolfs.dirY == 1 then
            wolfs.anim = wolfs.animate.down
        elseif wolfs.dirY == -1 then
            wolfs.anim = wolfs.animate.up
        else
            if wolfs.anim == wolfs.animate.right then
                wolfs.anim = wolfs.animate.idleRight
            elseif wolfs.anim == wolfs.animate.left then
                wolfs.anim = wolfs.animate.idleLeft
            elseif wolfs.anim == wolfs.animate.down then
                wolfs.anim = wolfs.animate.idleDown
            elseif wolfs.anim == wolfs.animate.up then
                wolfs.anim = wolfs.animate.idleUp
            end
        end
    end

    function wolf:update(dt)
        for _, wolfs in ipairs(wolf.instance) do
            if math.random() < 0.01 then
                wolfs.dirX = math.random(-1, 1)
                wolfs.dirY = math.random(-1, 1)
            end
            
            wolf:dirAnim(wolfs)
            
            wolfs.x = wolfs.x + wolfs.dirX * wolfs.speed * dt
            wolfs.y = wolfs.y + wolfs.dirY * wolfs.speed * dt
            
            if wolfs.x < 200 then wolfs.x = 200; wolfs.dirX = 1 end
            if wolfs.y < 1500 then wolfs.y = 1500; wolfs.dirY = 1 end
            if wolfs.x > 1000 then wolfs.x = 1000; wolfs.dirX = -1 end
            if wolfs.y > 2000 then wolfs.y = 2000; wolfs.dirY = -1 end
            
            wolfs.collider:setLinearVelocity(wolfs.dirX * wolfs.speed, wolfs.dirY * wolfs.speed)
            wolfs.x, wolfs.y = wolfs.collider:getPosition()
            
            wolfs.anim:update(dt) 
        end
    end

    function wolf:draw()
        for _, wolfs in ipairs(self.instance) do
            wolfs.anim:draw(self.spriteSheet, wolfs.x, wolfs.y, nil, 4, nil, 16, 16)
        end
    end
    
    return wolf
end
return c_wolf