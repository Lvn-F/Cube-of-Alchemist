-- src/states/crafting.lua

local Crafting = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYOUT CONSTANTS
-- ─────────────────────────────────────────────────────────────────────────────
local SLOT_SIZE      = 50
local SLOT_GAP       = 6
local WINDOW_PAD     = 20
local WINDOW_GAP     = 48   -- gap between the inventory window and crafting window
local DESC_HEIGHT    = 90
local TITLE_HEIGHT   = 36

local CRAFT_COLS     = 2
local CRAFT_ROWS     = 2

local CRAFT_BTN_W    = 140
local CRAFT_BTN_H    = 36

-- ─────────────────────────────────────────────────────────────────────────────
-- COLOUR PALETTE
-- ─────────────────────────────────────────────────────────────────────────────
local COL = {
    bgDim         = {0, 0, 0, 0.6},

    -- shared window chrome
    windowBg      = {0.12, 0.12, 0.18, 0.95},
    windowBorder  = {0.30, 0.30, 0.45, 1.0},
    titleText     = {1, 1, 1, 1},

    -- inventory slots
    slotBg        = {0.6, 0.6, 0.6, 0.2},
    slotHover     = {0.8, 0.8, 0.8, 0.3},
    slotSelected  = {0.9, 0.8, 0.2, 0.35},
    slotBorder    = {1, 1, 1, 0.25},

    -- crafting slots
    craftSlotBg   = {0.4, 0.5, 0.65, 0.18},
    craftBorder   = {0.5, 0.65, 0.85, 0.4},

    -- result preview
    resultBg          = {0.25, 0.55, 0.35, 0.25},
    resultBorder       = {0.4, 0.8, 0.5, 0.7},
    resultBgEmpty      = {0.3, 0.3, 0.3, 0.15},
    resultBorderEmpty  = {0.4, 0.4, 0.4, 0.4},

    -- craft button
    btnBg            = {0.25, 0.45, 0.65, 1},
    btnBgHover       = {0.32, 0.55, 0.78, 1},
    btnBgDisabled    = {0.25, 0.25, 0.3, 1},
    btnBorder        = {0.5, 0.7, 0.9, 1},
    btnText          = {1, 1, 1, 1},
    btnTextDisabled  = {0.6, 0.6, 0.65, 1},

    -- text / misc
    text          = {1, 1, 1, 1},
    textSub       = {0.75, 0.78, 0.85, 1},
    descBg        = {0.08, 0.08, 0.13, 0.9},
    descBorder    = {0.3, 0.3, 0.45, 0.8},
    badgeBg       = {0, 0, 0, 0.7},
    badgeFg       = {1, 1, 0.3, 1},
}

-- ─────────────────────────────────────────────────────────────────────────────
-- RECIPES
-- Each recipe lists required ingredients (by item name) and their counts,
-- plus the resulting item. Order of ingredients in the grid doesn't matter.
-- Set result.imgPath to a sprite path; it's loaded into result.imgObj lazily.
-- ─────────────────────────────────────────────────────────────────────────────
local RECIPES = require 'src/util/recipes'
local item    = require 'src/invensystem/item'

-- ─────────────────────────────────────────────────────────────────────────────
-- MODULE STATE
-- ─────────────────────────────────────────────────────────────────────────────
local layout        = {}    -- computed every resize/enter
local hoverSlot      = nil  -- { kind = "inv"/"craft", x, y }
local selectedSlot   = nil  -- the slot currently "picked up"
local hoverCraftBtn  = false
local font           = nil
local smallFont      = nil

-- craftGrid[row][col] = { item = ..., count = ... } or 0
local craftGrid = {}

-- Cached result of matching the current craftGrid against RECIPES.
-- nil if no recipe matches.
local matchedRecipe = nil

local function resetCraftGrid()
    craftGrid = {}
    for r = 1, CRAFT_ROWS do
        craftGrid[r] = {}
        for c = 1, CRAFT_COLS do
            craftGrid[r][c] = 0
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- HELPERS
-- ─────────────────────────────────────────────────────────────────────────────

local function setColor(col, a)
    love.graphics.setColor(col[1], col[2], col[3], (a or 1) * col[4])
end

local function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px < rx + rw and py >= ry and py < ry + rh
end

local function getInvSlot(x, y)
    return inv.arr[y][x]
