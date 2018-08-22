Config = Config or {}

Config.Monster = {}

Config.Monster_attack_type = {
	WARRIOR 	= 1,	--物理近战
	CLO_MAG		= 2,	--魔法近战
	SHOOTER		= 3,	--物理远程
	FAR_MAG		= 4,	--魔法远程
}

Config.Monster_move_type = {
	WALK 	= 1,	--步行
	FLY		= 2,	--飞
}

Config.Monster = {
	--编号		名称							稀有度		等级				攻击类型												移动类型										血量			伤害					最大怒气值		物理防御					魔法防御				移动力			速度					护甲穿透						技能列表									头像图片资源名称														角色图片资源名称																											远程攻击粒子或者模型														描述
	--{id = 0		,name = "default_monster"	,rarity = 0	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 100	,damage = 20		,anger = 4		,physical_defense = 5	,magic_defense = 5	,mobility = 5	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."1.obj"		,														description = "This is a monster used to test!"	,},
	{id = 1		,name = "Grunt"				,rarity = 1	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 100	,damage = 25		,anger = 4		,physical_defense = 1	,magic_defense = 1	,mobility = 2	,initiative = 42	,defense_penetration = 1	,skill = nil							,face_img_path = Config.monster_img_path.."face_orcwarrior.png"		,char_img_path = Config.monster_img_path.."char_orcwarrior.png"		,model_path = Config.model_path.."grunt.c3b"		,														description = "This is a monster used to test!"	,},
	{id = 2		,name = "Wild Bear"			,rarity = 1	,level = 1		,attack_type = Config.Monster_attack_type.CLO_MAG	,move_type = Config.Monster_move_type.WALK	,hp = 240	,damage = 30		,anger = 4		,physical_defense = 1	,magic_defense = 1	,mobility = 2	,initiative = 50	,defense_penetration = 1	,skill = nil							,face_img_path = Config.monster_img_path.."face_wildreferee.png"	,char_img_path = Config.monster_img_path.."char_wildreferee.png"	,model_path = Config.model_path.."bear.c3b"			,														description = "This is a monster used to test!"	,},
	{id = 3		,name = "Jaina"				,rarity = 3	,level = 1		,attack_type = Config.Monster_attack_type.FAR_MAG	,move_type = Config.Monster_move_type.WALK	,hp = 200	,damage = 40		,anger = 4		,physical_defense = 2	,magic_defense = 2	,mobility = 3	,initiative = 65	,defense_penetration = 1	,skill = Config.Skill[1001]				,face_img_path = Config.monster_img_path.."face_frostarcher.png"	,char_img_path = Config.monster_img_path.."char_frostarcher.png"	,model_path = Config.model_path.."jaina.c3b"		,attack_particle =Config.Particle.magic_ball			,description = "This is a monster used to test!"	,},
	{id = 4		,name = "Skeleton"			,rarity = 2	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 200	,damage = 50		,anger = 4		,physical_defense = 2	,magic_defense = 2	,mobility = 3	,initiative = 70	,defense_penetration = 1	,skill = Config.Skill[1003]				,face_img_path = Config.monster_img_path.."face_skeleton.png"		,char_img_path = Config.monster_img_path.."char_skeleton.png"		,model_path = Config.model_path.."skeleton.c3b"		,														description = "This is a monster used to test!"	,},
	{id = 5		,name = "Red Dragon"		,rarity = 4	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.FLY	,hp = 200	,damage = 60		,anger = 4		,physical_defense = 2	,magic_defense = 2	,mobility = 4	,initiative = 40	,defense_penetration = 2	,skill = nil							,face_img_path = Config.monster_img_path.."face_firedragon.png"		,char_img_path = Config.monster_img_path.."char_firedragon.png"		,model_path = Config.model_path.."reddragon.c3b"	,														description = "This is a monster used to test!"	,},
	{id = 6		,name = "The Captain"		,rarity = 3	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 300	,damage = 55		,anger = 4		,physical_defense = 2	,magic_defense = 2	,mobility = 3	,initiative = 45	,defense_penetration = 1	,skill = Config.Skill[1004]				,face_img_path = Config.monster_img_path.."face_paladin.png"		,char_img_path = Config.monster_img_path.."char_paladin.png"		,model_path = Config.model_path.."captain.c3b"		,														description = "This is a monster used to test!"	,},
	{id = 7		,name = "Tauren"			,rarity = 2	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 360	,damage = 40		,anger = 4		,physical_defense = 2	,magic_defense = 2	,mobility = 3	,initiative = 48	,defense_penetration = 1	,skill = Config.Skill[1002]				,face_img_path = Config.monster_img_path.."face_tauren.png"			,char_img_path = Config.monster_img_path.."char_tauren.png"			,model_path = Config.model_path.."tauren.c3b"		,														description = "This is a monster used to test!"	,},
}

