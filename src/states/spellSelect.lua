-- src/states/spellSelect.lua
--
-- Spell selection overlay (pushed on top of PlayState).
-- Two equipped slots at the top:
--   LEFT slot  (blue)  = main spell   → fired with left-click in gameplay
--   RIGHT slot (red)   = second spell → combined with main on right-click
--
-- Clicking a spell circle in the grid:
--   Left-click  → assign to main slot
--   Right-click → assign to second slot

local SpellSelect = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- SPELL REGISTRY
-- Add new spells here. iconPath can be nil (shows a placeholder symbol).
-- key must match player.mainSpell / player.secondSpell values.
-- ─────────────────────────────────────────────────────────────────────────────
local SPELLS = {
    { key = 1, name = "Shadowball",  symbol = "◆", desc = "Charge and hurl a dark projectile", iconPath = pathImg.skill .. "shadowballIcon.png"},
    { key = 2, name = "Light Shard", symbol = "★", desc = "Release a blinding flash of light", iconPath = pathImg.skill .. "lightshardIcon.png" },
    { key = 3, name = "Wind Charge", symbol = "↑", desc = "Blast forward with a gust of wind",  iconPath = pathImg.skill .. "winchargeIcon.png" },
    { key = 4, name = "Firecharge",  symbol = "🔥", desc = "Charge up and unleash a fiery blast", nil},
}

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYOUT CONSTANTS
-- ─────────────────────────────────────────────────────────────────────────────
local GRID_ICON_R  = 60   -- radius of each spell circle in the picker grid
local GRID_GAP     = 24   -- gap between grid circles
local EQUIP_R      = 52   -- radius of the two equipped-slot circles
local EQUIP_GAP    = 48   -- horizontal gap between the two equipped slots
local PANEL_PAD_X  = 60
local PANEL_PAD_Y  = 70
local GRID_COLS    = 3    -- max columns in the spell picker grid

-- ─────────────────────────────────────────────────────────────────────────────
-- COLOUR PALETTE  (all values 0–1)
-- ─────────────────────────────────────────────────────────────────────────────
local COL = {
    -- panel chrome
    panelBg     = {0.12, 0.12, 0.18, 0.92},
    panelBorder = {0.30, 0.30, 0.45, 1.00},
    divider     = {0.30, 0.30, 0.45, 0.70},
    shadow      = {0.00, 0.00, 0.00, 0.45},

    -- text
    textMain    = {1.00, 1.00, 1.00, 1.00},
    textSub     = {0.70, 0.75, 0.85, 1.00},
    textHint    = {0.60, 0.65, 0.75, 1.00},

    -- grid icon states
    iconBg      = {1.00, 1.00, 1.00, 0.50},
    iconHover   = {0.85, 0.92, 1.00, 0.50},
    borderNorm  = {0.55, 0.55, 0.70, 1.00},
    borderHover = {0.60, 0.85, 1.00, 1.00},
    symbolNorm  = {0.35, 0.35, 0.45, 1.00},
    symbolHover = {0.30, 0.55, 1.00, 1.00},

    -- equipped slot: main (left-click = blue)
    mainBorder  = {0.25, 0.55, 1.00, 1.00},
    mainBg      = {0.40, 0.70, 1.00, 0.50},
    mainSymbol  = {0.25, 0.55, 1.00, 1.00},
    mainName    = {0.50, 0.80, 1.00, 1.00},
    mainGrid    = {0.88, 0.94, 1.00, 0.50},  -- grid bg when assigned to main

    -- equipped slot: second (right-click = red)
    secBorder   = {1.00, 0.30, 0.35, 1.00},
    secBg       = {1.00, 0.55, 0.40, 0.50},
    secSymbol   = {1.00, 0.30, 0.35, 1.00},
    secName     = {1.00, 0.60, 0.55, 1.00},
    secGrid     = {1.00, 0.90, 0.88, 0.50},  -- grid bg when assigned to second

    -- empty slot
    emptyBg     = {0.22, 0.22, 0.32, 1.00},
    emptyBorder = {0.45, 0.45, 0.60, 1.00},

    -- tooltip
    tooltipBg   = {0.10, 0.10, 0.18, 0.90},
    tooltipBdr  = {0.35, 0.45, 0.70, 0.80},
    tooltipText = {0.85, 0.90, 1.00, 1.00},
}

