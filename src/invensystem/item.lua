local item = {}
item.__index = item
function item.new(name, img, desc)
    local itm = setmetatable({
        name = name,
        img = love.graphics.newImage(img),
        desc = desc
    }, item)
    return itm
end
return item