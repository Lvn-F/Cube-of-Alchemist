local function c_Fire()
    local fire = {
        spriteSheet = love.graphics.newImage('assets/sprite/object/fire2.png'),
        animSpeed = 0.1,
        x = 500,
        y = 500
    }
    fire.grid = anim8.newGrid(32, 64, fire.spriteSheet:getWidth(), fire.spriteSheet:getHeight())
    fire.animate = {
        idle = anim8.newAnimation(fire.grid('1-12', 1), fire.animSpeed)
    }
    fire.anim = fire.animate.idle

    function fire:update(dt)
        self.anim = self.animate.idle
        self.anim:update(dt)
    end

    function fire:draw()
        self.anim:draw(self.spriteSheet, self.x, self.y -32, nil, 2, nil, 16, 32)
    end
    return fire
end
return c_Fire