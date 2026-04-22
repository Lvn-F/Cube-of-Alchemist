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
    wolf.anim = wolf.animate.idleDown

    wolf.instance = {}
    for i = 1, 0 do
        local wolfs = {
            x = math.random(200, 600),
            y = math.random(200, 600),
            speed = 170,
            dirX = 0,
            dirY = 0
        }
        wolfs.collider = world:newBSGRectangleCollider(wolfs.x, wolfs.y, 55, 70, 16)
        wolfs.collider:setCollisionClass("Enemy")
        wolfs.collider:setFixedRotation(true)
        wolfs.collider:setType('dynamic')
        wolfs.collider:setLinearVelocity(wolfs.dirX * wolfs.speed, wolfs.dirY * wolfs.speed)
        table.insert(wolf.instance, wolfs)
    end

    function wolf:dirAnim(wolfs)
        for _, wolf in ipairs(wolf.instance) do
            if wolfs.dirX == 1 then
                self.anim = self.animate.right
            elseif wolfs.dirX == -1 then
                self.anim = self.animate.left
            elseif wolfs.dirY == 1 then
                self.anim = self.animate.down
            elseif wolfs.dirY == -1 then
                self.anim = self.animate.up
            else
                if self.anim == self.animate.right then
                    self.anim = self.animate.idleRight
                elseif self.anim == self.animate.left then
                    self.anim = self.animate.idleLeft
                elseif self.anim == self.animate.down then
                    self.anim = self.animate.idleDowne
                elseif self.anim == self.animate.up then
                    self.anim = self.animate.idleUp
                end
            end
            


            -- if math.abs(wolfs.dirX) > math.abs(wolfs.dirY) then
            --     if wolfs.dirX > 0 then
            --         wolf.anim = wolf.animate.right
            --     else
            --         wolf.anim = wolf.animate.left
            --     end
            -- else
            --     if wolfs.dirY > 0 then
            --         self.anim = self.animate.down
            --     else
            --         self.anim = self.animate.up
            --     end
            -- end
        end
    end
    function wolf:update(dt)
        for _, wolfs in ipairs(wolf.instance) do
            -- wolfs:update(dt)
            if math.random() < 0.01 then
                wolfs.dirX = math.random(-1, 1)
                wolfs.dirY = math.random(-1, 1)
            end
            wolf:dirAnim(wolfs)
            wolfs.x = wolfs.x + wolfs.dirX * wolfs.speed * dt
            wolfs.y = wolfs.y + wolfs.dirY * wolfs.speed * dt
            if wolfs.x < 200 then wolfs.x = 200 wolfs.dirX = 1 end
            if wolfs.y < 200 then wolfs.y = 200 wolfs.dirY = 1 end
            if wolfs.x > 1000 then wolfs.x = 1000 wolfs.dirX = -1 end
            if wolfs.y > 1000 then wolfs.y = 1000 wolfs.dirY = -1 end
            wolfs.collider:setPosition(wolfs.x, wolfs.y)
            wolfs.collider:setLinearVelocity(wolfs.dirX * wolfs.speed, wolfs.dirY * wolfs.speed)
        end
        
        wolf.anim:update(dt)
    end

    function wolf:draw()
        for _, wolfs in ipairs(self.instance) do
            self.anim:draw(self.spriteSheet, wolfs.x, wolfs.y, nil, 4, nil, 16, 16)
        end
    end
    return wolf
end
return c_wolf