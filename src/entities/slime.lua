local function c_Slime()
    slime = {
        sprite = love.graphics.newImage('assets/sprite/entities/slime.png'),
        animSpeed = 0.1,
        idleSpeed = 0.2
    }
    slime.grid = anim8.newGrid(32, 32, slime.sprite:getDimensions())
    slime.animate = {
        spawn = anim8.newAnimation(slime.grid('1-10', 1), slime.animSpeed),
        idle = anim8.newAnimation(slime.grid('11-14', 1), slime.idleSpeed),
        right = anim8.newAnimation(slime.grid('11-14', 2), slime.animSpeed),
        left = anim8.newAnimation(slime.grid('11-14', 3), slime.animSpeed),
        updown = anim8.newAnimation(slime.grid('11-14, 1'), slime.animSpeed),
    }
    slime.anim = slime.animate.idle
    
    return slime
end
return c_Slime