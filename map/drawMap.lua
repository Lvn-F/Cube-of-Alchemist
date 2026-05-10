
function drawBefore()
    map:drawLayer(map.layers["base"])
    map:drawLayer(map.layers["base1"])
    map:drawLayer(map.layers["grassL"])
    map:drawLayer(map.layers["envBot2"])
end
function drawAfter()
    map:drawLayer(map.layers["environtmentTop"])
    map:drawLayer(map.layers["grassR"])
end