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

	 	particle_path = Config.particle_path.."snowstorm.plist",
	 	particle_pos = cc.p(500,1000),

		buff = {

		},
		debuff = {
			[1] = Config.Buff.move_limit,
		},
	}, 

	[1002] = {
		name = "Impact Wave",
		description = "Emmmmmmmmmmmmmm...",
		img_path = Config.monster_img_path.."icon_skill_earth_shake.png",
		range = 2,
		is_need_target = false,
		cost = 0,
		damage = 50,
		damage_level_plus = 5,

		healing = 0,
		healing_level_plus = 0,

	 	particle_path = Config.particle_path.."impactwave.plist",
	 	particle_pos = cc.p(0,0),
	 	particle_scale = 0.5,
	 	particle_delay_time = 0.7, 
		buff = {

		},
		debuff = {
			[1] = Config.Buff.stun,
		},
	}, 
}