Config = Config or {}

Config.Monster = {}

Config.Monster_attack_type = {
	WARRIOR 	= 1,	--物理近战
	CLO_MAG		= 2,	--魔法近战
	SHOOTER		= 3,	--物理远程
	FAR_MAG		= 4,	--魔法远程
}

Config.Monster = {
	--编号		名称							稀有度		等级				攻击类型													血量			伤害				物理防御					魔法防御				移动力			速度					护甲穿透						技能列表									头像图片资源名称														角色图片资源名称																										描述
	--{id = 0		,name = "default_monster"	,rarity = 0	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR		,hp = 100	,damage = 20	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."1.obj"		,description = "This is a monster used to test!"	,},
	{id = 1		,name = "ZZZ"				,rarity = 1	,level = 4		,attack_type = Config.Monster_attack_type.WARRIOR		,hp = 100	,damage = 20	,physical_defense = 5	,magic_defense = 5	,mobility = 2	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."1.obj"		,description = "This is a monster used to test!"	,},
	{id = 2		,name = "XXXX"				,rarity = 1	,level = 5		,attack_type = Config.Monster_attack_type.CLO_MAG		,hp = 80	,damage = 30	,physical_defense = 5	,magic_defense = 5	,mobility = 2	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."2.obj"		,description = "This is a monster used to test!"	,},
	{id = 3		,name = "argqargq"			,rarity = 2	,level = 4		,attack_type = Config.Monster_attack_type.FAR_MAG		,hp = 50	,damage = 40	,physical_defense = 5	,magic_defense = 5	,mobility = 3	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."3.obj"		,description = "This is a monster used to test!"	,},
	{id = 4		,name = "HSHSHSHHS"			,rarity = 3	,level = 7		,attack_type = Config.Monster_attack_type.SHOOTER		,hp = 50	,damage = 50	,physical_defense = 5	,magic_defense = 5	,mobility = 3	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."4.obj"		,description = "This is a monster used to test!"	,},
	{id = 5		,name = "adfwr"				,rarity = 4	,level = 9		,attack_type = Config.Monster_attack_type.WARRIOR		,hp = 200	,damage = 30	,physical_defense = 5	,magic_defense = 5	,mobility = 4	,initiative = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = Config.model_path.."5.obj"		,description = "This is a monster used to test!"	,},
}