-- ─────────────────────────────────────────────────────────────────────────────
-- MODULE STATE
-- ─────────────────────────────────────────────────────────────────────────────
local icons      = {}    -- { [spellKey] = love Image }
local hoverKey   = nil   -- spell key the mouse is over
local mainKey    = nil   -- mirrors player.mainSpell
local secondKey  = nil   -- mirrors player.secondSpell
local alpha      = 0     -- fade-in progress (0→1)

local layout     = {}    -- built by buildLayout()
local titleFont  = nil
local bodyFont   = nil
local smallFont  = nil

-- Quick lookup: spell key → SPELLS entry
local spellByKey = {}
for _, sp in ipairs(SPELLS) do spellByKey[sp.key] = sp end

-- ─────────────────────────────────────────────────────────────────────────────
-- DRAWING HELPERS
-- ─────────────────────────────────────────────────────────────────────────────

local function setColor(col, alphaOverride)
    love.graphics.setColor(col[1], col[2], col[3], (alphaOverride or 1) * col[4])
end

-- Draws a filled circle then a border ring.
local function drawIconCircle(x, y, r, borderCol, bgCol, scale)
    local s = scale or 1
    -- drop shadow
    setColor(COL.shadow)
    love.graphics.circle("fill", x + 4*s, y + 6*s, r * s)
    -- background fill
    setColor(bgCol)
    love.graphics.circle("fill", x, y, r * s)
    -- border
    love.graphics.setLineWidth(4 * s)
    setColor(borderCol)
    love.graphics.circle("line", x, y, r * s)
    love.graphics.setLineWidth(1)
end

-- Draws a symbol centered inside a circle (used when no icon image exists).
local function drawSymbol(x, y, r, symbol, col, scale, font)
    love.graphics.setFont(font)
    setColor(col)
    love.graphics.printf(symbol, x - r * (scale or 1), y - 16 * (scale or 1), r * 2 * (scale or 1), "center")
end

local function pointInCircle(px, py, cx, cy, r)
    local dx, dy = px - cx, py - cy
    return dx*dx + dy*dy <= r*r
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYOUT BUILDER
-- ─────────────────────────────────────────────────────────────────────────────

