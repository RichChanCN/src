g_config = g_config or {}

g_config.monter = {}

g_config.monster_attack_type = 
{
	WARRIOR 	= 1, 	--物理近战
	CLO_MAG		= 2, 	--魔法近战
	SHOOTER		= 3, 	--物理远程
	FAR_MAG		= 4, 	--魔法远程
}

g_config.monster_move_type = 
{
	WALK 	= 1, 	--步行
	FLY		= 2, 	--飞
}

g_config.monter = 
{
	--编号		名称							稀有度		等级				攻击类型												移动类型										血量			伤害					最大怒气值		物理防御					魔法防御				移动力			速度					护甲穿透						技能列表									头像图片资源名称																角色图片资源名称																												远程攻击粒子或者模型														描述
	--{id = 0		, name = "default_monster"	, rarity = 0	, level = 1		, attack_type = g_config.monster_attack_type.WARRIOR	, move_type = g_config.monster_move_type.WALK	, hp = 100	, damage = 20		, anger = 4		, physical_defense = 5	, magic_defense = 5	, mobility = 5	, initiative = 50	, defense_penetration = 0	, skills_list = {1001, 	1002, 	1003, }	, face_img_path = g_config.monster_img_path.."face_infantry.png"		, char_img_path = g_config.monster_img_path.."char_infantry.png"		, model_path = g_config.model_path.."1.obj"		, 														description = "This is a monster used to test!"	, }, 
	{id = 1		, name = "Grunt"				, rarity = 1	, level = 1		, attack_type = g_config.monster_attack_type.WARRIOR	, move_type = g_config.monster_move_type.WALK	, hp = 100	, damage = 25		, anger = 4		, physical_defense = 1	, magic_defense = 1	, mobility = 2	, initiative = 42	, defense_penetration = 1	, skill = nil							, face_img_path = g_config:to_monster_img_path("face_orcwarrior.png")		, char_img_path = g_config:to_monster_img_path("char_orcwarrior.png")		, model_path = g_config:to_model_path("grunt.c3b")		, 														description = "This is a monster used to test!"	, }, 
	{id = 2		, name = "Wild Bear"			, rarity = 1	, level = 1		, attack_type = g_config.monster_attack_type.CLO_MAG	, move_type = g_config.monster_move_type.WALK	, hp = 240	, damage = 30		, anger = 4		, physical_defense = 1	, magic_defense = 1	, mobility = 2	, initiative = 50	, defense_penetration = 1	, skill = nil							, face_img_path = g_config:to_monster_img_path("face_wildreferee.png")		, char_img_path = g_config:to_monster_img_path("char_wildreferee.png")		, model_path = g_config:to_model_path("bear.c3b")		, 														description = "This is a monster used to test!"	, }, 
	{id = 3		, name = "Jaina"				, rarity = 3	, level = 1		, attack_type = g_config.monster_attack_type.FAR_MAG	, move_type = g_config.monster_move_type.WALK	, hp = 200	, damage = 40		, anger = 4		, physical_defense = 2	, magic_defense = 2	, mobility = 3	, initiative = 65	, defense_penetration = 1	, skill = g_config.skill[1001]			, face_img_path = g_config:to_monster_img_path("face_frostarcher.png")		, char_img_path = g_config:to_monster_img_path("char_frostarcher.png")		, model_path = g_config:to_model_path("jaina.c3b")		, attack_particle =g_config.Particle.magic_ball			, description = "This is a monster used to test!", }, 
	{id = 4		, name = "Skeleton"				, rarity = 2	, level = 1		, attack_type = g_config.monster_attack_type.WARRIOR	, move_type = g_config.monster_move_type.WALK	, hp = 200	, damage = 50		, anger = 4		, physical_defense = 2	, magic_defense = 2	, mobility = 3	, initiative = 70	, defense_penetration = 1	, skill = g_config.skill[1003]			, face_img_path = g_config:to_monster_img_path("face_skeleton.png")			, char_img_path = g_config:to_monster_img_path("char_skeleton.png")			, model_path = g_config:to_model_path("skeleton.c3b")	, 														description = "This is a monster used to test!"	, }, 
	{id = 5		, name = "Red Dragon"			, rarity = 4	, level = 1		, attack_type = g_config.monster_attack_type.WARRIOR	, move_type = g_config.monster_move_type.FLY	, hp = 200	, damage = 60		, anger = 4		, physical_defense = 2	, magic_defense = 2	, mobility = 4	, initiative = 40	, defense_penetration = 2	, skill = nil							, face_img_path = g_config:to_monster_img_path("face_firedragon.png")		, char_img_path = g_config:to_monster_img_path("char_firedragon.png")		, model_path = g_config:to_model_path("reddragon.c3b")	, 														description = "This is a monster used to test!"	, }, 
	{id = 6		, name = "The Captain"			, rarity = 3	, level = 1		, attack_type = g_config.monster_attack_type.WARRIOR	, move_type = g_config.monster_move_type.WALK	, hp = 300	, damage = 55		, anger = 4		, physical_defense = 2	, magic_defense = 2	, mobility = 3	, initiative = 45	, defense_penetration = 1	, skill = g_config.skill[1004]			, face_img_path = g_config:to_monster_img_path("face_paladin.png")			, char_img_path = g_config:to_monster_img_path("char_paladin.png")			, model_path = g_config:to_model_path("captain.c3b")	, 														description = "This is a monster used to test!"	, }, 
	{id = 7		, name = "Tauren"				, rarity = 2	, level = 1		, attack_type = g_config.monster_attack_type.WARRIOR	, move_type = g_config.monster_move_type.WALK	, hp = 360	, damage = 40		, anger = 4		, physical_defense = 2	, magic_defense = 2	, mobility = 3	, initiative = 48	, defense_penetration = 1	, skill = g_config.skill[1002]			, face_img_path = g_config:to_monster_img_path("face_tauren.png")			, char_img_path = g_config:to_monster_img_path("char_tauren.png")			, model_path = g_config:to_model_path("tauren.c3b")		, 														description = "This is a monster used to test!"	, }, 
}

