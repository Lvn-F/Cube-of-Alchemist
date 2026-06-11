local gui = {}

local w, h = love.graphics.getDimensions()
local item = require 'src/invensystem/item'

local inv, invW, invH
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

local mouseOn  = { is = false, x = 1, y = 1 }
local selected = { is = false, x = 1, y = 1 }
local infoBox  = { w = 500, h = 60 }
local gridOffsetX = 73
local gridOffsetY = 10
local gridSizeXY = 1.595
function gui:update()
    mx, my = love.mouse.getPosition()
    mouseOn.is = false
    for y = 1, invH do
        for x = 1, invW do
            local drawX = offsetX - gridOffsetX + (x - 1) * itemDrawW * gridSizeXY
            local drawY = offsetY - gridOffsetY  + (y - 1) * itemDrawH * gridSizeXY
            if mx > drawX and mx <= drawX + itemDrawW
            and my > drawY and my <= drawY + itemDrawH then
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
                    selected.x  = mouseOn.x
                    selected.y  = mouseOn.y
                end
            else
                inv:replace(selected.x, selected.y, mouseOn.x, mouseOn.y)
                selected.is = false
            end
        else
            selected.is = false
        end
    end
end

local font = love.graphics.newFont(11)

function gui:draw()
    for y = 1, invH do
        for x = 1, invW do
            local drawX = offsetX - gridOffsetX + (x - 1) * itemDrawW * gridSizeXY
            local drawY = offsetY - gridOffsetY  + (y - 1) * itemDrawH * gridSizeXY
            local mouseOnThis = mouseOn.is and mouseOn.x == x and mouseOn.y == y
            if mouseOnThis then
                love.graphics.setColor(0.8, 0.8, 0.8, 0.3)
            else
                love.graphics.setColor(0.6, 0.6, 0.6, 0.2)
            end
            love.graphics.rectangle("fill", drawX, drawY, itemDrawW, itemDrawH)
        end
    end

    for y = 1, invH do
        for x = 1, invW do
            local drawX = offsetX - gridOffsetX + (x - 1) * itemDrawW * gridSizeXY
            local drawY = offsetY - gridOffsetY  + (y - 1) * itemDrawH * gridSizeXY
            local slot  = inv.arr[y][x]

            if slot ~= 0 then
                local isSelected = selected.is and selected.x == x and selected.y == y

                if isSelected then
                    love.graphics.setColor(1, 1, 1, 0.4)
                else
                    love.graphics.setColor(1, 1, 1, 1)
                end
                love.graphics.draw(slot.item.img, drawX + 10, drawY + 10, nil, 2, 2, 8, 8)

                if slot.count > 0 then
                    local countStr = tostring(slot.count)
                    local badgeX = drawX + itemDrawW - 14
                    local badgeY = drawY + itemDrawH - 16
                    love.graphics.setColor(0, 0, 0, 0.7)
                    love.graphics.rectangle("fill", badgeX - 2, badgeY - 1, 14, 14, 3, 3)
                    love.graphics.setColor(1, 1, 0.3, 1)
                    love.graphics.setFont(font)
                    love.graphics.print(countStr, badgeX, badgeY)
                end

                local mouseOnThis = mouseOn.is and mouseOn.x == x and mouseOn.y == y
                if mouseOnThis then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.rectangle("fill",
                        offsetX + itemDrawH - 150,
                        offsetY + 230,
                        infoBox.w, infoBox.h)
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.printf(
                        slot.item.name .. "  x" .. slot.count .. "\n" .. slot.item.desc,
                        offsetX + itemDrawW * invW - 380,
                        offsetY + 240,
                        infoBox.w - 5)
                end
            end
        end
    end

    if selected.is then
        local slot = inv.arr[selected.y][selected.x]
        if slot ~= 0 then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(slot.item.img, mx, my, nil, 2, 2, 16, 16)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return gui