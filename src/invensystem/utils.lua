local utils = {
    newEmptyArray = function (w, h, placeholder)
        local toRet = {}
        for i = 1, h do 
            local toIns = {}
            for j = 1, w do
            table.insert(toIns, placeholder)
            end
            table.insert(toRet, toIns)
        end
        return toRet
    end
}
return utils