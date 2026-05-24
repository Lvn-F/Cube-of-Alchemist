local function c_Lightbeam()
    lightbeam = {
        sprite = love.graphics.newImage('assets/sprite/player/skill/lightbeam'),
        animSpeed = 0.1
    }
    lightbeam.grid = anim.newGrid(32, 32, lightbeam.sprite:getWidth(), lightbeam.sprite:getHeight())
    lightbeam.animate = {
        charge = Anim8.newAnimation(lightbeam.grid('1-17', 1), lightbeam.animSpeed),
        chargeFull = Anim8.newAnimation(lightbeam.grid('1-1', 2), lightbeam.animSpeed)
    }
    lightbeam.anim = lightbeam.charge
end
return c_Lightbeam