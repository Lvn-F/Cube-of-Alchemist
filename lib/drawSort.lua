-- lib/drawSort.lua
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

function drawSort.draw(map, scale)
    local drawables = {}
    local tileH     = map.tileheight * scale

    -- ── Environment tile rows ──────────────────────────────────────────────
    local envLayer = map.layers["environtmentBottom"]
    if envLayer then
        for row = 1, envLayer.height do
            if rowHasContent(envLayer, row) then
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
    table.insert(drawables, {
        y        = player.y,
        isScaled = false,
        draw     = function() player:draw() end
    })

    -- ── Wolf instances ────────────────────────────────────────────────────
    for _, wolfs in ipairs(wolf.instance) do
        local wx = wolfs.x
        local wy = wolfs.y - 64
        table.insert(drawables, {
            y        = wy,
            isScaled = false,
            draw     = function()
                wolf:draw()
            end
        })
    end

    table.insert(drawables, {
        y = dummy.y + 72,
        isScaled = false,
        draw = function()
            dummy:draw()
            player.animate.shadow:draw(player.spriteSheet, dummy.x + 24, dummy.y + 110, nil, 2.5, nil, 16, 23)
        end
    })

    -- ── Fire ─────────────────────────────────────────────────────────────
    table.insert(drawables, {
        y        = fire.y,
        isScaled = false,
        draw     = function() fire:draw() end
    })

    -- ── Grass instances (one drawable per instance for correct sort order) ─
    for _, inst in ipairs(grass.instances) do
        local gx, gy, ganim = inst.x, inst.y, inst.anim
        table.insert(drawables, {
            y        = gy - 16,
            isScaled = false,
            draw     = function()
                ganim:draw(grass.spriteSheet, gx, gy, nil, 2, nil, 12, 12)
            end
        })
        -- table.insert(drawables, {
        --     y        = gy,
        --     isScaled = false,
        --     draw     = function()
        --         ganim:draw(grass.spriteSheet, gx + 16, gy - 8, nil, 2, nil, 4, 4)
        --     end
        -- })
        -- table.insert(drawables, {
        --     y        = gy,
        --     isScaled = false,
        --     draw     = function()
        --         ganim:draw(grass.spriteSheet, gx + 16, gy + 8, nil, 2, nil, 4, 4)
        --     end
        -- })
        -- table.insert(drawables, {
        --     y        = gy,
        --     isScaled = false,
        --     draw     = function()
        --         ganim:draw(grass.spriteSheet, gx - 16, gy + 16, nil, 2, nil, 4, 4)
        --     end
        -- })
        -- table.insert(drawables, {
        --     y        = gy,
        --     isScaled = false,
        --     draw     = function()
        --         ganim:draw(grass.spriteSheet, gx - 8, gy - 16, nil, 2, nil, 4, 4)
        --     end
        -- })
    end

    -- Shadowballs
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
                    1, 1,
                    Shadowballs.projectile:getWidth()  / 13,
                    Shadowballs.projectile:getHeight() / 2
                )
            end
        })
    end
    for _, sb in ipairs(WindCharges) do
        local sx, sy = sb.pos.x, sb.pos.y
        table.insert(drawables, {
            y        = sy,
            isScaled = false,
            draw     = function()
                sb.anim:draw(
                    WindCharges.projectile,
                    sx, sy,
                    sb.rotation,
                    1.5, 1.5,
                    16,
                    16
                )
            end
        })
    end

    -- Firecharges
    for _, sb in ipairs(Firecharges) do
        local sx, sy = sb.pos.x, sb.pos.y
        table.insert(drawables, {
            y        = sy,
            isScaled = false,
            draw     = function()
                sb.anim:draw(
                    Firecharges.projectile,
                    sx, sy ,
                    sb.rotation,
                    2, 2,
                    16,
                    16
                )
            end
        })
    end
    -- for _, fb in ipairs(FireBurst) do
    --     local sx, sy = fb.pos.x, fb.pos.y
    --     table.insert(drawables, {
    --         y        = sy,
    --         isScaled = false,
    --         draw     = function()
    --             fb.animR:draw(
    --                 FireBurst.projectile,
    --                 sx, sy ,
    --                 fb.rotation,
    --                 1.5, 1.5,
    --                 32,
    --                 32
    --             )
    --             fb.animO:draw(
    --                 FireBurst.projectile,
    --                 sx, sy ,
    --                 fb.rotation,
    --                 1.5, 1.5,
    --                 32,
    --                 32
    --             )
    --             fb.animY:draw(
    --                 FireBurst.projectile,
    --                 sx, sy ,
    --                 fb.rotation,
    --                 1.5, 1.5,
    --                 32,
    --                 32
    --             )
    --         end
    --     })
    -- end
    

    -- ── Sort ascending by world Y (back → front) ─────────────────────────
    table.sort(drawables, function(a, b) return a.y < b.y end)

    -- ── Draw ──────────────────────────────────────────────────────────────
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