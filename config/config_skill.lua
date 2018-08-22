g_config = g_config or {}

g_config.skill = 
{
	--暴风雪
	[1001] = 
	{
		--技能名称
		name = "Snow Storm",
		--技能描述
		description = "Cost 4 anger points,deals 100+(10*level) damage to all enemies,And they add freezing to them, minus their mobility in next action.",
		--技能图标路径
		img_path = g_config.monster_img_path.."icon_skill_destructive_ray.png",
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
	 	particle_path = g_config.particle_path.."snowstorm.plist",
	 	--粒子放置的位置
	 	particle_pos = cc.p(500,1000),
	 	--给队友加的buff列表
		buff = 
		{

		},
		--给敌人加的buff列表
		debuff = 
		{
			[1] = g_config.buff.move_limit,
		},
	}, 
	--冲击波
	[1002] = 
	{
		name = "Impact Wave",
		description = "Cost 4 anger points, deals 50+(10*5) damage to all enemies around self, And they can't do anything in next action.",
		img_path = g_config.monster_img_path.."icon_skill_earth_shake.png",
		range = 2,
		is_need_target = false,
		cost = 4,
		damage = 50,
		damage_level_plus = 5,

		healing = 0,
		healing_level_plus = 0,

	 	particle_path = g_config.particle_path.."impactwave.plist",
	 	particle_pos = cc.p(0,0),
	 	particle_scale = 0.5,
	 	particle_delay_time = 0.7, 
		buff = 
		{

		},
		debuff = 
		{
			[1] = g_config.buff.stun,
		},
	}, 

	--毒刃
	[1003] = 
	{
		name = "Poison Blade",
		description = "Cost 2 anger points, deals 50+(10*5) damage to an enemy, And it will minus 40 HP when begin next two action",
		img_path = g_config.monster_img_path.."icon_skill_holy_slash.png",
		range = 1,
		is_need_target = true,
		cost = 2,
		damage = 50,
		damage_level_plus = 5,

		healing = 0,
		healing_level_plus = 0,

		buff = 
		{

		},
		debuff = 
		{
			[1] = g_config.buff.poison,
		},
	},

	--友方群体加攻击
	[1004] = 
	{
		name = "Battle Fury",
		description = "Cost 3 anger points, increase all friend 30% damage 2 round.",
		img_path = g_config.monster_img_path.."icon_skill_eager_for_fight.png",
		range = 0,
		is_need_target = false,
		cost = 3,
		damage = 0,
		damage_level_plus = 0,

		healing = 0,
		healing_level_plus = 0,

		buff = 
		{
			[1] = g_config.buff.damage_up,
		},
		debuff = 
		{
		},
	},
}