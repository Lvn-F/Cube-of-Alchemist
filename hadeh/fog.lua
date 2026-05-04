
local fog = {}
local shader = require 'src/shaders'
function fog:load()
    self.image = love.graphics.newImage("assets/tiles/grass.png")
    self.shader = shader.fog
    self.time = 0
end
function fog:update(dt)
    self.time = self.time + dt
    self.shader:send("time", self.time)
    self.shader:send("fogTex", self.image)
end
function fog:draw(drawWorldfunc)
    love.graphics.setShader(self.shader)
    drawWorldfunc()
    love.graphics.setShader(self.shader)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end
return fog
