Config = {}

Config.Debug = false


--bountyhunter
Config.Price = math.random(50, 150)



Config.BlipBounty = {
    blipName = 'strange area', -- Config.Blip.blipName
    blipScale = 0.2 -- Config.Blip.blipScale
}

Config.BountyLocation = {
    
	["UFO camp"] = {
        description = "Hideout ",
        coords = {
            vec3(7.35, 931.29, 209.19),
            vec3(17.23, 924.59, 208.22),
			vec3(6.03, 915.32, 209.85),
			vec3(39.26, 936.69, 208.11),
            
        }
    }
}

Config.weapons = {
	{hash = 0x772C8DD6},
	{hash = 0x169F59F7},
	{hash = 0xDB21AC8C},
	{hash = 0x6DFA071B},
	{hash = 0xF5175BA1},
	{hash = 0xD2718D48},
	{hash = 0x797FBF5},
	{hash = 0x772C8DD6},
	{hash = 0x7BBD1FF6},
	{hash = 0x63F46DE6},
	{hash = 0xA84762EC},
	{hash = 0xDDF7BC1E},
	{hash = 0x20D13FF},
	{hash = 0x1765A8F8},
	{hash = 0x657065D6},
	{hash = 0x8580C63E},
	{hash = 0x95B24592},
	{hash = 0x31B7B9FE},
	{hash = 0x88A8505C},
	{hash = 0x1C02870C},
	{hash = 0x28950C71},
	{hash = 0x6DFA071B},
}

Config.models = {
    --{hash = "cs_dutch", name = "Dutch van der Linde", description = "Leader of the Van der Linde Gang"},
    --{hash = "cs_micahbell", name = "Micah Bell", description = "Dangerous gunslinger"},
    --{hash = "CS_charlessmith", name = "Charles Smith", description = "Skilled hunter and fighter"},
    --{hash = "CS_johnmarston", name = "John Marston", description = "Former outlaw"},
    --{hash = "CS_hoseamatthews", name = "Hosea Matthews", description = "Veteran conman"},
    --{hash = "CS_mrsadler", name = "Sadie Adler", description = "Fierce bounty hunter"},
    --{hash = "CS_leostrauss", name = "Leopold Strauss", description = "Money lender"},
    --{hash = "CS_abigailroberts", name = "Abigail Roberts", description = "Former gang member"},
    --{hash = "cs_poisonwellshaman", name = "Poison Well Shaman", description = "Mystical native shaman"},
    {hash = "cs_crackpotrobot", name = "Crackpot Robot", description = "Eccentric mechanical creation"},
}
