local herb = {
    spriteSheet = love.graphics.newImage(pathImg.plant .. 'herbPlant.png')
}
function herb:draw()
    love.graphics.draw(spriteSheet)
end

local fireHerb = {
    spriteSheet = love.graphics.newImage(pathImg.plant .. 'fireHerbPlant.png')
}
function fireHerb:draw()
    love.graphics.draw(spriteSheet)
end
return fireHerb, herb