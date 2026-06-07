local herb = {
    spriteSheet = love.graphics.newImage(pathImg.plant .. 'herb.png')
}
function herb:draw()
    love.graphics.draw(spriteSheet)
end
return herb