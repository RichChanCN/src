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
	--编号		名称							稀有度		等级				攻击类型												移动类型										血量			伤害				物理防御					魔法防御				移动力			速度					护甲穿透						技能列表									头像图片资源名称														角色图片资源名称																											描述
	--{id = 0		,name = "default_monster"	,rarity = 0	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 100	,damage = 20	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."1.obj"			,description = "This is a monster used to test!"	,},
	{id = 1		,name = "Grunt"				,rarity = 1	,level = 4		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 100	,damage = 20	,physical_defense = 5	,magic_defense = 5	,mobility = 2	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_orcwarrior.png"		,char_img_path = Config.monster_img_path.."char_orcwarrior.png"		,model_path = Config.model_path.."grunt.c3b"		,description = "This is a monster used to test!"	,},
	{id = 2		,name = "Wild Bear"			,rarity = 1	,level = 5		,attack_type = Config.Monster_attack_type.CLO_MAG	,move_type = Config.Monster_move_type.WALK	,hp = 80	,damage = 30	,physical_defense = 5	,magic_defense = 5	,mobility = 2	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_wildreferee.png"	,char_img_path = Config.monster_img_path.."char_wildreferee.png"	,model_path = Config.model_path.."bear.c3b"			,description = "This is a monster used to test!"	,},
	{id = 3		,name = "Jaina"				,rarity = 2	,level = 4		,attack_type = Config.Monster_attack_type.FAR_MAG	,move_type = Config.Monster_move_type.WALK	,hp = 50	,damage = 40	,physical_defense = 5	,magic_defense = 5	,mobility = 3	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_frostarcher.png"	,char_img_path = Config.monster_img_path.."char_frostarcher.png"	,model_path = Config.model_path.."jaina.c3b"		,description = "This is a monster used to test!"	,},
	{id = 4		,name = "Skeleton"			,rarity = 3	,level = 7		,attack_type = Config.Monster_attack_type.SHOOTER	,move_type = Config.Monster_move_type.WALK	,hp = 50	,damage = 50	,physical_defense = 5	,magic_defense = 5	,mobility = 3	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_skeleton.png"		,char_img_path = Config.monster_img_path.."char_skeleton.png"		,model_path = Config.model_path.."skeleton.c3b"		,description = "This is a monster used to test!"	,},
	{id = 5		,name = "Red Dragon"		,rarity = 4	,level = 9		,attack_type = Config.Monster_attack_type.WARRIOR	,move_type = Config.Monster_move_type.WALK	,hp = 200	,damage = 30	,physical_defense = 5	,magic_defense = 5	,mobility = 4	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_firedragon.png"		,char_img_path = Config.monster_img_path.."char_firedragon.png"		,model_path = Config.model_path.."reddragon.c3b"	,description = "This is a monster used to test!"	,},
}
