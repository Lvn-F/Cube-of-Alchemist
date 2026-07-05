local function c_GiantSlime()
    giantSlime = {
        sprite = love.graphics.newImage('assets/sprite/entities/bossSlime.png'),
        bullet = love.graphics.newImage('assets/sprite/entities/gelBullet.png'),
        animSpeed = 0.1,
    }
    giantSlime.grid = anim8.newGrid(128, 128, giantSlime.sprite:getDimensions())
    giantSlime.grid = anim8.newGrid(32, 32, giantSlime.bullet:getDimensions())
    giantSlime.animate = {
        stationary = anim8.newAnimation(giantSlime.grid('1-5',1),giantSlime.animSpeed),
        bulletCharge = anim8.newAnimation(giantSlime.grid('1-3',1),giantSlime.animSpeed),
        bulletShot = anim8.newAnimation(giantSlime.grid('4-6',1),giantSlime.animSpeed),
        atkCharge = anim8.newAnimation(giantSlime.grid('6-6',1),giantSlime.animSpeed),
    }
end
return c_GiantSlime