end

local function getCraftSlot(x, y)
    return craftGrid[y][x]
end

-- Flattens the craft grid into { [itemName] = totalCount }
local function tallyCraftGrid()
    local tally = {}
    for r = 1, CRAFT_ROWS do
        for c = 1, CRAFT_COLS do
            local slot = craftGrid[r][c]
            if slot ~= 0 then
                tally[slot.item.name] = (tally[slot.item.name] or 0) + slot.count
            end
        end
    end
    return tally
end

-- Lazily loads the result image for a recipe (once per recipe).
local function ensureResultImage(recipe)
    local result = recipe.result
    if result.imgObj or not result.imgPath then return end
    local ok, img = pcall(love.graphics.newImage, result.imgPath)
    if ok then result.imgObj = img end
end

-- Checks the craft grid against RECIPES. Returns the matching recipe or nil.
local function findMatchingRecipe()
    local tally = tallyCraftGrid()
    if next(tally) == nil then return nil end -- empty grid, nothing to match

    for _, recipe in ipairs(RECIPES) do
        local matches = true
        local requiredNames = {}

        for _, ing in ipairs(recipe.inputs) do
            requiredNames[ing.name] = true
            if (tally[ing.name] or 0) < ing.count then
                matches = false
                break
            end
        end

        -- Make sure there's nothing extra in the grid beyond what's required
        if matches then
            for name, _ in pairs(tally) do
                if not requiredNames[name] then
                    matches = false
                    break
                end
            end
        end

        if matches then
            ensureResultImage(recipe)
            return recipe
        end
    end

    return nil
end

-- Re-checks the recipe match; call after any craftGrid change.
local function refreshRecipeMatch()
    matchedRecipe = findMatchingRecipe()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYOUT BUILDER
-- ─────────────────────────────────────────────────────────────────────────────

local function buildLayout()
    local sw, sh = love.graphics.getDimensions()

    -- ── Inventory window sizing ──────────────────────────────────────────────
    local invCols = #inv.arr[1]
    local invRows = #inv.arr

    local invGridW = invCols * (SLOT_SIZE + SLOT_GAP) - SLOT_GAP
    local invGridH = invRows * (SLOT_SIZE + SLOT_GAP) - SLOT_GAP

    local invWindowW = invGridW + WINDOW_PAD * 2
    local invWindowH = TITLE_HEIGHT + invGridH + 12 + DESC_HEIGHT + WINDOW_PAD * 2

    -- ── Crafting window sizing ───────────────────────────────────────────────
    local craftGridW = CRAFT_COLS * (SLOT_SIZE + SLOT_GAP) - SLOT_GAP
    local craftGridH = CRAFT_ROWS * (SLOT_SIZE + SLOT_GAP) - SLOT_GAP

    -- result preview sits to the right of the craft grid, same row height
    local resultSize = SLOT_SIZE + 10
    local craftRowW  = craftGridW + 40 + resultSize

    local craftWindowW = craftRowW + WINDOW_PAD * 2
    local craftWindowH = TITLE_HEIGHT + craftGridH + 20 + CRAFT_BTN_H + WINDOW_PAD * 2

    -- ── Position both windows side by side, centered as a pair ──────────────
    local totalW = invWindowW + WINDOW_GAP + craftWindowW
    local pairX  = sw / 2 - totalW / 2
    local pairY  = sh / 2 - math.max(invWindowH, craftWindowH) / 2

    layout.inv = {
        x = pairX, y = pairY, w = invWindowW, h = invWindowH,
        cols = invCols, rows = invRows,
        gridX = pairX + WINDOW_PAD,
        gridY = pairY + WINDOW_PAD + TITLE_HEIGHT,
    }
    layout.inv.descX = layout.inv.gridX
    layout.inv.descY = layout.inv.gridY + invGridH + 12
    layout.inv.descW = invGridW
    layout.inv.descH = DESC_HEIGHT

    local craftX = pairX + invWindowW + WINDOW_GAP
    layout.craft = {
        x = craftX, y = pairY + 48, w = craftWindowW, h = craftWindowH,
        gridX = craftX + WINDOW_PAD,
        gridY = pairY + 48 + WINDOW_PAD + TITLE_HEIGHT,
    }

    -- Result preview slot, right of the craft grid, vertically centered on it
    layout.craft.resultX = layout.craft.gridX + craftGridW + 40
    layout.craft.resultY = layout.craft.gridY + (craftGridH - resultSize) / 2
    layout.craft.resultSize = resultSize

    -- Craft button, centered under the craft grid row
    layout.craft.btnX = layout.craft.gridX + (craftRowW - CRAFT_BTN_W) / 2
    layout.craft.btnY = layout.craft.gridY + craftGridH + 20
    layout.craft.btnW = CRAFT_BTN_W
    layout.craft.btnH = CRAFT_BTN_H
