local function mapCollider()
    local collider = {}
    if map.layers["mapHitbox"] then
        for i, obj in pairs(map.layers["mapHitbox"].objects) do
            local map = world:newRectangleCollider(obj.x * 3, obj.y * 3, obj.width * 3, obj.height * 3)
            map:setType('static')
            map:setCollisionClass("Map")
            -- map:setObject(Map)
            table.insert(collider, map)
        end
    end
    local collidorPassable = {}
    if map.layers["mapPassable"] then
        for i, obj in pairs(map.layers["mapPassable"].objects) do
            local mapPass = world:newRectangleCollider(obj.x * 3, obj.y * 3, obj.width * 3, obj.height * 3)
            mapPass:setType('static')
            mapPass:setCollisionClass("MapPassable")
            table.insert(collidorPassable, mapPass)
        end
    end
end
return mapCollider