Config.Monster_animate = {
	[1] = {

		[1]		= function(animation) return cc.Animate3D:createWithFrames(animation,0,89) end,
		[2]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,91,121) end,
		[3]		= function(animation) return cc.Animate3D:createWithFrames(animation,122,151) end,
		[4]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,152,172) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,173,220) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,221,266) end,
		show_num = 6,

		alive		= function(animation) return cc.Animate3D:createWithFrames(animation,0,89) end,
		attack1 	= function(animation) return cc.Animate3D:createWithFrames(animation,91,121) end,
		attack2		= function(animation) return cc.Animate3D:createWithFrames(animation,122,151) end,
		skill		= function(animation) return cc.Animate3D:createWithFrames(animation,122,151) end,
		walk	 	= function(animation) return cc.Animate3D:createWithFrames(animation,152,172) end,
		die 		= function(animation) return cc.Animate3D:createWithFrames(animation,173,220) end,
		victory		= function(animation) return cc.Animate3D:createWithFrames(animation,221,266) end,
	},

	[2] = {

		[1]		= function(animation) return cc.Animate3D:createWithFrames(animation,0,52) end,
		[2]		= function(animation) return cc.Animate3D:createWithFrames(animation,53,84) end,
		[3]		= function(animation) return cc.Animate3D:createWithFrames(animation,85,115) end,
		[4]		= function(animation) return cc.Animate3D:createWithFrames(animation,116,131) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,132,152) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,153,243) end,
		show_num = 6,

		alive		= function(animation) return cc.Animate3D:createWithFrames(animation,0,52) end,
		attack1		= function(animation) return cc.Animate3D:createWithFrames(animation,53,84) end,
		attack2 	= function(animation) return cc.Animate3D:createWithFrames(animation,85,115) end,
		skill 		= function(animation) return cc.Animate3D:createWithFrames(animation,85,115) end,
		beattacked	= function(animation) return cc.Animate3D:createWithFrames(animation,116,131) end,
		walk	 	= function(animation) return cc.Animate3D:createWithFrames(animation,132,152) end,
		die	 		= function(animation) return cc.Animate3D:createWithFrames(animation,153,243) end,
	},

	[3] = {

		[1]		= function(animation) return cc.Animate3D:createWithFrames(animation,0,40) end,
		[2]		= function(animation) return cc.Animate3D:createWithFrames(animation,41,84) end,
		[3]		= function(animation) return cc.Animate3D:createWithFrames(animation,85,167) end,
		[4]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,168,230) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,231,336) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,337,429) end,
		[7]		= function(animation) return cc.Animate3D:createWithFrames(animation,430,511) end,
		show_num = 7,

		alive 		= function(animation) return cc.Animate3D:createWithFrames(animation,0,40) end,
		attack1 	= function(animation) return cc.Animate3D:createWithFrames(animation,41,84) end,
		attack2 	= function(animation) return cc.Animate3D:createWithFrames(animation,85,167) end,
		skill 		= function(animation) return cc.Animate3D:createWithFrames(animation,85,167) end,
		walk	 	= function(animation) return cc.Animate3D:createWithFrames(animation,168,230) end,
		die	 		= function(animation) return cc.Animate3D:createWithFrames(animation,231,336) end,
		wait		= function(animation) return cc.Animate3D:createWithFrames(animation,337,429) end,
		victory		= function(animation) return cc.Animate3D:createWithFrames(animation,430,511) end,
	},

	[4] = {

		[1] 	= function(animation) return cc.Animate3D:createWithFrames(animation,46,76) end,
		[2] 	= function(animation) return cc.Animate3D:createWithFrames(animation,77,107) end,
		[3]		= function(animation) return cc.Animate3D:createWithFrames(animation,145,216) end,
		[4]		= function(animation) return cc.Animate3D:createWithFrames(animation,217,298) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,299,379) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,380,410) end,
		show_num = 6,

		alive		= function(animation) return cc.Animate3D:createWithFrames(animation,0,45) end,
		attack1 	= function(animation) return cc.Animate3D:createWithFrames(animation,46,76) end,
		attack2 	= function(animation) return cc.Animate3D:createWithFrames(animation,77,107) end,
		skill 	 	= function(animation) return cc.Animate3D:createWithFrames(animation,77,107) end,
		walk 		= function(animation) return cc.Animate3D:createWithFrames(animation,108,144) end,
		wait		= function(animation) return cc.Animate3D:createWithFrames(animation,145,216) end,
		victory		= function(animation) return cc.Animate3D:createWithFrames(animation,217,298) end,
		stand3		= function(animation) return cc.Animate3D:createWithFrames(animation,299,379) end,
		stand4		= function(animation) return cc.Animate3D:createWithFrames(animation,380,410) end,
	},

	[5] = {

		[1]		= function(animation) return cc.Animate3D:createWithFrames(animation,0,25) end,
		[2]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,26,72) end,
		[3]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,73,120) end,
		[4]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,121,142) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,143,244) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,245,272) end,
		show_num = 6,

		alive		= function(animation) return cc.Animate3D:createWithFrames(animation,0,25) end,
		attack1 	= function(animation) return cc.Animate3D:createWithFrames(animation,26,72) end,
		attack2 	= function(animation) return cc.Animate3D:createWithFrames(animation,73,120) end,
		skill 		= function(animation) return cc.Animate3D:createWithFrames(animation,73,120) end,
		walk	 	= function(animation) return cc.Animate3D:createWithFrames(animation,121,142) end,
		wait		= function(animation) return cc.Animate3D:createWithFrames(animation,143,244) end,
		walk2		= function(animation) return cc.Animate3D:createWithFrames(animation,245,272) end,
	},

	[6] = {

		[1]		= function(animation) return cc.Animate3D:createWithFrames(animation,0,45) end,
		[2] 	= function(animation) return cc.Animate3D:createWithFrames(animation,46,76) end,
		[3] 	= function(animation) return cc.Animate3D:createWithFrames(animation,77,107) end,
		[4]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,108,138) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,139,170) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,171,246) end,
		[7]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,247,405) end,
		[8]		= function(animation) return cc.Animate3D:createWithFrames(animation,406,477) end,
		[9]		= function(animation) return cc.Animate3D:createWithFrames(animation,478,502) end,
		[10]	= function(animation) return cc.Animate3D:createWithFrames(animation,503,536) end,
		[11]	= function(animation) return cc.Animate3D:createWithFrames(animation,537,572) end,
		show_num = 11,

		alive		= function(animation) return cc.Animate3D:createWithFrames(animation,0,45) end,
		attack1 	= function(animation) return cc.Animate3D:createWithFrames(animation,46,76) end,
		attack2 	= function(animation) return cc.Animate3D:createWithFrames(animation,77,107) end,
		skill 		= function(animation) return cc.Animate3D:createWithFrames(animation,406,477) end,
		attack3	 	= function(animation) return cc.Animate3D:createWithFrames(animation,108,138) end,
		defend		= function(animation) return cc.Animate3D:createWithFrames(animation,139,170) end,
		wait		= function(animation) return cc.Animate3D:createWithFrames(animation,171,246) end,
		stand3	 	= function(animation) return cc.Animate3D:createWithFrames(animation,247,405) end,
		victory		= function(animation) return cc.Animate3D:createWithFrames(animation,406,477) end,
		walk		= function(animation) return cc.Animate3D:createWithFrames(animation,478,502) end,
		walk2		= function(animation) return cc.Animate3D:createWithFrames(animation,503,536) end,
		die			= function(animation) return cc.Animate3D:createWithFrames(animation,537,572) end,
	},

	[7] = {
		[1]		= function(animation) return cc.Animate3D:createWithFrames(animation,0,80) end,
		[2] 	= function(animation) return cc.Animate3D:createWithFrames(animation,81,120) end,
		[3]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,121,353) end,
		[4]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,354,444) end,
		[5]		= function(animation) return cc.Animate3D:createWithFrames(animation,445,475) end,
		[6]		= function(animation) return cc.Animate3D:createWithFrames(animation,476,537) end,
		[7]	 	= function(animation) return cc.Animate3D:createWithFrames(animation,538,578) end,
		[8]		= function(animation) return cc.Animate3D:createWithFrames(animation,580,675) end,
		show_num = 8,

		alive		= function(animation) return cc.Animate3D:createWithFrames(animation,0,80) end,
		attack2 	= function(animation) return cc.Animate3D:createWithFrames(animation,81,120) end,
		skill 		= function(animation) return cc.Animate3D:createWithFrames(animation,81,120) end,
		wait	 	= function(animation) return cc.Animate3D:createWithFrames(animation,121,353) end,
		victory	 	= function(animation) return cc.Animate3D:createWithFrames(animation,354,444) end,
		walk		= function(animation) return cc.Animate3D:createWithFrames(animation,445,475) end,
		stand3		= function(animation) return cc.Animate3D:createWithFrames(animation,476,537) end,
		attack1	 	= function(animation) return cc.Animate3D:createWithFrames(animation,538,578) end,
		die			= function(animation) return cc.Animate3D:createWithFrames(animation,580,675) end,
	},
}