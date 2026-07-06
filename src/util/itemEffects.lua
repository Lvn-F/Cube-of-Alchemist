
local ItemEffects = {}

ItemEffects["Potion"] = function()
    playerStat.health = math.min(playerStat.health + 1, playerStat.maxHealthContainer)
    return true
end

ItemEffects["Fire Essence"] = function()
    return true
end

return ItemEffects