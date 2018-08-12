Config = Config or {}

Config.sprite = {
	gezi_enable = Config.sprite_path.."hex_tile_enabled.png",
	gezi_barrier = Config.sprite_path.."hex_tile_barrier.png",
	gezi_disable = Config.sprite_path.."hex_tile_disabled.png",
	
	buff_defend = Config.sprite_path.."common_defend.png",

	selected = Config.sprite_path.."icon_selected_1.png",
	chesspiece_mask = Config.sprite_path.."header_hex_mask.png",
	
	team_hp_img_1  = Config.sprite_path.."battle_bloodbar_1.png",
	team_hp_img_4 = Config.sprite_path.."battle_bloodbar_2.png",
	
	team_card_border_1  = Config.sprite_path.."hero_border_self.png",
	team_card_border_4 = Config.sprite_path.."hero_border_other.png",
	boss_card_border  = Config.sprite_path.."hero_border_boss.png",

	hex_border_0 = Config.monster_img_path.."hex_tile_border_0.png",
	hex_border_1 = Config.monster_img_path.."hex_tile_border_1.png",
	hex_border_2 = Config.monster_img_path.."hex_tile_border_2.png",
	hex_border_3 = Config.monster_img_path.."hex_tile_border_3.png",
	hex_border_4 = Config.monster_img_path.."hex_tile_border_4.png",

	rarity_sp_1 = Config.monster_img_path.."item_bg_1_1.png",
	rarity_sp_2 = Config.monster_img_path.."item_bg_1_2.png",
	rarity_sp_3 = Config.monster_img_path.."item_bg_1_3.png",
	rarity_sp_4 = Config.monster_img_path.."item_bg_1_4.png",

	card_border_0 = Config.monster_img_path.."hero_card_border_0.png",
	card_border_1 = Config.monster_img_path.."hero_card_border_1.png",
	card_border_2 = Config.monster_img_path.."hero_card_border_2.png",
	card_border_3 = Config.monster_img_path.."hero_card_border_3.png",
	card_border_4 = Config.monster_img_path.."hero_card_border_4.png",

	attack_type_1 = Config.monster_img_path.."icon_attack_type_1.png",
	attack_type_2 = Config.monster_img_path.."icon_attack_type_2.png",
	attack_type_3 = Config.monster_img_path.."icon_attack_type_3.png",
	attack_type_4 = Config.monster_img_path.."icon_attack_type_4.png",
}

Config.color = {
	rarity_color_1 = cc.c4b(66,152,76,255),
	rarity_color_2 = cc.c4b(74,154,219,255),
	rarity_color_3 = cc.c4b(193,78,242,255),
	rarity_color_4 = cc.c4b(243,146,46,255),

	--miss_color
	damage_0 = cc.c4b(0,0,0,255),
	--low_damage_color
	damage_1 = cc.c4b(127,127,127,255),
	--common_damage_color
	damage_2 = cc.c4b(255,255,255,255),
	--high_damage_color
	damage_3 = cc.c4b(255,255,0,255),
	--higher_damage_color
	damage_4 = cc.c4b(255,165,0,255),
	--highest_damage_color
	damage_5 = cc.c4b(255,0,0,255),
	--skill_damage_color
	damage_6 = cc.c4b(30,144,255,255),
}

Config.text = {
	monster_type_1 = "PHYSICAL MELEE",
	monster_type_2 = "MAGIC MELEE",
	monster_type_3 = "PHYSICAL RANGE",
	monster_type_4 = "MAGIC RANGE",

	rarity_text_1 = "RARITY: COMMON MONSTER",
	rarity_text_2 = "RARITY: EPIC MONSTER",
	rarity_text_3 = "RARITY: MONSTROUS MONSTER",
	rarity_text_4 = "RARITY: DIABOLIC MONSTER",
}
