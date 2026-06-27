-- src/util/recipes.lua
--
-- Crafting recipe definitions, consumed by src/states/crafting.lua.
-- Each recipe:
--   inputs = { { name = "<item name>", count = <needed amount> }, ... }
--   result = { name = "<result item name>", imgPath = "<path to sprite>",
--              desc = "<description>", count = <amount produced> }
--
-- `inputs` names must match the `name` field used when items are created
-- (see itemDefs in src/object/plant/herb.lua, e.g. "Herb", "Fire Herb").

local Recipes = {
    {
        inputs = { { name = "Herb", count = 1 } },
        result = {
            name    = "Potion",
            imgPath = pathImg.consumable .. "potion.png",
            desc    = "Restores a small amount of health.",
            count   = 1,
        },
    },
    {
        inputs = { { name = "Fire Herb", count = 1} },
        result = {
            name = "Fire Essence",
            imgPath = pathImg.consumable .. "potion.png",
            desc = "Recharge your fire affinity",
            count = 1,
        }
    }

    -- Example of a multi-ingredient recipe, ready to extend later:
    -- {
    --     inputs = { { name = "Herb", count = 1 }, { name = "Fire Herb", count = 1 } },
    --     result = {
    --         name    = "Fire Potion",
    --         imgPath = pathImg.consumable .. "firepotion.png",
    --         desc    = "A potion infused with fire herb.",
    --         count   = 1,
    --     },
    -- },
}

return Recipes