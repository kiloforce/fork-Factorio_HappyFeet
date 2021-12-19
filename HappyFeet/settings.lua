data:extend({
	{
		type = "string-setting",
		name = "tile-blacklist",
		setting_type = "runtime-per-user",
		default_value = "stone,stone-brick",
		order = "02"
	},
	{
		type = "int-setting",
		name = "tile-range",
		setting_type = "runtime-per-user",
		default_value = 2,
		minimum_value = 0,
		maximum_value = 25,
		order = "01"
	},
	{
		type = "bool-setting",
		name = "happy-factorissimo",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "03"
	}
})
