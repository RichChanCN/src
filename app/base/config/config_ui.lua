g_config = g_config or {}

g_config.sprite = 
{
	gezi_enable 		= g_config:to_sprite_path("hex_tile_enabled.png"),
	gezi_barrier 		= g_config:to_sprite_path("hex_tile_barrier.png"),
	gezi_disable 		= g_config:to_sprite_path("hex_tile_disabled.png"),
	
	card_crystal 		= g_config:to_sprite_path("icon_crystal.png"),
	card_coin 			= g_config:to_sprite_path("icon_gold.png"),

	tip_bg 				= g_config:to_sprite_path("bg_chat_join.png"),

	challenge_normal 	= g_config:to_sprite_path("site_open.png"),
	challenge_best 		= g_config:to_sprite_path("site_challenged.png"),

	site_star_get 		= g_config:to_sprite_path("icon_star_1.png"),
	site_star_empty 	= g_config:to_sprite_path("icon_star_0.png"),

	star_0_site 		= g_config:to_sprite_path("site_not_open.png"),
	star_1_site 		= g_config:to_sprite_path("site_bg_star_1.png"),
	star_2_site 		= g_config:to_sprite_path("site_bg_star_2.png"),
	star_3_site 		= g_config:to_sprite_path("site_bg_star_3.png"),

	lager_star_got 		= g_config:to_sprite_path("site_big_star.png"),
	lager_star_empty 	= g_config:to_sprite_path("site_big_star_gray.png"),

	autoOn 				= g_config:to_sprite_path("autoOn.png"),
	autoOff 			= g_config:to_sprite_path("autoOff.png"),

	result_star_got 	= g_config:to_sprite_path("star.png"),
	result_star_gray 	= g_config:to_sprite_path("star_gray.png"),

	result_win_band 	= g_config:to_sprite_path("result_win_title_bg.png"),
	result_defeat_band 	= g_config:to_sprite_path("result_defeated_title_bg.png"),
	result_win_bg 		= g_config:to_sprite_path("combat_result_win_bg.png"),
	result_defeat_bg 	= g_config:to_sprite_path("combat_result_defeated_bg.png"),

	buff_defend 		= g_config:to_sprite_path("common_defend.png"),

	selected 			= g_config:to_sprite_path("icon_selected_1.png"),
	chesspiece_mask 	= g_config:to_sprite_path("header_hex_mask.png"),
	
	team_hp_img_1  		= g_config:to_sprite_path("battle_bloodbar_1.png"),
	team_hp_img_4 		= g_config:to_sprite_path("battle_bloodbar_2.png"),
	
	team_card_border_1  = g_config:to_sprite_path("hero_border_self.png"),
	team_card_border_4 	= g_config:to_sprite_path("hero_border_other.png"),
	boss_card_border  	= g_config:to_sprite_path("hero_border_boss.png"),

	hex_border_0 		= g_config:to_monster_img_path("hex_tile_border_0.png"),
	hex_border_1 		= g_config:to_monster_img_path("hex_tile_border_1.png"),
	hex_border_2 		= g_config:to_monster_img_path("hex_tile_border_2.png"),
	hex_border_3 		= g_config:to_monster_img_path("hex_tile_border_3.png"),
	hex_border_4 		= g_config:to_monster_img_path("hex_tile_border_4.png"),

	rarity_sp_1 		= g_config:to_monster_img_path("item_bg_1_1.png"),
	rarity_sp_2 		= g_config:to_monster_img_path("item_bg_1_2.png"),
	rarity_sp_3 		= g_config:to_monster_img_path("item_bg_1_3.png"),
	rarity_sp_4 		= g_config:to_monster_img_path("item_bg_1_4.png"),

	card_border_0 		= g_config:to_monster_img_path("hero_card_border_0.png"),
	card_border_1 		= g_config:to_monster_img_path("hero_card_border_1.png"),
	card_border_2 		= g_config:to_monster_img_path("hero_card_border_2.png"),
	card_border_3 		= g_config:to_monster_img_path("hero_card_border_3.png"),
	card_border_4 		= g_config:to_monster_img_path("hero_card_border_4.png"),

	attack_type_1 		= g_config:to_monster_img_path("icon_attack_type_1.png"),
	attack_type_2 		= g_config:to_monster_img_path("icon_attack_type_2.png"),
	attack_type_3 		= g_config:to_monster_img_path("icon_attack_type_3.png"),
	attack_type_4 		= g_config:to_monster_img_path("icon_attack_type_4.png"),
}

g_config.color = 
{
	white 			= cc.c4b(255, 255, 255, 255),
	black 			= cc.c4b(0, 0, 0, 255),
	green 			= cc.c4b(0, 255, 0, 255),
	blue  			= cc.c4b(0, 0, 255, 255),
	red   			= cc.c4b(255, 0, 0, 255),

	rarity_color_1 	= cc.c4b(66, 152, 76, 255),
	rarity_color_2 	= cc.c4b(74, 154, 219, 255),
	rarity_color_3 	= cc.c4b(193, 78, 242, 255),
	rarity_color_4 	= cc.c4b(243, 146, 46, 255),

	coin 			= cc.c4b(255, 255, 0, 255),
	crystal 		= cc.c4b(30, 144, 255, 255),

	--miss_color
	damage_0 		= cc.c4b(0, 0, 0, 255),
	--low_damage_color
	damage_1 		= cc.c4b(127, 127, 127, 255),
	--common_damage_color
	damage_2 		= cc.c4b(255, 255, 255, 255),
	--high_damage_color
	damage_3 		= cc.c4b(255, 255, 0, 255),
	--higher_damage_color
	damage_4 		= cc.c4b(255, 165, 0, 255),
	--highest_damage_color
	damage_5 		= cc.c4b(255, 0, 0, 255),
	--skill_damage_color
	damage_6 		= cc.c4b(30, 144, 255, 255),
	--heal_color
	damage_7 		= cc.c4b(49, 212, 8, 255),
	--poison_damage_color
	damage_8 		= cc.c4b(187, 13, 117, 255),
	--bleeding_damage_color
	damage_9 		= cc.c4b(255, 0, 0, 255),
}

g_config.text = 
{
	monster_type_1 		= "PHYSICAL MELEE",
	monster_type_2 		= "MAGIC MELEE",
	monster_type_3 		= "PHYSICAL RANGE",
	monster_type_4 		= "MAGIC RANGE",

	rarity_text_1 		= "RARITY: COMMON MONSTER",
	rarity_text_2 		= "RARITY: EPIC MONSTER",
	rarity_text_3 		= "RARITY: MONSTROUS MONSTER",
	rarity_text_4 		= "RARITY: DIABOLIC MONSTER",

	reward_had_got 		= "You have already received the rewards!",
	reward_first_get 	= "You win these rewards!",
	defeat 				= "Regrettably, please try again",

	collected_tip 		= "You can get the collected monsters in the rewards",
	uncollected_tip	 	= "You can unlock these monsters in the story or shop",
}

g_config.font = 
{
	default = g_config:to_font_path("camex2.2.ttf"),
}
