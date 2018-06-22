-- only alter this file if it's named "custom.recipes.lua"
-- alter the recipes as you please and delete / comment out
-- the recipes you don't want to be available in the game
-- the original versions are in "default/recipes.lua"

return {
	["wesh:canvas02"] = {
		{"group:wool", "group:wool",           "group:wool"},
		{"group:wool", "default:steel_ingot",  "group:wool"},
		{"group:wool", "group:wool",           "group:wool"},
	},
	["wesh:canvas04"] = {
		{"group:wool", "group:wool",           "group:wool"},
		{"group:wool", "default:copper_ingot", "group:wool"},
		{"group:wool", "group:wool",           "group:wool"},
	},
	["wesh:canvas08"] = {
		{"group:wool", "group:wool",           "group:wool"},
		{"group:wool", "default:tin_ingot",    "group:wool"},
		{"group:wool", "group:wool",           "group:wool"},
	},
	["wesh:canvas16"] = {
		{"group:wool", "group:wool",           "group:wool"},
		{"group:wool", "default:bronze_ingot", "group:wool"},
		{"group:wool", "group:wool",           "group:wool"},
	},
	["wesh:canvas32"] = {
		{"group:wool", "group:wool",           "group:wool"},
		{"group:wool", "default:gold_ingot",   "group:wool"},
		{"group:wool", "group:wool",           "group:wool"},
	},
	["wesh:canvas64"] = {
		{"group:wool", "group:wool",           "group:wool"},
		{"group:wool", "default:diamond",      "group:wool"},
		{"group:wool", "group:wool",           "group:wool"},
	},
	-- this is the orientation block with colored faces
	-- marked according to the semiaxes they point to
	["wesh:faces"] = {
		{"group:wool", "",           "group:wool"},
		{"",           "group:wool", ""},
		{"group:wool", "",           "group:wool"},
	}
}
