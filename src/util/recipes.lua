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
        inputs = { { name = "Fire Herb", count = 1}, { name = "Slime Gel", count =1 } },
        result = {
            name = "Fire Essence",
            imgPath = pathImg.consumable .. "shardfire.png",
            desc = "Recharge your fire affinity",
            count = 1,
        }
    }
}

return Recipes