end

local function invSlotRect(x, y)
    return layout.inv.gridX + (x - 1) * (SLOT_SIZE + SLOT_GAP),
           layout.inv.gridY + (y - 1) * (SLOT_SIZE + SLOT_GAP),
           SLOT_SIZE, SLOT_SIZE
end

local function craftSlotRect(x, y)
    return layout.craft.gridX + (x - 1) * (SLOT_SIZE + SLOT_GAP),
           layout.craft.gridY + (y - 1) * (SLOT_SIZE + SLOT_GAP),
           SLOT_SIZE, SLOT_SIZE
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DRAW HELPERS
-- ─────────────────────────────────────────────────────────────────────────────

local function drawWindowChrome(win, title)
    setColor(COL.windowBg)
    love.graphics.rectangle("fill", win.x, win.y, win.w, win.h, 14, 14)
    setColor(COL.windowBorder)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", win.x, win.y, win.w, win.h, 14, 14)
    love.graphics.setLineWidth(1)

    love.graphics.setFont(font)
    setColor(COL.titleText)
    love.graphics.printf(title, win.x, win.y + 10, win.w, "center")
end

local function drawSlotBg(rx, ry, rw, rh, isHover, isSelected, baseCol, borderCol)
    if isSelected then
        setColor(COL.slotSelected)
    elseif isHover then
        setColor(COL.slotHover)
    else
        setColor(baseCol)
    end
    love.graphics.rectangle("fill", rx, ry, rw, rh, 4, 4)

    setColor(borderCol)
    love.graphics.rectangle("line", rx, ry, rw, rh, 4, 4)
end

local function drawSlotContents(rx, ry, rw, rh, slotData)
    if slotData == 0 or slotData == nil then return end

    setColor(COL.text)
    love.graphics.draw(
        slotData.item.img,
        rx + rw / 2, ry + rh / 2,
        0, 1.5, 1.5,
        16, 16
    )

    if slotData.count and slotData.count > 1 then
        local countStr = tostring(slotData.count)
        local bx = rx + rw - 16
        local by = ry + rh - 16
        setColor(COL.badgeBg)
        love.graphics.rectangle("fill", bx - 2, by - 1, 16, 14, 3, 3)
        setColor(COL.badgeFg)
        love.graphics.setFont(smallFont)
        love.graphics.print(countStr, bx, by)
    end
end

local function drawDescriptionBox()
    local d = layout.inv
    local x, y, w, h = d.descX, d.descY, d.descW, d.descH

    setColor(COL.descBg)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    setColor(COL.descBorder)
    love.graphics.rectangle("line", x, y, w, h, 6, 6)

    local slotData = nil
    local activeSlot = hoverSlot or selectedSlot
    if activeSlot then
        slotData = activeSlot.kind == "inv"
            and getInvSlot(activeSlot.x, activeSlot.y)
            or  getCraftSlot(activeSlot.x, activeSlot.y)
    end

    love.graphics.setFont(font)
    if slotData and slotData ~= 0 then
        setColor(COL.text)
        love.graphics.printf(slotData.item.name, x + 10, y + 8, w - 20, "left")

        love.graphics.setFont(smallFont)
        setColor(COL.textSub)
        love.graphics.printf(slotData.item.desc or "", x + 10, y + 30, w - 20, "left")
    else
        setColor(COL.textSub)
        love.graphics.printf("Hover an item to see its description.", x + 10, y + 8, w - 20, "left")
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DRAW SECTIONS
-- ─────────────────────────────────────────────────────────────────────────────

