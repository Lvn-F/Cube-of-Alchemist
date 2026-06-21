-- src/ui/Window .lua

local Window  = {}

-- ┌─────────────────────────────────────────────────────────┐
-- │  CONFIGURATION  (edit freely)                           │
-- └─────────────────────────────────────────────────────────┘

local CFG = {
    -- Window spritesheet (192x192, 3x3 grid of 64x64 tiles)
    sheetPath   = "assets/tiles/window.png",
    tileW       = 64,
    tileH       = 64,
    scale       = 2,          -- render scale for the 9-slice
    
    -- Where to draw the window on screen (top-left corner)
    windowX = love.graphics.getWidth()  / 2 - (64 * 3 * 2) / 2,
    windowY = love.graphics.getHeight() / 2 - (64* 3 * 2) / 2,
    
    -- How many columns/rows of item slots
    slotCols    = 6,
    slotRows    = 6,
    
    -- Slot grid offset FROM the window top-left (in screen pixels, after scale)
    slotOffsetX = 24,         -- push slots inward from left edge
    slotOffsetY = 24,         -- push slots inward from top edge
    slotPaddingX = 8,         -- gap between slot columns
    slotPaddingY = 8,         -- gap between slot rows
    
    -- Slot visual size (screen pixels)
    slotW       = 50,
    slotH       = 50,
    
    -- Item icon draw size inside the slot
    iconScale   = 2,
    iconOffsetX = 8,          -- icon offset from slot top-left
    iconOffsetY = 8,
    
    -- Colors
    slotBgColor        = {0.2, 0.2, 0.3, 0.6},
    slotHoverColor     = {0.5, 0.5, 0.8, 0.6},
    slotSelectedColor  = {0.9, 0.8, 0.2, 0.8},
    slotBorderColor    = {1,   1,   1,   0.3},
    countBadgeBg       = {0,   0,   0,   0.7},
    countBadgeFg       = {1,   1,   0.3, 1  },
    tooltipBg          = {0,   0,   0,   0.85},
    tooltipFg          = {1,   1,   1,   1   },
}

-- ┌─────────────────────────────────────────────────────────┐
-- │  INTERNAL STATE                                         │
-- └─────────────────────────────────────────────────────────┘

local sheet     = nil
local quads     = {}          -- [row][col] = Quad  (1-indexed)
local slots     = {}          -- flat list of slot tables
local hoverIdx  = nil
local selectedIdx = nil
local font      = love.graphics.newFont(10)

-- ┌─────────────────────────────────────────────────────────┐
-- │  INIT                                                   │
-- └─────────────────────────────────────────────────────────┘

function Window :load()
    sheet = love.graphics.newImage(CFG.sheetPath)
    sheet:setFilter("nearest", "nearest")
    
    -- Build 3×3 quads from the spritesheet
    local sw = sheet:getWidth()
    local sh = sheet:getHeight()
    for row = 1, 3 do
        quads[row] = {}
        for col = 1, 3 do
            quads[row][col] = love.graphics.newQuad(
                (col-1) * CFG.tileW,
                (row-1) * CFG.tileH,
                CFG.tileW, CFG.tileH,
                sw, sh
            )
        end
    end
    
    -- Build slot grid
    self:buildSlots()
end

-- ┌─────────────────────────────────────────────────────────┐
-- │  SLOT BUILDER  (call again if CFG changes at runtime)   │
-- └─────────────────────────────────────────────────────────┘

function Window :buildSlots()
    slots = {}
    for row = 1, CFG.slotRows do
        for col = 1, CFG.slotCols do
            local sx = CFG.windowX
                      + CFG.slotOffsetX
                      + (col-1) * (CFG.slotW + CFG.slotPaddingX)
            local sy = CFG.windowY
                      + CFG.slotOffsetY
                      + (row-1) * (CFG.slotH + CFG.slotPaddingY)
            table.insert(slots, {
                x    = sx,
                y    = sy,
                w    = CFG.slotW,
                h    = CFG.slotH,
                col  = col,
                row  = row,
                item = nil,   -- { img, name, desc, count }
            })
        end
    end
end

-- ┌─────────────────────────────────────────────────────────┐
-- │  HELPERS                                                │
-- └─────────────────────────────────────────────────────────┘

-- Returns the total screen width/height of the drawn window
function Window :windowSize()
    local w = CFG.tileW * 5 * CFG.scale
    local h = CFG.tileH * 5 * CFG.scale
    return w, h
end

-- Place an item into a specific slot (1-indexed flat index)
function Window :setSlot(index, item)
    if slots[index] then
        slots[index].item = item
    end
end

-- Place by grid coordinates
function Window :setSlotAt(col, row, item)
    local idx = (row-1) * CFG.slotCols + col
    self:setSlot(idx, item)
end

-- Clear a slot
function Window :clearSlot(index)
    self:setSlot(index, nil)
end

-- Get hovered slot index (nil if none)
function Window :getHovered()
    return hoverIdx
end

-- Get selected slot index (nil if none)
function Window :getSelected()
    return selectedIdx
end

