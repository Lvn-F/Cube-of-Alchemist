local shader = {}

shader.white = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        return vec4(255, 255, 255, pixel.a);
    }
]]
shader.light = love.graphics.newShader[[
    extern vec2 firePosition;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
    
        float distance = length(screen_coords - firePosition);
        float fade = clamp(distance/250, 0.0, 0.1);
        
        if (distance < 200) {
            return vec4(0, 0, 0, 0);
        }
        return pixel * color;
    }
]]

function shader:darken()
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, love.graphics:getWidth(), love.graphics:getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end
function shader:whiten()
    love.graphics.setColor(1, 1, 1, 0.01)
    love.graphics.rectangle("fill", 0, 0, love.graphics:getWidth(), love.graphics:getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

shader.fog = love.graphics.newShader[[
    extern number time;
    extern Image fogTex;

    vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord) {
        vec2 offset = vec2(time * 0.02, time * 0.01);
        vec4 fogColor = Texel(fogTex, texCoord + offset);
        vec4 sceneColor = Texel(tex, texCoord);
        return mix(sceneColor, fogColor, 1);
    }
]]

return shader