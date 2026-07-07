local item = require 'src/invensystem/item'

local itemDefs = {
    herbPlant = {
        name = "Herb",
        img = function() return pathImg.collectible .. "herb.png" end,
        desc = "Basic imgredient for healing potion",
        sprite = function() return pathImg.plant .. "herbPlant.png" end
    },
    fireHerbPlant = {
        name = "Fire Herb",
        img = function() return pathImg.collectible .. "fireHerb.png" end,
        desc = "You can make fire with this",
        sprite = function() return pathImg.plant .. "fireHerbPlant.png" end
    }
}

local function c_Herb(world, map)
    local herbs = {}
    local spriteCache = {}
    local function getSprite(path)
        if not spriteCache[path] then
            spriteCache[path] = love.graphics.newImage(path)
        end
        return spriteCache[path]
    end

    local objLayer = map.layers["objects"]
    if objLayer then
        for _, obj in ipairs(objLayer.objects) do
            local def = itemDefs[obj.name]
            if def then
                local wx = obj.x * 3
                local wy = obj.y * 3
                local h = {
                    x = wx,
                    y = wy,
                    name = def.name,
                    imgPath = def.img(),
                    desc = def.desc,
                    looted = false,
                    sprite = getSprite(def.sprite()),
                    collider = world:newCircleCollider(wx, wy, 40)
                }
                h.collider:setCollisionClass("Ignore")
                h.collider:setType("static")
                table.insert(herbs, h)
            end
        end
    end

    local herbs_obj = {}
    function herbs_obj:tryLoot(inventory)
        for _, h in ipairs(herbs) do
            if not h.looted then
                local dist = math.sqrt((player.x - h.x)^2 + (player.y - h.y)^2)
                if dist < 80 then
                    local itm = item.new(h.name, h.imgPath, h.desc)
                    inventory:addItem(itm)
                    h.looted = true
                    h.collider:destroy()
                end
            end
        end
    end
    function herbs_obj:destroy()
        for _, h in ipairs(herbs) do
            if not h.looted then h.collider:destroy() end
        end
    end

    function herbs_obj:draw()
        for _, h in ipairs(herbs) do
            if not h.looted then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(h.sprite, h.x, h.y, nil, 2, 2, 16, 16)

                local dist = math.sqrt((player.x - h.x)^2 + (player.y - h.y)^2)
                if dist < 80 then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.print("[F]", h.x - 10, h.y - 36, nil, 1.5)
                end
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
    return herbs_obj
end
return c_Herb