-- ┌─────────────────────────────────────────────────────────┐
-- │  UPDATE                                                 │
-- └─────────────────────────────────────────────────────────┘

function Window :update()
    local mx, my = love.mouse.getPosition()
    hoverIdx = nil
    for i, s in ipairs(slots) do
        if mx >= s.x and mx < s.x + s.w
        and my >= s.y and my < s.y + s.h then
            hoverIdx = i
            break
        end
    end
end

-- ┌─────────────────────────────────────────────────────────┐
-- │  MOUSE PRESS                                            │
-- └─────────────────────────────────────────────────────────┘

function Window :mousepressed(x, y, button)
    if button == 1 and hoverIdx then
        if selectedIdx == hoverIdx then
            selectedIdx = nil     -- deselect on second click
        else
            selectedIdx = hoverIdx
        end
    end
end

-- ┌─────────────────────────────────────────────────────────┐
-- │  DRAW                                                   │
-- └─────────────────────────────────────────────────────────┘

function Window :draw()
    cam:attach()
        love.graphics.push()
            love.graphics.scale(3, 3)
            drawBefore()
        love.graphics.pop()

        herbs:draw()
        drawSort.draw(map, 3)
        player:drawSpell()

        love.graphics.push()
            love.graphics.scale(3, 3)
            drawAfter()
        love.graphics.pop()
    cam:detach()
    love.graphics.setColor(1, 1, 1, 1)
    self:_drawWindow()
    self:_drawSlots()
    self:_drawTooltip()
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw the 9-slice window chrome
function Window :_drawWindow()
    local s  = CFG.scale
    local tw = CFG.tileW * s
    local th = CFG.tileH * s
    local wx = CFG.windowX
    local wy = CFG.windowY

    -- Draw all 9 pieces: [row][col]
    -- (1,1)=top-left  (1,2)=top-mid  (1,3)=top-right
    -- (2,1)=mid-left  (2,2)=center   (2,3)=mid-right
    -- (3,1)=bot-left  (3,2)=bot-mid  (3,3)=bot-right

    local positions = {
        {1,1, wx,        wy       },
        {1,2, wx+tw,     wy       },
        {1,3, wx+tw*2,   wy       },
        {2,1, wx,        wy+th    },
        {2,2, wx+tw,     wy+th    },
        {2,3, wx+tw*2,   wy+th    },
        {3,1, wx,        wy+th*2  },
        {3,2, wx+tw,     wy+th*2  },
        {3,3, wx+tw*2,   wy+th*2  },
    }

    love.graphics.setColor(1, 1, 1, 1)
    for _, p in ipairs(positions) do
        love.graphics.draw(sheet, quads[p[1]][p[2]], p[3], p[4], 0, s, s)
    end
end

-- Draw all slots and their contents
function Window :_drawSlots()
    for i, s in ipairs(slots) do
        -- Background fill
        if i == selectedIdx then
            love.graphics.setColor(CFG.slotSelectedColor)
        elseif i == hoverIdx then
            love.graphics.setColor(CFG.slotHoverColor)
        else
            love.graphics.setColor(CFG.slotBgColor)
        end
        love.graphics.rectangle("fill", s.x, s.y, s.w, s.h, 4, 4)

        -- Border
        love.graphics.setColor(CFG.slotBorderColor)
        love.graphics.rectangle("line", s.x, s.y, s.w, s.h, 4, 4)

        -- Item icon
        if s.item and s.item.img then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                s.item.img,
                s.x + CFG.iconOffsetX,
                s.y + CFG.iconOffsetY,
                0,
                CFG.iconScale, CFG.iconScale,
                s.item.img:getWidth()  / 2,
                s.item.img:getHeight() / 2
            )

            -- Count badge
            if s.item.count and s.item.count > 1 then
                local countStr = tostring(s.item.count)
                local bx = s.x + s.w - 14
                local by = s.y + s.h - 14
                love.graphics.setColor(CFG.countBadgeBg)
                love.graphics.rectangle("fill", bx-2, by-1, 14, 13, 3, 3)
                love.graphics.setColor(CFG.countBadgeFg)
                love.graphics.setFont(font)
                love.graphics.print(countStr, bx, by)
            end
        end
    end
end

-- Draw tooltip for hovered slot
function Window :_drawTooltip()
    if not hoverIdx then return end
    local s = slots[hoverIdx]
    if not s.item then return end

    local mx, my = love.mouse.getPosition()
    local tw, th = 160, 50
    local tx = mx + 12
    local ty = my - 10

    love.graphics.setColor(CFG.tooltipBg)
    love.graphics.rectangle("fill", tx, ty, tw, th, 4, 4)
    love.graphics.setColor(CFG.tooltipFg)
    love.graphics.setFont(font)
    love.graphics.printf(
        (s.item.name or "?") .. "\n" .. (s.item.desc or ""),
        tx + 6, ty + 6,
        tw - 12
    )
end

function Window:keypressed(key)
    local GS = require 'lib/hump/gamestate'
    if key == 'z' then
        local playState = require 'src/states/play'
        GS.push(playState)
        return
    end
end

return Window