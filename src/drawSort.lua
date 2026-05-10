-- src/drawSort.lua
-- Draws environtmentBottom tile rows and world entities sorted by Y position,
-- so sprites correctly appear in front of or behind environment objects.

local drawSort = {}

-- Draw a single row of a tile layer without sprite batches.
-- Must be called inside a love.graphics.scale(scale, scale) block.
local function drawTileRow(map, layer, row)
    if not layer.data or not layer.data[row] then return end
    local tileW = map.tilewidth
    local tileH = map.tileheight

    for col = 1, layer.width do
        local tile = layer.data[row][col]
        if tile then
            local image  = map.tilesets[tile.tileset].image
            -- Match STI's orthogonal tile position formula from getLayerTilePosition
            local tileX  = (col - 1) * tileW + tile.offset.x + layer.x
            local tileY  = row * tileH + tile.offset.y - tile.height + layer.y
            love.graphics.draw(image, tile.quad, tileX, tileY, tile.r, tile.sx, tile.sy)
        end
    end
end

-- Returns true if any tile exists in this row of the layer.
local function rowHasContent(layer, row)
    if not layer.data or not layer.data[row] then return false end
    for col = 1, layer.width do
        if layer.data[row][col] then return true end
    end
    return false
end

-- Build and draw a Y-sorted list of:
--   • every non-empty row of map.layers["environtmentBottom"]
--   • player, wolf instances, fire, and shadowballs
--
-- scale: the integer scale applied to map tile drawing (3 in this project).
-- World Y of a tile at map-row r = r * tileheight * scale.
-- Entity positions are already in that world space (mapCollider multiplies by 3).
function drawSort.draw(map, scale)
    local drawables = {}
    local tileH     = map.tileheight * scale  -- world-space height of one tile row

    -- ── Environment tile rows ──────────────────────────────────────────────
    local envLayer = map.layers["environtmentBottom"]
    if envLayer then
        for row = 1, envLayer.height do
            if rowHasContent(envLayer, row) then
                -- Sort by the bottom edge of the tile row in world space.
                -- This makes entities whose Y exceeds the tile base draw on top.
                local envOffset = envLayer.properties.ySortOffset or 0
                local worldBottomY = row * tileH + envOffset
                table.insert(drawables, {
                    y        = worldBottomY,
                    isScaled = true,
                    draw     = function()
                        drawTileRow(map, envLayer, row)
                    end
                })
            end
        end
    end

    -- ── Player ────────────────────────────────────────────────────────────
    -- Use the collider centre as the sort key; close enough to foot position.
    table.insert(drawables, {
        y        = player.y,
        isScaled = false,
        draw     = function() player:draw() end
    })

    -- ── Wolf instances ────────────────────────────────────────────────────
    -- Each wolf is a separate drawable so they sort individually.
    -- wolf.anim is a shared reference; capture it per-frame here.
    for _, wolfs in ipairs(wolf.instance) do
        local wx, wy = wolfs.x, wolfs.y
        table.insert(drawables, {
            y        = wy,
            isScaled = false,
            draw     = function()
                wolf.anim:draw(wolf.spriteSheet, wx, wy, nil, 4, nil, 16, 16)
            end
        })
    end

    -- ── Fire ─────────────────────────────────────────────────────────────
    table.insert(drawables, {
        y        = fire.y,
        isScaled = false,
        draw     = function() fire:draw() end
    })

    -- ── Shadowballs ───────────────────────────────────────────────────────
    -- Individual projectiles sort by their own Y position.
    for _, sb in ipairs(Shadowballs) do
        local sx, sy = sb.pos.x, sb.pos.y
        table.insert(drawables, {
            y        = sy,
            isScaled = false,
            draw     = function()
                Shadowballs.anim:draw(
                    Shadowballs.projectile,
                    sx, sy,
                    sb.rotation,
                    1.5, 1.5,
                    Shadowballs.projectile:getWidth()  / 13,
                    Shadowballs.projectile:getHeight() / 2
                )
            end
        })
    end

    -- ── Sort ascending by world Y (back → front) ─────────────────────────
    table.sort(drawables, function(a, b) return a.y < b.y end)

    -- ── Draw ──────────────────────────────────────────────────────────────
    -- Scaled drawables (tile rows) need the 3× transform; entities do not.
    -- We toggle the scale around each tile-row draw to avoid one giant
    -- push/pop block that would mix coordinate systems.
    for _, d in ipairs(drawables) do
        if d.isScaled then
            love.graphics.push()
            love.graphics.scale(scale, scale)
            d.draw()
            love.graphics.pop()
        else
            d.draw()
        end
    end
end

return drawSort