local function drawInventoryWindow()
    drawWindowChrome(layout.inv, "Inventory")

    for y = 1, layout.inv.rows do
        for x = 1, layout.inv.cols do
            local rx, ry, rw, rh = invSlotRect(x, y)
            local isHover    = hoverSlot and hoverSlot.kind == "inv" and hoverSlot.x == x and hoverSlot.y == y
            local isSelected = selectedSlot and selectedSlot.kind == "inv" and selectedSlot.x == x and selectedSlot.y == y

            drawSlotBg(rx, ry, rw, rh, isHover, isSelected, COL.slotBg, COL.slotBorder)
            drawSlotContents(rx, ry, rw, rh, getInvSlot(x, y))
        end
    end

    drawDescriptionBox()
end

local function drawCraftingGrid()
    for y = 1, CRAFT_ROWS do
        for x = 1, CRAFT_COLS do
            local rx, ry, rw, rh = craftSlotRect(x, y)
            local isHover    = hoverSlot and hoverSlot.kind == "craft" and hoverSlot.x == x and hoverSlot.y == y
            local isSelected = selectedSlot and selectedSlot.kind == "craft" and selectedSlot.x == x and selectedSlot.y == y

            drawSlotBg(rx, ry, rw, rh, isHover, isSelected, COL.craftSlotBg, COL.craftBorder)
            drawSlotContents(rx, ry, rw, rh, getCraftSlot(x, y))
        end
    end
end

local function drawResultPreview()
    local c = layout.craft
    local rx, ry, rs = c.resultX, c.resultY, c.resultSize

    -- arrow hint between grid and result
    love.graphics.setFont(font)
    setColor(COL.textSub)
    love.graphics.printf("→", rx - 30, ry + rs / 2 - 10, 24, "center")

    if matchedRecipe then
        setColor(COL.resultBg)
        love.graphics.rectangle("fill", rx, ry, rs, rs, 6, 6)
        setColor(COL.resultBorder)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", rx, ry, rs, rs, 6, 6)
        love.graphics.setLineWidth(1)

        local result = matchedRecipe.result
        if result.imgObj then
            setColor(COL.text)
            love.graphics.draw(result.imgObj, rx + rs / 2, ry + rs / 2, 0, 1.5, 1.5, 16, 16)
        end

        if result.count and result.count > 1 then
            love.graphics.setFont(smallFont)
            setColor(COL.badgeFg)
            love.graphics.printf("x" .. result.count, rx, ry + rs - 16, rs, "center")
        end
    else
        setColor(COL.resultBgEmpty)
        love.graphics.rectangle("fill", rx, ry, rs, rs, 6, 6)
        setColor(COL.resultBorderEmpty)
        love.graphics.rectangle("line", rx, ry, rs, rs, 6, 6)
    end
end

local function drawCraftButton()
    local c = layout.craft
    local canCraft = matchedRecipe ~= nil

    local bg = not canCraft and COL.btnBgDisabled
        or hoverCraftBtn and COL.btnBgHover
        or COL.btnBg

    setColor(bg)
    love.graphics.rectangle("fill", c.btnX, c.btnY, c.btnW, c.btnH, 6, 6)
    setColor(COL.btnBorder, canCraft and 1 or 0.5)
    love.graphics.rectangle("line", c.btnX, c.btnY, c.btnW, c.btnH, 6, 6)

    love.graphics.setFont(font)
    setColor(canCraft and COL.btnText or COL.btnTextDisabled)
    love.graphics.printf("Craft", c.btnX, c.btnY + (c.btnH - font:getHeight()) / 2, c.btnW, "center")
end

local function drawCraftingWindow()
    drawWindowChrome(layout.craft, "Crafting")
    drawCraftingGrid()
    drawResultPreview()
    drawCraftButton()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CRAFTING ACTION
-- ─────────────────────────────────────────────────────────────────────────────

-- Consumes exactly the amounts required by the recipe from the craft grid,
-- leaving any surplus behind in place (rather than wiping whole stacks).
local function consumeRecipeIngredients(recipe)
    for _, ing in ipairs(recipe.inputs) do
        local remaining = ing.count

        for r = 1, CRAFT_ROWS do
            for c = 1, CRAFT_COLS do
                if remaining <= 0 then break end

                local slot = craftGrid[r][c]
                if slot ~= 0 and slot.item.name == ing.name then
                    local take = math.min(slot.count, remaining)
                    slot.count = slot.count - take
                    remaining = remaining - take

                    if slot.count <= 0 then
                        craftGrid[r][c] = 0
                    end
                end
            end
        end
    end
end

