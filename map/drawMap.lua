
function drawBefore()
    map:drawLayer(map.layers["base0"])
    map:drawLayer(map.layers["base"])
    map:drawLayer(map.layers["base1"])
    map:drawLayer(map.layers["grassL"])
    -- map:drawLayer(map.layers["environtmentBottom"])
    map:drawLayer(map.layers["envBot2"])
end
function drawAfter()
    map:drawLayer(map.layers["environtmentTop"])
    map:drawLayer(map.layers["grassR"])
    love.graphics.push()
        love.graphics.scale(4,4)
        map:drawLayer(map.layers["shaderlayer1"])
    love.graphics.pop()
    map:drawLayer(map.layers["shaderlayercolor"])
end