local grassDefs = {
    grasss = {
        name = "grass",
        sprite = function() return "assets/sprite/object/smallGrass.png" end,

    }
}
local function c_Grass()
    local grass = {
        spriteSheet = love.graphics.newImage('assets/sprite/object/smallGrass.png'),
        animSpeed = 0.3,
        x = 950,
        y = 930
    }
    grass.grid = anim8.newGrid(16, 16, grass.spriteSheet:getWidth(), grass.spriteSheet:getHeight())
    grass.animate = {
        idle = anim8.newAnimation(grass.grid('1-4', 1), grass.animSpeed)
    }
    grass.anim = grass.animate.idle
    -- local spriteCache = {}
    
    -- local function getSprite(path)
    --     if not spriteCache[path] then
    --         spriteCache[path] = love.graphics.newImage(path)
    --     end
    --     return spriteCache[path]
    -- end
    -- local objLayer = map.layers["objects"]
    -- if objLayer then
    --     for _, obj in ipairs(objLayer.objects) do
    --         local def = grassDefs[obj.name]
    --         if def then
    --             local wx = obj.x * 2
    --             local wy = obj.y * 2
    --             local g = {
    --                 x = wx,
    --                 y = wy,
    --                 name = def.name,
    --                 sprite = getSprite(def.sprite())
    --             }
    --             table.insert(grass, g)
    --         end
    --     end
    -- end
    function grass:update(dt)
        self.anim = self.animate.idle
        self.anim:update(dt)
    end

    function grass:draw()
        self.anim:draw(self.spriteSheet, self.x, self.y -16, nil, 2, nil, 4, 4)
        self.anim:draw(self.spriteSheet, self.x + 16, self.y - 32, nil, 2, nil, 4, 4)
        self.anim:draw(self.spriteSheet, self.x - 30, self.y -16, nil, 2, nil, 4, 4)
        self.anim:draw(self.spriteSheet, self.x - 60, self.y -48, nil, 2, nil, 4, 4)
        self.anim:draw(self.spriteSheet, self.x, self.y -16, nil, 2, nil, 4, 4)
        self.anim:draw(self.spriteSheet, self.x - 64, self.y -32, nil, 2, nil, 4, 4)
        self.anim:draw(self.spriteSheet, self.x - 64, self.y -16, nil, 2, nil, 4, 4)
        -- for _, g in ipairs(grass) do
        --     self.anim:draw(g.sprite, g.x, g.y)
        -- end
    end
    return grass
end
return c_Grass