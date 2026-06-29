-- src/levels/transition.lua
transitions = {}
transitions.colliders = {}
transitions.canUse = nil

local destMap = {
    toBossRoom = "map/bossroom",
    toHome     = "map/tile",
}

function transitions:init(currentMap)
    for _, c in ipairs(self.colliders) do c:destroy() end
    self.colliders = {}
    self.canUse = nil

    for _, layer in ipairs(currentMap.layers) do
        if layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                local dest = destMap[obj.name]
                if dest then
                    local x, y = obj.x * 3, obj.y * 3
                    local w, h = obj.width * 3, obj.height * 3
                    local col = world:newRectangleCollider(x, y, w, h)
                    col:setType('static')
                    col:setCollisionClass('Transition')
                    col.destMap = dest
                    col.w, col.h = w, h
                    table.insert(self.colliders, col)
                end
            end
        end
    end
end

function transitions:update(dt)
    self.canUse = nil
    for _, col in ipairs(self.colliders) do
        local hits = world:queryRectangleArea(
            col:getX() - col.w / 2,
            col:getY() - col.h / 2,
            col.w, col.h,
            {'Player'}
        )
        if #hits > 0 then
            self.canUse = col
            break
        end
    end
end

function transitions:draw()
    if self.canUse then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Press F to move", player.x - 40, player.y - 60, nil, 2, 2)
    end
end