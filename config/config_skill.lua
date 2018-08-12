Config = Config or {}

Config.Skill = {
	[1001] = {
		name = "Snow Storm",
		description = "Emmmmmmmmmmmmmm...",
		img_path = Config.monster_img_path.."icon_skill_destructive_ray.png",
		range = 0,
		is_need_target = false,
		cost = 4,
		damage = 100,
		damage_level_plus = 10,

		healing = 0,
		healing_level_plus = 0,

	 	paticle_path = Config.paticle_path.."snowstorm.plist",
	 	paticle_pos = cc.p(500,1000),

		buff = {

		},
		debuff = {
			[1] = Config.Buff.move_limit,
		},
	}, 
}