local function buildLayout()
    local sw, sh = love.graphics.getDimensions()

    local cols   = math.min(#SPELLS, GRID_COLS)
    local rows   = math.ceil(#SPELLS / cols)
    local cellW  = GRID_ICON_R * 2 + GRID_GAP
    local cellH  = GRID_ICON_R * 2 + GRID_GAP
    local gridW  = cols * cellW - GRID_GAP

    -- Two side-by-side slots: each center is (EQUIP_R + EQUIP_GAP/2) from panel center
    -- Total width = 2 * (EQUIP_R + EQUIP_GAP/2) + EQUIP_R * 2  (left edge to right edge)
    local equipRowW = (EQUIP_R + EQUIP_GAP / 2) * 2 + EQUIP_R * 2

    local panelW = math.max(gridW, equipRowW) + PANEL_PAD_X * 2
    local panelH = PANEL_PAD_Y          -- title area
                 + EQUIP_R * 2 + 50     -- equipped row + label/name space
                 + rows * cellH         -- spell grid
                 + PANEL_PAD_Y

    local panelX = sw / 2 - panelW / 2
    local panelY = sh / 2 - panelH / 2

    layout.panelX, layout.panelY = panelX, panelY
    layout.panelW, layout.panelH = panelW, panelH

    -- ── Equipped slots ──────────────────────────────────────────────────────
    local equipY   = panelY + PANEL_PAD_Y + EQUIP_R
    local centerX  = panelX + panelW / 2
    -- Each slot center is offset from panel center by (radius + half the gap)
    local slotOffset  = EQUIP_R + EQUIP_GAP / 2
    layout.mainSlot   = { x = centerX - slotOffset, y = equipY, r = EQUIP_R }
    layout.secondSlot = { x = centerX + slotOffset, y = equipY, r = EQUIP_R }

    -- ── Spell picker grid ───────────────────────────────────────────────────
    local startX = panelX + panelW / 2 - gridW / 2 + GRID_ICON_R
    local startY = equipY + EQUIP_R + 52 + GRID_ICON_R

    layout.spells = {}
    for i, spell in ipairs(SPELLS) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        layout.spells[spell.key] = {
            key = spell.key,
            x   = startX + col * cellW,
            y   = startY + row * cellH,
            r   = GRID_ICON_R,
        }
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DRAW SUB-ROUTINES
-- ─────────────────────────────────────────────────────────────────────────────

-- Draws one equipped slot (main or second) given its colour set.
local function drawEquippedSlot(slot, spellKey, labelText, borderCol, bgCol, symbolCol, nameCol)
    local a       = alpha
    local textW   = slot.r * 2 + 20   -- text area width centered over the slot
    local textX   = slot.x - textW / 2 -- left edge of that text area

    -- Label above the circle, centered over the slot
    love.graphics.setFont(smallFont)
    setColor(COL.textSub, a)
    love.graphics.printf(labelText, textX, slot.y - slot.r - 20, textW, "center")

    if spellKey then
        local sp = spellByKey[spellKey]
        drawIconCircle(slot.x, slot.y, slot.r, borderCol, bgCol)

        local img = icons[spellKey]
        if img then
            local iw, ih = img:getDimensions()
            local s = (slot.r * 1.4) / math.max(iw, ih)
            setColor(COL.textMain, a)
            love.graphics.draw(img, slot.x - iw*s/2, slot.y - ih*s/2, 0, s, s)
        else
            drawSymbol(slot.x, slot.y, slot.r, sp.symbol, symbolCol, 1, titleFont)
        end

        -- Spell name below the circle, centered over the slot
        love.graphics.setFont(bodyFont)
        setColor(nameCol, a)
        love.graphics.printf(sp.name, textX, slot.y + slot.r + 8, textW, "center")
    else
        drawIconCircle(slot.x, slot.y, slot.r, COL.emptyBorder, COL.emptyBg)
        love.graphics.setFont(bodyFont)
        setColor(COL.textSub, a)
        love.graphics.printf("Empty", textX, slot.y + slot.r + 8, textW, "center")
    end
end

local function drawEquippedRow()
    -- Equiped and label
    drawEquippedSlot(
        layout.mainSlot, mainKey,
        "Main",
        COL.mainBorder, COL.mainBg, COL.mainSymbol, COL.mainName
    )
    drawEquippedSlot(
        layout.secondSlot, secondKey,
        "Aspect",
        COL.secBorder, COL.secBg, COL.secSymbol, COL.secName
    )
end

local function drawSpellGrid()
    local a = alpha
    for _, sp in ipairs(SPELLS) do
        local p = layout.spells[sp.key]
        if not p then goto continue end

        local isMain   = (sp.key == mainKey)
        local isSecond = (sp.key == secondKey)
        local isHover  = (sp.key == hoverKey)
        local scale    = isHover and 1.12 or 1.0

        -- Choose border and background based on assignment state
        local borderCol, bgCol, symbolCol
        if isMain then
            borderCol = COL.mainBorder
            bgCol     = COL.mainGrid
            symbolCol = COL.mainSymbol
        elseif isSecond then
            borderCol = COL.secBorder
            bgCol     = COL.secGrid
            symbolCol = COL.secSymbol
        elseif isHover then
            borderCol = COL.borderHover
            bgCol     = COL.iconHover
            symbolCol = COL.symbolHover
        else
            borderCol = COL.borderNorm
            bgCol     = COL.iconBg
            symbolCol = COL.symbolNorm
        end

        drawIconCircle(p.x, p.y, p.r, borderCol, bgCol, scale)

        local img = icons[sp.key]
        if img then
            local iw, ih = img:getDimensions()
            local s = (p.r * 1.3 * scale) / math.max(iw, ih)
            setColor(COL.textMain, a)
            love.graphics.draw(img, p.x - iw*s/2, p.y - ih*s/2, 0, s, s)
        else
            drawSymbol(p.x, p.y, p.r, sp.symbol, symbolCol, scale, titleFont)
        end

        -- Spell name below circle
        love.graphics.setFont(smallFont)
        local nameCol = isMain   and COL.mainName
                     or isSecond and COL.secName
                     or COL.textSub
        setColor(nameCol, a)
        love.graphics.printf(sp.name, p.x - 70, p.y + p.r * scale + 6, 140, "center")

        ::continue::
    end
end

local function drawTooltip()
    if not hoverKey then return end
    local sp = spellByKey[hoverKey]
    local p  = layout.spells[hoverKey]
    if not sp or not p then return end

    local a   = alpha
    local tw  = 220
    local tx  = p.x - tw / 2
    local ty  = p.y + p.r * 1.15 + 28
    local px  = layout.panelX
    local pw  = layout.panelW

    tx = math.max(px + 10, math.min(px + pw - tw - 10, tx))

    setColor(COL.tooltipBg, a)
    love.graphics.rectangle("fill", tx - 8, ty - 6, tw + 16, 42, 8, 8)
    setColor(COL.tooltipBdr, a)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", tx - 8, ty - 6, tw + 16, 42, 8, 8)

    love.graphics.setFont(smallFont)
    setColor(COL.tooltipText, a)
    love.graphics.printf(sp.desc, tx, ty + 4, tw, "center")
end


function SpellSelect:enter()
    -- Sync from player globals
    mainKey   = player and player.mainSpell   or nil
    secondKey = player and player.secondSpell or nil
    hoverKey  = nil
    alpha     = 0

    titleFont = love.graphics.newFont(20)
    bodyFont  = love.graphics.newFont(14)
    smallFont = love.graphics.newFont(11)

    -- Load icon images
    for _, sp in ipairs(SPELLS) do
        if sp.iconPath and not icons[sp.key] then
            local ok, img = pcall(love.graphics.newImage, sp.iconPath)
            if ok then icons[sp.key] = img end
        end
    end

    buildLayout()
end

function SpellSelect:update(dt)
    alpha = math.min(alpha + dt * 6, 1)

    -- Hover
    local mx, my = love.mouse.getPosition()
    hoverKey = nil
    for key, p in pairs(layout.spells or {}) do
        if pointInCircle(mx, my, p.x, p.y, p.r * 1.1) then
            hoverKey = key
            break
        end
    end
end

function SpellSelect:draw()
    local sw, sh = love.graphics.getDimensions()
    local a      = alpha
    local px, py = layout.panelX, layout.panelY
    local pw, ph = layout.panelW, layout.panelH

    cam:attach()
        -- Draw heirarchy
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
    
    -- Dim the gameplay behind the panel
    love.graphics.setColor(0, 0, 0, 0.65 * a)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Panel background
    setColor(COL.panelBg, a)
    love.graphics.rectangle("fill", px, py, pw, ph, 18, 18)
    setColor(COL.panelBorder, a)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", px, py, pw, ph, 18, 18)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    setColor(COL.textMain, a)
    love.graphics.printf("Select Spell", px, py + 20, pw, "center")

    love.graphics.setFont(smallFont)
    setColor(COL.textHint, a)
    -- love.graphics.printf("Left-click = main  •  Right-click = second  •  Tab to close", px, py + 46, pw, "center")

    -- Equipped row
    drawEquippedRow()

    -- Divider between equipped row and picker grid
    local divY = layout.mainSlot.y + EQUIP_R + 32
    setColor(COL.divider, a)
    love.graphics.line(px + 30, divY, px + pw - 24, divY)

    -- Spell picker grid
    drawSpellGrid()

    -- Tooltip on hover
    drawTooltip()

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end


-- # Input
function SpellSelect:keypressed(key)
    if key == 'tab' or key == 'escape' then
        local GS = require 'lib/hump/gamestate'
        GS.pop()
    end
end

function SpellSelect:mousepressed(x, y, button)
    -- Prevent both key pressed
    if button ~= 1 and button ~= 2 then return end

    for key, p in pairs(layout.spells or {}) do
        if pointInCircle(x, y, p.x, p.y, p.r * 1.1) then
            if button == 1 then
                -- Left-click → assign as main spell
                mainKey           = key
                player.mainSpell  = key
            else
                -- Right-click → assign as second spell (for combining)
                secondKey          = key
                player.secondSpell = key
            end
            return
        end
    end
end

function SpellSelect:resize(w, h)
    buildLayout()
end

return SpellSelect