local gui = {}

local w, h = love.graphics.getDimensions()
local item = require 'src/invensystem/item'

local inv, invW, invH
-- local invW
-- local invH
local itemDrawW
local itemDrawH
local offsetX = 0
local offsetY = 0
function gui:setInventory(inventory, iconW, iconH)
    inv = inventory
    invW = #inv.arr[1]
    invH = #inv.arr
    itemDrawW = iconW
    itemDrawH = iconH

    offsetX = (w - invW * itemDrawW) / 2
    offsetY = (h - invH * itemDrawH) / 2
end

-- local mx,my = love.mouse.getPosition()
local mouseOn = {is = false, x = 1, y = 1}
local selected = {is = false, x=1, y = 1}
local infoBox = {w = 500, h = 60}

function gui:update()
    mx, my = love.mouse.getPosition()
    mouseOn.is = false
    for y=1,invH do
        for x=1,invW do
            local drawX = offsetX - 115 + (x-1) * itemDrawW * 1.93
            local drawY = offsetY - 45 + (y-1) * itemDrawH * 1.93
            local mouseIsOn = mx > drawX and mx <= drawX + itemDrawW and my > drawY and my <= drawY+itemDrawH
            if mouseIsOn then 
                mouseOn.is = true
                mouseOn.x, mouseOn.y = x, y
            end
        end
    end
end

function gui:mousepressed(x, y, b)
    if b == 1 then
        if mouseOn.is then
            if not selected.is then
                if inv.arr[mouseOn.y][mouseOn.x] ~= 0 then
                    selected.is = true
                    selected.x = mouseOn.x
                    selected.y = mouseOn.y
                end
            else
                inv:replace(selected.x, selected.y, mouseOn.x, mouseOn.y)
                selected.is = false
            end
        end
    end
end

love.graphics.setLineWidth(2)
love.graphics.setNewFont(15)
function gui:draw()
    for y = 1,invH do
        for x = 1,invW do
            local drawX = offsetX - 115 + (x-1) * itemDrawW * 1.93
            local drawY = offsetY - 45 + (y-1) * itemDrawH * 1.93
            local mouseOnThis = mouseOn.is and mouseOn.x == x and mouseOn.y == y
            if mouseOnThis then
                love.graphics.setColor(200, 200, 200)
            else
                love.graphics.setColor(170, 170, 170)
            end
            -- love.graphics.rectangle("fill",drawX,drawY,itemDrawW,itemDrawH)
            -- love.graphics.setColor(0,0,0)
            -- love.graphics.rectangle("line",drawX,drawY,itemDrawW,itemDrawH)
            -- love.graphics.setColor(255,255,255)
        end
    end
    for y=1,invH do
        for x=1,invW do
            local drawX = offsetX - 115 + (x-1) * itemDrawW * 1.93
            local drawY = offsetY - 45 + (y-1) * itemDrawH * 1.93
            local mouseOnThis = mouseOn.is and mouseOn.x == x and mouseOn.y == y
            local item = inv.arr[y][x]
            if selected.is and selected.x == x and selected.y == y then
                love.graphics.setColor(255, 255, 255, 100)
                love.graphics.draw(item.img, drawX+10, drawY+10, nil, 2, 2, 8, 8)
                -- love.graphics.setColor(0,0,0,30)
                -- love.graphics.draw(item.img,mx+10,my+10)
            elseif item ~= 0 then
                love.graphics.setColor(255,255,255)
                love.graphics.draw(item.img, drawX+10, drawY+10, nil, 2, 2, 8, 8)
            end
            if mouseOn.is and item ~= 0 and mouseOn.x == x and mouseOn.y == y then
                love.graphics.setColor(255, 255, 255)
                love.graphics.rectangle("fill", offsetX + itemDrawH - 150, offsetY + 230, infoBox.w, infoBox.h)
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(item.name .. "\n" .. item.desc, offsetX + itemDrawW * invW - 380, offsetY + 240, infoBox.w - 5)
            end
        end
    end
    if selected.is then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(inv.arr[selected.y][selected.x].img, mx, my, nil, 2, 2, 16, 16)
    end
    love.graphics.setColor(255, 255, 255)
    -- love.graphics.line(mx,my+10,mx,my,mx+10,my)
end

return gui