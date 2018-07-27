Config = Config or {}

Config.Monster = {}

Config.Monster_attack_type = {
	WARRIOR 	= 1,	--物理近战
	CLO_MAG		= 2,	--魔法近战
	SHOOTER		= 3,	--物理远程
	FAR_MAG		= 4,	--魔法远程
}

Config.Monster = {
	--编号		名称							稀有度		等级				攻击类型													血量			伤害				物理防御					魔法防御				移动力			速度			护甲穿透						技能列表									头像图片资源名称														角色图片资源名称																				描述
	--{id = 0		,name = "default_monster"	,rank = 0	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR		,hp = 100	,damage = 20	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,speed = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = ""		,description = "This is a monster used to test!"	,},
	{id = 1		,name = "default_monster"	,rank = 0	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR		,hp = 100	,damage = 20	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,speed = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = ""		,description = "This is a monster used to test!"	,},
	{id = 2		,name = "default_monster"	,rank = 1	,level = 1		,attack_type = Config.Monster_attack_type.CLO_MAG		,hp = 80	,damage = 30	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,speed = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = ""		,description = "This is a monster used to test!"	,},
	{id = 3		,name = "default_monster"	,rank = 2	,level = 1		,attack_type = Config.Monster_attack_type.FAR_MAG		,hp = 50	,damage = 40	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,speed = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = ""		,description = "This is a monster used to test!"	,},
	{id = 4		,name = "default_monster"	,rank = 3	,level = 1		,attack_type = Config.Monster_attack_type.SHOOTER		,hp = 50	,damage = 50	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,speed = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = ""		,description = "This is a monster used to test!"	,},
	{id = 5		,name = "default_monster"	,rank = 4	,level = 1		,attack_type = Config.Monster_attack_type.WARRIOR		,hp = 200	,damage = 30	,physical_defense = 5	,magic_defense = 5	,mobility = 5	,speed = 50	,defense_penetration = 0	,skills_list = {1001,	1002,	1003,}	,face_img_path = Config.monster_img_path.."face_infantry.png"		,char_img_path = Config.monster_img_path.."char_infantry.png"		,model_path = ""		,description = "This is a monster used to test!"	,},
}