g_config.create_animate_tbl = function(self, sf, ef)
	return {start_frame = sf, end_frame = ef}
end

g_config.monster_animate = 
{
	[1] = 
	{
		[1]		= g_config:create_animate_tbl(0, 89), 
		[2]	 	= g_config:create_animate_tbl(91, 121), 
		[3]		= g_config:create_animate_tbl(122, 151), 
		[4]	 	= g_config:create_animate_tbl(152, 172), 
		[5]		= g_config:create_animate_tbl(173, 220), 
		[6]		= g_config:create_animate_tbl(221, 266), 
		show_num = 6, 

		alive		= g_config:create_animate_tbl(0, 89), 
		attack1 	= g_config:create_animate_tbl(91, 121), 
		attack2		= g_config:create_animate_tbl(122, 151), 
		skill		= g_config:create_animate_tbl(122, 151), 
		walk	 	= g_config:create_animate_tbl(152, 172), 
		die 		= g_config:create_animate_tbl(173, 220), 
		victory		= g_config:create_animate_tbl(221, 266), 
	}, 

	[2] = 
	{
		[1]		= g_config:create_animate_tbl(0, 52), 
		[2]		= g_config:create_animate_tbl(53, 84), 
		[3]		= g_config:create_animate_tbl(85, 115), 
		[4]		= g_config:create_animate_tbl(116, 131), 
		[5]		= g_config:create_animate_tbl(132, 152), 
		[6]		= g_config:create_animate_tbl(153, 243), 
		show_num = 6, 

		alive		= g_config:create_animate_tbl(0, 52), 
		attack1		= g_config:create_animate_tbl(53, 84), 
		attack2 	= g_config:create_animate_tbl(85, 115), 
		skill 		= g_config:create_animate_tbl(85, 115), 
		beattacked	= g_config:create_animate_tbl(116, 131), 
		walk	 	= g_config:create_animate_tbl(132, 152), 
		die	 		= g_config:create_animate_tbl(153, 243), 
	}, 

	[3] = 
	{
		[1]		= g_config:create_animate_tbl(0, 40), 
		[2]		= g_config:create_animate_tbl(41, 84), 
		[3]		= g_config:create_animate_tbl(85, 167), 
		[4]	 	= g_config:create_animate_tbl(168, 230), 
		[5]		= g_config:create_animate_tbl(231, 336), 
		[6]		= g_config:create_animate_tbl(337, 429), 
		[7]		= g_config:create_animate_tbl(430, 511), 
		show_num = 7, 

		alive 		= g_config:create_animate_tbl(0, 40), 
		attack1 	= g_config:create_animate_tbl(41, 84), 
		attack2 	= g_config:create_animate_tbl(85, 167), 
		skill 		= g_config:create_animate_tbl(85, 167), 
		walk	 	= g_config:create_animate_tbl(168, 230), 
		die	 		= g_config:create_animate_tbl(231, 336), 
		wait		= g_config:create_animate_tbl(337, 429), 
		victory		= g_config:create_animate_tbl(430, 511), 
	}, 

	[4] = 
	{
		[1] 	= g_config:create_animate_tbl(46, 76), 
		[2] 	= g_config:create_animate_tbl(77, 107), 
		[3]		= g_config:create_animate_tbl(145, 216), 
		[4]		= g_config:create_animate_tbl(217, 298), 
		[5]		= g_config:create_animate_tbl(299, 379), 
		[6]		= g_config:create_animate_tbl(380, 410), 
		show_num = 6, 

		alive		= g_config:create_animate_tbl(0, 45), 
		attack1 	= g_config:create_animate_tbl(46, 76), 
		attack2 	= g_config:create_animate_tbl(77, 107), 
		skill 	 	= g_config:create_animate_tbl(77, 107), 
		walk 		= g_config:create_animate_tbl(108, 144), 
		wait		= g_config:create_animate_tbl(145, 216), 
		victory		= g_config:create_animate_tbl(217, 298), 
		stand3		= g_config:create_animate_tbl(299, 379), 
		stand4		= g_config:create_animate_tbl(380, 410), 
	}, 

	[5] = 
	{
		[1]		= g_config:create_animate_tbl(0, 25), 
		[2]	 	= g_config:create_animate_tbl(26, 72), 
		[3]	 	= g_config:create_animate_tbl(73, 120), 
		[4]	 	= g_config:create_animate_tbl(121, 142), 
		[5]		= g_config:create_animate_tbl(143, 244), 
		[6]		= g_config:create_animate_tbl(245, 272), 
		show_num = 6, 

		alive		= g_config:create_animate_tbl(0, 25), 
		attack1 	= g_config:create_animate_tbl(26, 72), 
		attack2 	= g_config:create_animate_tbl(73, 120), 
		skill 		= g_config:create_animate_tbl(73, 120), 
		walk	 	= g_config:create_animate_tbl(121, 142), 
		wait		= g_config:create_animate_tbl(143, 244), 
		walk2		= g_config:create_animate_tbl(245, 272), 
	}, 

	[6] = 
	{
		[1]		= g_config:create_animate_tbl(0, 45), 
		[2] 	= g_config:create_animate_tbl(46, 76), 
		[3] 	= g_config:create_animate_tbl(77, 107), 
		[4]	 	= g_config:create_animate_tbl(108, 138), 
		[5]		= g_config:create_animate_tbl(139, 170), 
		[6]		= g_config:create_animate_tbl(171, 246), 
		[7]	 	= g_config:create_animate_tbl(247, 405), 
		[8]		= g_config:create_animate_tbl(406, 477), 
		[9]		= g_config:create_animate_tbl(478, 502), 
		[10]	= g_config:create_animate_tbl(503, 536), 
		[11]	= g_config:create_animate_tbl(537, 572), 
		show_num = 11, 

		alive		= g_config:create_animate_tbl(0, 45), 
		attack1 	= g_config:create_animate_tbl(46, 76), 
		attack2 	= g_config:create_animate_tbl(77, 107), 
		skill 		= g_config:create_animate_tbl(406, 477), 
		attack3	 	= g_config:create_animate_tbl(108, 138), 
		defend		= g_config:create_animate_tbl(139, 170), 
		wait		= g_config:create_animate_tbl(171, 246), 
		stand3	 	= g_config:create_animate_tbl(247, 405), 
		victory		= g_config:create_animate_tbl(406, 477), 
		walk		= g_config:create_animate_tbl(478, 502), 
		walk2		= g_config:create_animate_tbl(503, 536), 
		die			= g_config:create_animate_tbl(537, 572), 
	}, 

	[7] = 
	{
		[1]		= g_config:create_animate_tbl(0, 80), 
		[2] 	= g_config:create_animate_tbl(81, 120), 
		[3]	 	= g_config:create_animate_tbl(121, 353), 
		[4]	 	= g_config:create_animate_tbl(354, 444), 
		[5]		= g_config:create_animate_tbl(445, 475), 
		[6]		= g_config:create_animate_tbl(476, 537), 
		[7]	 	= g_config:create_animate_tbl(538, 578), 
		[8]		= g_config:create_animate_tbl(580, 675), 
		show_num = 8, 

		alive		= g_config:create_animate_tbl(0, 80), 
		attack2 	= g_config:create_animate_tbl(81, 120), 
		skill 		= g_config:create_animate_tbl(81, 120), 
		wait	 	= g_config:create_animate_tbl(121, 353), 
		victory	 	= g_config:create_animate_tbl(354, 444), 
		walk		= g_config:create_animate_tbl(445, 475), 
		stand3		= g_config:create_animate_tbl(476, 537), 
		attack1	 	= g_config:create_animate_tbl(538, 578), 
		die			= g_config:create_animate_tbl(580, 675), 
	}, 
}

g_config.get_monster_animate = function(self, monster, animate)
	local frame_tbl = g_config.monster_animate[monster.id][animate]
	return cc.Animate3D:createWithFrames(monster.animation, frame_tbl.start_frame, frame_tbl.end_frame)
end
