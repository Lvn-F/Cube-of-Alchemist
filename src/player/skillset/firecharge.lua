local function c_Firecharge()
    local firecharges = {
        sprite = love.graphics.newImage(pathImg.skill .. 'firecharge.png'),
        animSpeed = 0.3,
    }
    firecharges.grid = anim8.newGrid(32, 32, firecharges.sprite:getDimensions())
    firecharges.animate = {
        charge = anim8.newAnimation(firecharges.grid('1-7',1),firecharges.animSpeed),
        chargeFull = anim8.newAnimation(firecharges.grid('8-12',1),firecharges.animSpeed),
        release = anim8.newAnimation(firecharges.grid('13-15',1),firecharges.animSpeed),
    }
    firecharges.anim = firecharges.animate.charge
end
return c_Firecharge