local function tryCraft()
    if not matchedRecipe then return end

    local result = matchedRecipe.result
    local craftedItem = item.new(result.name, result.imgPath, result.desc)

    consumeRecipeIngredients(matchedRecipe)

    for i = 1, (result.count or 1) do
        inv:addItem(craftedItem)
    end

    refreshRecipeMatch()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- GAMESTATE LIFECYCLE
-- ─────────────────────────────────────────────────────────────────────────────

function Crafting:enter()
    resetCraftGrid()
    hoverSlot     = nil
    selectedSlot  = nil
    hoverCraftBtn = false
    refreshRecipeMatch()

    font      = love.graphics.newFont(14)
    smallFont = love.graphics.newFont(11)

    buildLayout()
end

function Crafting:resize(w, h)
    buildLayout()
end

function Crafting:update(dt)
    local mx, my = love.mouse.getPosition()
    hoverSlot     = nil
    hoverCraftBtn = false
    world:update(dt)
    updateGame(dt)
    for y = 1, layout.inv.rows do
        for x = 1, layout.inv.cols do
            local rx, ry, rw, rh = invSlotRect(x, y)
            if pointInRect(mx, my, rx, ry, rw, rh) then
                hoverSlot = { kind = "inv", x = x, y = y }
                return
            end
        end
    end

    for y = 1, CRAFT_ROWS do
        for x = 1, CRAFT_COLS do
            local rx, ry, rw, rh = craftSlotRect(x, y)
            if pointInRect(mx, my, rx, ry, rw, rh) then
                hoverSlot = { kind = "craft", x = x, y = y }
                return
            end
        end
    end

    local c = layout.craft
    if pointInRect(mx, my, c.btnX, c.btnY, c.btnW, c.btnH) then
        hoverCraftBtn = true
    end
end

function Crafting:draw()
    local sw, sh = love.graphics.getDimensions()
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
    setColor(COL.bgDim)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    drawInventoryWindow()
    drawCraftingWindow()

    love.graphics.setColor(1, 1, 1, 1)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- INPUT
-- ─────────────────────────────────────────────────────────────────────────────

-- Moves every item currently sitting in the craft grid back into the first
-- available inventory slot, then clears the craft grid.
local function returnCraftGridToInventory()
    for r = 1, CRAFT_ROWS do
        for c = 1, CRAFT_COLS do
            local slot = craftGrid[r][c]
            if slot ~= 0 then
                inv:addItem(slot.item, slot.count)
                craftGrid[r][c] = 0
            end
        end
    end
end

function Crafting:keypressed(key)
    if key == 'tab' or key == 'escape' or key == 'e' then
        returnCraftGridToInventory()
        local GS = require 'lib/hump/gamestate'
        GS.pop()
    end
end

function Crafting:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Craft button takes priority over slot interaction
    local c = layout.craft
    if pointInRect(x, y, c.btnX, c.btnY, c.btnW, c.btnH) then
        tryCraft()
        return
    end

    if not hoverSlot then
        selectedSlot = nil
        return
    end

    if not selectedSlot then
        -- Nothing picked up yet — try to pick up whatever is under the cursor
        local data = hoverSlot.kind == "inv"
            and getInvSlot(hoverSlot.x, hoverSlot.y)
            or  getCraftSlot(hoverSlot.x, hoverSlot.y)

        if data ~= 0 then
            selectedSlot = hoverSlot
        end
        return
    end

    -- Something is already picked up — swap it with whatever's under cursor now
    local fromKind, fromX, fromY = selectedSlot.kind, selectedSlot.x, selectedSlot.y
    local toKind,   toX,   toY   = hoverSlot.kind,    hoverSlot.x,    hoverSlot.y

    local fromData = fromKind == "inv" and getInvSlot(fromX, fromY) or getCraftSlot(fromX, fromY)
    local toData    = toKind   == "inv" and getInvSlot(toX, toY)     or getCraftSlot(toX, toY)

    if fromKind == "inv" then inv.arr[fromY][fromX] = toData
    else craftGrid[fromY][fromX] = toData end

    if toKind == "inv" then inv.arr[toY][toX] = fromData
    else craftGrid[toY][toX] = fromData end

    selectedSlot = nil

    -- Any change to the craft grid might unlock/lock a recipe
    refreshRecipeMatch()
end

return Crafting