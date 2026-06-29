local SpellCombine = {}

local RECIPES = {
    { a = 1, b = 3, result = 11 },  -- Firecharge + Wind Charge -> Fireburst
    { a = 2, b = 2, result = 1 },   -- LightShard + LightShard  -> ???
    { a = 1, b = 1, result = 1 },   -- Shadowballs + Shadowball ->   
    { a = 4, b = 2, result = 1 },
    { a = 2, b = 2, result = 1 },
    { a = 2, b = 2, result = 1 },
}

function SpellCombine.getResult(spellA, spellB)
    for _, recipe in ipairs(RECIPES) do
        local matchAB = (recipe.a == spellA and recipe.b == spellB)
        if matchAB then
            return recipe.result
        end
    end
    return nil
end

return SpellCombine