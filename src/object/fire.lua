local function c_Fire()
    local fire = {
        spriteSheet = love.graphics.newImage('assets/sprite/arrow.png'),
        animSpeed = 0.1,
        x = 200,
        y = 300
    }
    fire.grid = anim8.newGrid(64, 64, fire.spriteSheet:getWidth(), fire.spriteSheet:getHeight())
    fire.animate = {
        idle = anim8.newAnimation(fire.grid('1-3', 1), fire.animSpeed)
    }
    fire.anim = fire.animate.idle

    function fire:update(dt)
        self.anim = self.animate.idle
        self.anim:update(dt)
    end

    function fire:draw()
        self.anim:draw(self.spriteSheet, self.x, self.y -32, nil, 2, nil, 16, 32)
        -- self.anim:draw(self.spriteSheet, self.x - 50, self.y -32, nil, 2, nil, 16, 32)
    end
    return fire
end
return c_Fire