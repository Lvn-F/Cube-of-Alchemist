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
end
return mapCollider