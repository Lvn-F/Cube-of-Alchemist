-- map/drawMap.lua

local function safeDraw(layerName)
    local layer = map.layers[layerName]
    if layer then
        map:drawLayer(layer)
    end
end

function drawBefore()
    safeDraw("base0")
    safeDraw("base")
    safeDraw("base1")
    safeDraw("grassL")
    -- safeDraw("environtmentBottom")
    safeDraw("envBot2")
end

function drawAfter()
    safeDraw("environtmentTop")
    safeDraw("grassR")
    love.graphics.push()
        love.graphics.scale(4,4)
        safeDraw("shaderlayer1")
    love.graphics.pop()
    safeDraw("shaderlayercolor")
end