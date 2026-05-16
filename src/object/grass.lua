local function c_Grass()
    local grass = {
        spriteSheet = love.graphics.newImage('assets/tiles/grasst.png'),
        animSpeed = 0.3,
        x = 500,
        y = 700
    }
    grass.grid = anim8.newGrid(32, 64, grass.spriteSheet:getWidth(), grass.spriteSheet:getHeight())
    grass.animate = {
        idle = anim8.newAnimation(grass.grid('1-5', 1), grass.animSpeed)
    }
    grass.anim = grass.animate.idle

    function grass:update(dt)
        self.anim = self.animate.idle
        self.anim:update(dt)
    end

    function grass:draw()
        self.anim:draw(self.spriteSheet, self.x, self.y -32, nil, 2, nil, 16, 32)
        self.anim:draw(self.spriteSheet, self.x - 30, self.y -32, nil, 2, nil, 16, 32)
        self.anim:draw(self.spriteSheet, self.x - 16, self.y -32, nil, 2, nil, 16, 32)
        self.anim:draw(self.spriteSheet, self.x, self.y -32, nil, 2, nil, 16, 32)
    end
    return grass
end
return c_Grass