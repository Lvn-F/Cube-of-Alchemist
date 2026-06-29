mapColliders = mapColliders or {}
local function mapCollider()
    for _, c in ipairs(mapColliders) do c:destroy() end
    mapColliders = {}

    if map.layers["mapHitbox"] then
        for i, obj in pairs(map.layers["mapHitbox"].objects) do
            local m = world:newRectangleCollider(obj.x * 3, obj.y * 3, obj.width * 3, obj.height * 3)
            m:setType('static')
            m:setCollisionClass("Map")
            table.insert(mapColliders, m)
        end
    end

    if map.layers["mapPassable"] then
        for i, obj in pairs(map.layers["mapPassable"].objects) do
            local p = world:newRectangleCollider(obj.x * 3, obj.y * 3, obj.width * 3, obj.height * 3)
            p:setType('static')
            p:setCollisionClass("MapPassable")
            table.insert(mapColliders, p)
        end
    end
end
return mapCollider