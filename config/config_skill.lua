Config = Config or {}

Config.Skill = {
	--暴风雪
	[1001] = {
		--技能名称
		name = "Snow Storm",
		--技能描述
		description = "Emmmmmmmmmmmmmm...",
		--技能图标路径
		img_path = Config.monster_img_path.."icon_skill_destructive_ray.png",
		--技能范围，0的话就是全范围
		range = 0,
		--技能是否需要选择目标
		is_need_target = false,
		--技能消耗的怒气值
		cost = 4,
		--技能的伤害
		damage = 100,
		--怪物等级对技能伤害的加成
		damage_level_plus = 10,
		--治疗量
		healing = 0,
		--怪物等级对治疗量的加成
		healing_level_plus = 0,

		--技能粒子路径
	 	particle_path = Config.particle_path.."snowstorm.plist",
	 	--粒子放置的位置
	 	particle_pos = cc.p(500,1000),
	 	--给队友加的buff列表
		buff = {

		},
		--给敌人加的buff列表
		debuff = {
			[1] = Config.Buff.move_limit,
		},
	}, 
	--冲击波
	[1002] = {
		name = "Impact Wave",
		description = "Emmmmmmmmmmmmmm...",
		img_path = Config.monster_img_path.."icon_skill_earth_shake.png",
		range = 2,
		is_need_target = false,
		cost = 4,
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

	--毒刃
	[1003] = {
		name = "Poison Blade",
		description = "Emmmmmmmmmmmmmm...",
		img_path = Config.monster_img_path.."icon_skill_holy_slash.png",
		range = 1,
		is_need_target = true,
		cost = 0,
		damage = 50,
		damage_level_plus = 5,

		healing = 0,
		healing_level_plus = 0,

		buff = {

		},
		debuff = {
			[1] = Config.Buff.poison,
		},
	},

	--友方群体加攻击
	[1004] = {
		name = "Battle Fury",
		description = "Emmmmmmmmmmmmmm...",
		img_path = Config.monster_img_path.."icon_skill_eager_for_fight.png",
		range = 0,
		is_need_target = false,
		cost = 3,
		damage = 0,
		damage_level_plus = 0,

		healing = 0,
		healing_level_plus = 0,

		buff = {
			[1] = Config.Buff.damage_up,
		},
		debuff = {
		},
	},
}