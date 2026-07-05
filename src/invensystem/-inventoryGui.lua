-- local inventoryGui = {}
-- local  w, h = love.graphics.getDimensions()

-- local guiMap

-- local inv
-- local invSlots = {}
-- local hotbarSlots = {}

-- local mx, my = love.mouse.getPosition()
-- local mouseOn = {is = false, index = nil, group = nil}
-- local selected = {is = false, index = nil, group = nil}
-- local infoBox = {w = 200, h = 100}
-- local isOpen = false

-- function inventoryGui:init(map, inventory)
--     guiMap = map
--     inv = inventory

--     local invenLayer = guiMap.layers["invebox"]
--     local hotbarLayer = guiMap.layers["hotbar"]

--     invSlots = {}
--     if invenLayer then
--         local objs = {}
--         for _, obj in ipairs(invenLayer.objects) do
--             table.insert(objs, obj)
--         end
--         table.sort(objs, function(a, b)
--             if a.y == b.y then
--                 return a.x < b.x
--             end
--             return a.y < b.y
--         end)
--         for i, obj in ipairs(objs) do
--             table.insert(invSlots, {
--                 x = obj.x * 3,
--                 y = obj.y * 3,
--                 w = obj.width * 3,
--                 h = obj.height *3
--             })
--         end
--     end
--     hotbarSlots = {}
--     if invenLayer then
--         local objs = {}
--         for _, obj in ipairs(invenLayer.objects) do
--             table.insert(objs, obj)
--         end
--         table.sort(objs, function(a, b)
--             if a.y == b.y then
--                 return a.x < b.x
--             end
--             return a.y < b.y
--         end)
--         for i, obj in ipairs(objs) do
--             table.insert(hotbarSlots, {
--                 x = obj.x * 3,
--                 y = obj.y * 3,
--                 w = obj.width * 3,
--                 h = obj.height *3
--             })
--         end
--     end
-- end

-- function inventoryGui:toggle()
--     isOpen = not isOpen
-- end

-- local function mouseInRect(rect)
--     return mx > rec.x and mx <= rect.w + rect.w
--     and my > rec.y and my <= rect.h + rect.h
-- end

-- function inventoryGui:update()
--     mx, my = love.mouse.getPosition()
--     mouseOn.is = false
--     if isOpen then
--         for i, slot in ipairs(invSlots) do
--             if mouseInRect(slot) then
--                 mouseOn.is = true
--                 mouseOn.index = i
--                 mouseOn.group = "inv"
--             end
--         end
--     end

--     for i, slot in ipairs(hotbarSlots) do
--         if mouseInRect(slot) then
--             mouseOn.is = true
--             mouseOn.is = i
--             mouseOn.is = "hotbar"
--         end
--     end
-- end

-- local function getItem(group, index)
--     if group == "inv" then
--         local invW = #inv.arr[1]
--         local y = math.ceil(index / invW)
--         local x = ((index - 1) % invW) + 1
--         return inv.arr[y][x]
--     elseif group == "hotbar" then
--         return inv.hotbar[index]
--     end
-- end

-- local function setItem(group, index, item)
--     if group == "inv" then
--         local invW = #inv.arr[1]
--         local y = math.ceil(index / invW)
--         local x = ((index - 1) % invW) + 1
--         inv.arr[y][x] = item
--     elseif group == "hotbar" then
--         inv.hotbar[index] = item
--     end
-- end

-- function inventoryGui:mousepressed(x, y, b)
--     if b == 1 then
--         if mouseOn.is then
--             if not selected.is then
--                 local item = getitem(mouseOn.group, mouseOn.index)
--                 if item ~= 0 and item ~= nil then
--                     selected.is = true
--                     selected.index = mouseOn.index
--                     selected.group = mouseOn.group
--                 end
--             else
--                 local itemA = getItem(selected.group, selected.index)
--                 local itemB = getItem(mouseOn.group, mouseOn.index)
--                 setItem(mouseOn.group, mouseOn.index, itemA)
--                 setItem(selected.group, selected.index, itemB)
--             end
--         else
--             selected.is =false
--         end
--     end
-- end

-- function inventoryGui:draw()
--     love.graphics.push()
--         love.graphics.scale(3, 3)
--         if isOpen then
--             guiMap:drawLayer(guiMap.layers["invenbox"])
--         else
--             guiMap:drawLayer(guiMap.layers["hotbar"])
--         end
--         guiMap:drawLayer(guiMap.layers["hotbar"])
--     love.graphics.pop()

--     if isOpen then
--         for i, slot in ipairs(invSlots) do
--             local item = getItem("inv", i)
--             if item and item ~= 0 then
--                 if selected.is and selected.group == "inv" and selected.index == i then
--                     -- love.graphics.setColor(1, 1, 1, 0.4)
--                     love.graphics.draw(item.img, slot.x, slot.y)
--                 else
--                     -- love.graphics.setColor(1, 1, 1, 1)
--                     love.graphics.draw(item.img, slot.x, slot.y)
--                 end
--             end
--         end
--     end

--     for i, slot in ipairs(hotbarSlots) do
--         local item = getItem("hotbar", i)
--         if item and item ~= 0 then
--             if selected.is and selected.group == "hotbar" and selected.index == i then
--                 -- love.graphics.setColor(1, 1, 1, 0.4)
--                 love.graphics.draw(item.img, slot.x, slot.y)
--             else
--                 -- love.graphics.setColor(1, 1, 1, 1)
--                 love.graphics.draw(item.img, slot.x, slot.y)
--             end
--         end
--     end

--     if selected.is then
--         local item = getItem(selected.group, selected.index)
--         if item and item ~= 0 then
--             -- love.graphics.setColor(1, 1, 1, 1)
--             love.graphics.draw(item.img, mx, my)
--         end
--     end

--     if mouseOn.is then
--         local item = getItem(mouseOn.group, mouseOn.index)
--         if item and item ~= 0 then
--             -- love.graphics.setColor(1, 1, 1, 1)
--             love.graphics.rectangle("fill", mx + 20, my, infoBox.w, infoBox.h)
--             -- love.graphics.setColor(0, 0, 0, 1)
--             love.graphics.printf(item.name .. "\n" .. item.desc, mx + 25, my + 5, infoBox.w - 10)
--         end
--     end

--     -- love.graphics.setColor(1, 1, 1, 1)
--     -- love.graphics.line(mx, my+10, mx, my, mx+10, my)
-- end

-- return inventoryGui

