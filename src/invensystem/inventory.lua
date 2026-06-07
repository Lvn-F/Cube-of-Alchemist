local utils = require "src/invensystem/utils"

inventory = {}
inventory.__index = inventory

function inventory.new(w,h, hotbarSize)
    local self = {}
    setmetatable(self,inventory)
    self.w = w
    self.h = h
    self.arr = utils.newEmptyArray(w,h,0)
    -- self.hotbar = {}
    -- for i = 1, (hotbarSize or 8) do
    --     self.hotbar[i] = 0
    -- end
    return self
end

function inventory:addItem(item)
    local stop = false
    for y=1,#self.arr do
        for x=1,#self.arr[1] do
            if self.arr[y][x] == 0 then
                self.arr[y][x] = item
                stop = true
                break
            end
        end
        if stop then break end
    end
end

function inventory:replace(x1,y1,x2,y2)
    local ph = self.arr[y1][x1]
    self.arr[y1][x1] = self.arr[y2][x2]
    self.arr[y2][x2] = ph
end

return inventory