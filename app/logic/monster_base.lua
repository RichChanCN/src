local monster_base = {}

monster_base.team_side = {
	NONE 	= 0,
	LEFT 	= 1,
	RIGHT 	= 4,
}

monster_base.damage_level = {
    MISS 		= 0,
    LOW 		= 1,
	COMMON 		= 2,
	HIGH 		= 3,
	HIGHER 		= 4,
	HIGHEST 	= 5,
	SKILL 		= 6,
	HEAL		= 7,
	POISON 		= 8,
}

monster_base.status = {
	DEAD 		= 0,
	ALIVE 		= 1,
	DEFEND 		= 2,
	WAITING 	= 3,
	CANT_ATTACK = 100,
	CANT_ACTIVE = 1000,
	STUN 		= 1001,
}

monster_base.towards = {
	[0]		= 1,
	[1] 	= 1,
	[2] 	= 2,
	[3] 	= 3,
	[4] 	= 4,
	[5] 	= 5,
	[6] 	= 6,
}



monster_base.instance = function(self)
	return setmetatable({}, { __index = self })
end

monster_base.new = function(self, data, team_side, arena_pos)

	team_side = team_side or monster_base.TeamSide.NONE

	self.id 					= data.id
	self.name 					= data.name
	self.level 					= data.level
	self.rarity					= data.rarity
	self.attack_type			= data.attack_type
	self.attack_particle		= data.attack_particle
	self.move_type 				= data.move_type
	
	self.model_path 			= data.model_path
	self.char_img_path			= data.char_img_path

	self._max_anger				= data.anger
	
	self._max_hp 				= data.hp
	self._damage 				= data.damage
	self._physical_defense 		= data.physical_defense
	self._magic_defense 		= data.magic_defense
	self._mobility 				= data.mobility
	self._initiative 			= data.initiative
	self._defense_penetration 	= data.defense_penetration

	self._cur_max_hp 				= self._max_hp 			
	self._cur_damage 				= self._damage 			
	self._cur_physical_defense 		= self._physical_defense 	
	self._cur_magic_defense 		= self._magic_defense 		
	self._cur_mobility 				= self._mobility 			
	self._cur_initiative 			= self._initiative 		
	self._cur_defense_penetration 	= self._defense_penetration

	self._cur_anger					= 0
	self._cur_hp 					= self._max_hp
	self._steps 					= self._cur_mobility
	self._cur_towards				= self._towards
	
	self._team_side				= team_side
	self._towards				= monster_base.towards[team_side]
	self._has_waited			= false
	self._start_pos 			= arena_pos
	self._cur_pos 				= arena_pos
	self._status 				= monster_base.status.ALIVE
	self._buff_list				= {}
	self._debuff_list			= {}

	self._tag = self.id * 100 + self._start_pos.x * 10 + self._start_pos.y
	
	if data.skill then
		local skill_base = require("app.logic.skill_base")
		self._skill = skill_base:instance():new(self,data.skill)
	end

	return self
end

monster_base.get_tag = function(self)
	return self._tag
end

monster_base.get_id = function(self)
	return self.id
end

monster_base.get_team_side = function(self)
	return self._team_side
end

monster_base.get_start_pos = function(self)
	return self._start_pos
end

monster_base.get_cur_pos = function(self)
	return self._cur_pos
end

monster_base.get_cur_hp = function(self)
	return self._cur_hp
end

monster_base.get_cur_pos_num = function(self)
	return gtool:ccp_2_int(self._cur_pos)
end

monster_base.get_skill = function(self)
	return self._skill
end

monster_base.get_max_anger = function(self)
	return self._max_anger
end

monster_base.get_cur_anger = function(self)
	return self._cur_anger
end

monster_base.get_cur_damage = function(self, no_update)
	if no_update then
		return self._cur_damage
	end

	self._cur_damage = self._damage

	self:update_cur_attribute()

	return self._cur_damage
end

monster_base.set_cur_damage = function(self, cd)
	self._cur_damage = cd
end

monster_base.get_cur_max_hp = function(self, no_update)
	if no_update then
		return self._cur_max_hp
	end

	self._cur_max_hp = self._max_hp

	self:update_cur_attribute()

	return self._cur_max_hp
end

monster_base.get_cur_physical_defense = function(self, no_update)
	if no_update then
		return self._cur_physical_defense
	end

	self._cur_physical_defense = self._physical_defense
	
	self:update_cur_attribute()

	return self._cur_physical_defense
end

monster_base.set_cur_physical_defense = function(self, pd)
	self._cur_physical_defense = pd
end

monster_base.get_cur_magic_defense = function(self, no_update)
	if no_update then
		return self._cur_magic_defense
	end

	self._cur_magic_defense = self._magic_defense
	
	self:update_cur_attribute()

	return self._cur_magic_defense
end

monster_base.set_cur_magic_defense = function(self, md)
	self._cur_magic_defense = md
end

monster_base.get_cur_mobility = function(self, no_update)
	if no_update then
		return self._cur_mobility
	end

	self._cur_mobility = self._mobility
	
	self:update_cur_attribute()

	return self._cur_mobility
end

monster_base.set_cur_mobility = function(self, cm)
	self._cur_mobility = cm
end

monster_base.get_cur_initiative = function(self, no_update)
	if no_update then
		return self._cur_initiative
	end

	self._cur_initiative = self._initiative
	
	self:update_cur_attribute()

	return self._cur_initiative
end

monster_base.get_cur_defense_penetration = function(self, no_update)
	if no_update then
		return self._cur_defense_penetration
	end

	self._cur_defense_penetration = self._defense_penetration
	
	self:update_cur_attribute()

	return self._cur_defense_penetration
end

monster_base.get_alive_enemy_monsters = function(self)
	local enemy_list
	if self:is_player() then
		enemy_list = pve_game_ctrl:instance():get_right_alive_monsters()
	else
		enemy_list = pve_game_ctrl:instance():get_left_alive_monsters()
	end

	return enemy_list
end

monster_base.get_alive_friend_monsters = function(self)
	local friend_list
	if not self:is_player() then
		friend_list = pve_game_ctrl:instance():get_right_alive_monsters()
	else
		friend_list = pve_game_ctrl:instance():get_left_alive_monsters()
	end

	return friend_list
end

monster_base.reset = function(self)
	if not self.model and self.animation and self.node then
		return
	end

	self._cur_anger					= 0
	self._cur_hp 					= self._max_hp
	self._cur_pos    				= self._start_pos
	self._cur_towards				= self._towards

	self._cur_max_hp 				= self._max_hp 			
	self._cur_damage 				= self._damage 			
	self._cur_physical_defense 		= self._physical_defense 	
	self._cur_magic_defense 		= self._magic_defense 		
	self._cur_mobility 				= self._mobility 			
	self._cur_initiative 			= self._initiative 		
	self._cur_defense_penetration 	= self._defense_penetration

	self._has_waited					= false

	self._steps 						= self._cur_mobility
	self._buff_list					= {}
	self._debuff_list				= {}

	self:toward_to(self._cur_towards)

	self:change_monster_status(monster_base.status.ALIVE)
end

monster_base.is_monster = function(self)
	return true
end

monster_base.is_fly = function(self)
	return self._move_type == g_config.monster_move_type.FLY
end

monster_base.is_dead = function(self)
	return self._status == monster_base.status.DEAD
end

monster_base.is_defend = function(self)
	return self._status == monster_base.status.DEFNED
end

monster_base.is_melee = function(self)
	return self.attack_type < g_config.monster_attack_type.SHOOTER
end

monster_base.is_physical = function(self)
	return self.attack_type % 2 == 1
end

monster_base.has_waited = function(self)
	return self._has_waited
end

monster_base.has_last_round_waited = function(self)
	return self.has_last_round_waited
end

monster_base.is_player = function(self)
	return self._team_side == monster_base.team_side.LEFT
end

monster_base.is_enemy = function(self, monster)
	return self._team_side ~= monster:get_team_side()
end

monster_base.is_be_back_attacked = function(self, murderer)
	return self._cur_towards == murderer._cur_towards
end

monster_base.is_be_side_attacked = function(self, murderer)
	return self._cur_towards + 1 == murderer._cur_towards
			or self._cur_towards + 1 == murderer._cur_towards + 6
			or self._cur_towards - 1 == murderer._cur_towards
			or self._cur_towards - 1 == murderer._cur_towards - 6
end

monster_base.can_counter_attack = function(self, murderer)
	return self:is_melee()
			and self:can_attack()
			and murderer:is_melee() 
			and self:is_near(gtool:ccp_2_int(murderer._cur_pos)) 
			and not(self:is_be_side_attacked(murderer) or self:is_be_back_attacked(murderer))
end

monster_base.can_use_skill = function(self)
	return self._skill and not(self._cur_anger < self._skill:get_cost())
end

monster_base.can_active = function(self)
	return (not self:is_dead()) and self._status < monster_base.status.CANT_ACTIVE
end

monster_base.can_attack = function(self)
	return self._status < monster_base.status.CANT_ATTACK
end


----------------------------×Ô¶¯´¥·¢----------------------------------
----------------------------×Ô¶¯´¥·¢----------------------------------
----------------------------×Ô¶¯´¥·¢----------------------------------

monster_base.on_enter_new_round = function(self, round_num)
	self.has_last_round_waited = self._has_waited
	self._has_waited = false
end

monster_base.on_active = function(self, round_num)
	if not self:has_waited() then
		self:deal_with_all_buff()
		self._steps = self:get_cur_mobility()
	end

	if self:can_active() then
		self:active()
	else
		pve_game_ctrl:instance():next_monster_activate()
	end
end

monster_base.active = function(self)
	local ac1 = self.node:runAction(cc.Blink:create(0.5, 2))
	self.node:stopAction(ac1)
	local cb = function()
		self.node:setVisible(true)
		if self:is_player() and not pve_game_ctrl:instance():get_auto() then
			self:change_monster_status(monster_base.status.ALIVE)
			pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.WAIT_ORDER)
		else
			self:run_ai()
		end
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1, callback)
	
	self.node:runAction(seq)
end

monster_base.update_cur_attribute = function(self)
	for k, v in pairs(self._buff_list) do
		v.apply(self)
	end

	for k, v in pairs(self._debuff_list) do
		v.apply(self)
	end

end

----------------------------Ö÷¶¯´¥·¢----------------------------------
----------------------------Ö÷¶¯´¥·¢----------------------------------
----------------------------Ö÷¶¯´¥·¢----------------------------------
monster_base.move_to = function(self, arena_pos, attack_target, skill_target_pos)
	pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.RUNNING)
	local cb = function()
		self._cur_pos = arena_pos
		if attack_target then
			local distance = self:get_distance_to_pos(attack_target:get_cur_pos_num(), true)
			self:attack(attack_target, distance)
		elseif skill_target_pos then
			self:use_skill(skill_target_pos)
		else
			self:change_monster_status(monster_base.status.ALIVE)
			if self:nothing_can_do() then
				pve_game_ctrl:instance():next_monster_activate()
			else
				pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.WAIT_ORDER)
			end
		end
	end
	local callback = cc.CallFunc:create(handler(self, cb))
	if gtool:ccp_2_int(arena_pos) == self:get_cur_pos_num() then
		cb()
	else
		self:repeat_animation("walk")
		self:move_follow_path(arena_pos, callback)
	end
end

monster_base.attack = function(self, target, distance)
	pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.RUNNING)
	
	if self:is_melee() and not self:is_near(gtool:ccp_2_int(target._cur_pos)) then
		self:move_and_attack(target)
	else
		if self._attack_particle then
			self:create_attack_particle(target)
		end

		self:add_anger()
		local cur_num = self:get_cur_pos_num()
		local to_num = gtool:ccp_2_int(target._cur_pos)
		self:toward_to_int_pos(cur_num, to_num)
		self:do_animation("attack1")
		target:be_attacked(self, false, distance)
	end
end

monster_base.wait = function(self, is_auto)
	if self:has_waited() then
		if is_auto then
			self:defend()
		else
			uitool:create_top_tip("you has been waited!")
		end
	else
		self:change_monster_status(monster_base.status.WAITING)
		self._has_waited = true
		pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.RUNNING)
		pve_game_ctrl:instance():next_monster_activate(true)
	end
end

monster_base.defend = function(self)
	self:change_monster_status(monster_base.status.DEFEND)
	self:add_buff({g_config.buff.defend})
	pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.RUNNING)
	pve_game_ctrl:instance():next_monster_activate()
end

monster_base.use_skill = function(self, target_pos_num)
	if (not self._skill:is_need_target()) 
		or (self:is_melee() and self:is_near(target_pos_num)) 
		or (not self:is_melee()) then
		
		self._skill:play()
		self:minus_anger(self._skill:get_cost())
		pve_game_ctrl:instance():change_game_status(pve_game_ctrl.game_status.RUNNING)
		
		local cb = function()
			self._skill:use(target_pos_num)
		end
		local callback = cc.CallFunc:create(cb)
		self:toward_to_int_pos(self:get_cur_pos_num(), target_pos_num)
		self:do_animation("skill", callback)
	else
		self:move_and_use_skill(target_pos_num)
	end
end
----------------------------±»¶¯´¥·¢----------------------------------
----------------------------±»¶¯´¥·¢----------------------------------
----------------------------±»¶¯´¥·¢----------------------------------

monster_base.die = function(self, is_buff_or_skill)
	self._status = monster_base.status.DEAD
	self.card.remove_self()

	local ac = self.model:runAction(cc.FadeOut:create(1))
	local cb = function()
		self.node:setVisible(false)
		if not pve_game_ctrl:instance():is_game_over() then
			pve_game_ctrl:instance():check_game_over(is_buff_or_skill)
		end
	end

	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac, callback)
	self:do_animation("die", seq)
end

monster_base.be_attacked = function(self, murderer, is_counter_attack, distance)
	local damage, damage_type = self:get_final_attack_damage(murderer, distance)

	if self:minus_hp(damage, damage_type) then
		self:add_anger()
		local cb = function()
			local cur_num = self:get_cur_pos_num()
			local to_num = gtool:ccp_2_int(murderer._cur_pos)
			if (not is_counter_attack) and self:can_counter_attack(murderer) then
				self:toward_to_int_pos(cur_num, to_num)
				self:counter_attack(murderer)
			else
				self:toward_to_int_pos(cur_num, to_num)
				pve_game_ctrl:instance():next_monster_activate()
			end
		end
		local callback = cc.CallFunc:create(handler(self, cb))
		self:do_animation("beattacked", callback)
	end
end

monster_base.counter_attack = function(self, target)
	local cur_num = self:get_cur_pos_num()
	local to_num = gtool:ccp_2_int(target._cur_pos)
	self:toward_to_int_pos(cur_num, to_num)
	self:do_animation("attack1")
	self:add_anger()
	target:be_attacked(self, true)
end

monster_base.be_affected_by_skill = function(self, skill, is_last)
	if self:is_enemy(skill:get_caster()) then
		if skill:get_damage() > 0 then
			local damage, damage_type = self:get_final_skill_damage(skill)
			self:minus_hp(damage, damage_type, true)
		end
		if #skill:get_debuff() > 0 then
			self:add_debuff(skill:get_debuff())
		end
	else
		if skill:get_healing() > 0 then
			local healing, htype = self:get_final_healing(skill)
			self:add_hp(healing, htype)
		end
		if #skill:get_buff() > 0 then
			self:add_buff(skill:get_buff())
		end
	end

	if is_last then 
		local cb = function()
			pve_game_ctrl:instance():next_monster_activate()
		end
		local callback = cc.CallFunc:create(cb)
		self:do_something_later(callback, 0.6)
	end
end

monster_base.toward_to = function(self, num)
	if not num then 
		return
	end
	self._cur_towards = num
	self.model:setRotation3D(cc.vec3(0, (1 - num) * 60, 0))
end


monster_base.toward_to_int_pos = function(self, cur_num, to_num, only_get)
	
	result_towards = gtool:get_toward_to_int_pos(cur_num, to_num)
	
	if only_get then
		return result_towards
	else
		self:toward_to(result_towards)
	end
end
----------------------------ÉËº¦ÖÎÁÆ¼ÆËãÑªÁ¿Å­Æø----------------------------------
----------------------------ÉËº¦ÖÎÁÆ¼ÆËãÑªÁ¿Å­Æø----------------------------------
----------------------------ÉËº¦ÖÎÁÆ¼ÆËãÑªÁ¿Å­Æø----------------------------------
monster_base.get_final_attack_damage = function(self, murderer, distance)
	local damage = murderer:get_cur_damage()
	local damage_type = monster_base.damage_level.COMMON

	if self:is_be_back_attacked(murderer) then
		damage = damage * 1.5
		damage_type = monster_base.damage_level.HIGHER
	elseif self:is_be_side_attacked(murderer) then
		damage = damage * 1.2
		damage_type = monster_base.damage_level.HIGH
	end

	
	local defense
	if murderer:is_physical() then
		defense = self:get_cur_physical_defense() - murderer:get_cur_defense_penetration()
	else
		defense = self:get_cur_magic_defense() - murderer:get_cur_defense_penetration()
	end
	damage = damage * (1 - defense / (defense + 10))
	
	if not murderer:is_melee() then
		if distance > 5 then
			damage = damage * (1 - (distance - 5) * 2 / 10)
			damage_type = monster_base.damage_level.LOW
		elseif distance < 3 then
			damage = damage * (1 - (3 - distance) / 10)
			damage_type = monster_base.damage_level.LOW
		else
			damage = damage * 1.2
			damage_type = monster_base.damage_level.HIGH
		end
	end

	damage = damage + (math.random() - 0.5) * 10

	if damage < 1 then
		damage = 1
	end

	return math.floor(damage), damage_type
end

monster_base.get_final_healing = function(self, skill)
	local healing = skill:get_healing()

	healing = healing + skill:get_caster().level * skill:get_healing_level_plus()

	return healing, monster_base.damage_level.HEAL
end

monster_base.get_final_skill_damage = function(self, skill)
	local damage = skill:get_damage()
	local caster = skill:get_caster()

	damage = damage + caster.level * skill:get_damage_level_plus()

	local defense
	if caster:is_physical() then
		defense = self:get_cur_physical_defense() - caster:get_cur_defense_penetration()
	else
		defense = self:get_cur_magic_defense() - caster:get_cur_defense_penetration()
	end

	damage = damage * (1 - defense / (defense + 10))

	damage = damage + (math.random() - 0.5) * 20

	if damage < 1 then
		damage = 1
	end

	return math.floor(damage), monster_base.damage_level.SKILL
end

monster_base.add_hp = function(self, healing, htype)
	local hp = self._cur_hp + healing

	local max_hp = self:get_cur_max_hp()
	if hp > max_hp then
		hp = max_hp
	end

	local cb = function()
		self.blood_bar.updae_hp(hp / self._max_hp, healing, htype)
	end
	local callback = cc.CallFunc:create(handler(self, cb))
	self:do_something_later(callback, 0.3)
	self:set_hp(hp)
end

monster_base.minus_hp = function(self, damage, damage_type, is_buff_or_skill)
	local hp = self._cur_hp - damage

	local cb = function()
		self.blood_bar.updae_hp(hp / self._max_hp , damage , damage_type)
		if hp < 1 then
			self:die()
		end
	end
	if not is_buff_or_skill then
		local callback = cc.CallFunc:create(handler(self, cb))
		self:do_something_later(callback, 0.5)
	else
		self.blood_bar.updae_hp(hp / self._max_hp, damage, damage_type)
		if hp < 1 then
			self:die(is_buff_or_skill)
		end
	end

	self:set_hp(hp)

	if hp > 0 then
		return true
	else
		return false
	end
end

monster_base.set_hp = function(self, hp)
	if hp < 0 then
		hp = 0
	end
	local max_hp = self:get_cur_max_hp()
	if hp > max_hp then
		hp = max_hp
	end
	self._cur_hp = hp
end

monster_base.add_anger = function(self, num)
	if self._cur_anger > self._max_anger - 1 then 
		return
	end
	num = num or 1

	self:set_anger(self._cur_anger + num)
end

monster_base.minus_anger = function(self, num)
	self:set_anger(self._cur_anger - num)
end

monster_base.set_anger = function(self, angle)
	self._cur_anger = angle

	local cb = function()
		self.card.update(self._cur_anger)
		self.blood_bar.update_anger(self._cur_anger)
	end
	local callback = cc.CallFunc:create(handler(self, cb))

	self:do_something_later(callback, 0.5)
end
----------------------------buffÏà¹Ø----------------------------------
----------------------------buffÏà¹Ø----------------------------------
----------------------------buffÏà¹Ø----------------------------------
monster_base.add_buff = function(self, buff_list)
	for k, v in pairs(buff_list) do
		local buff = v:clone()
		buff.affect_round = 0
		buff.begin(self)
		table.insert(self._buff_list, buff)
	end
end

monster_base.add_debuff = function(self, debuff_list)
	for k, v in pairs(debuff_list) do
		local buff = v:clone()
		buff.affect_round = 0
		buff.begin(self)
		table.insert(self._debuff_list, buff)
	end
end

monster_base.deal_with_all_buff = function(self)
	for k, v in pairs(self._buff_list) do
		if v.affect_round < v.round then
			v.affect_round = v.affect_round + 1
			v.once_a_round(self)
		else
			v.finish(self)
			table.remove(self._buff_list, k)
		end
	end

	for k, v in pairs(self._debuff_list) do
		if v.affect_round < v.round then
			v.affect_round = v.affect_round + 1
			v.once_a_round(self)
		else
			v.finish(self)
			table.remove(self._debuff_list, k)
		end
	end
end

----------------------------¹¥»÷ ¼¼ÄÜ¸¨Öú----------------------------------
----------------------------¹¥»÷ ¼¼ÄÜ¸¨Öú----------------------------------
----------------------------¹¥»÷ ¼¼ÄÜ¸¨Öú----------------------------------

monster_base.move_and_attack = function(self, target)
	local num = gtool:ccp_2_int(target._cur_pos)
	local pos = gtool:int_2_ccp(self:get_back_first_near_pos_num(num, target._cur_towards))

	self:move_to(pos, target)
end

monster_base.move_and_use_skill = function(self, target_pos_num)
	local pos = gtool:int_2_ccp(self:get_near_pos_num(target_pos_num))

	self:move_to(pos, nil, target_pos_num)
end

monster_base.move_follow_path = function(self, arena_pos, callback_final)
	local num = gtool:ccp_2_int(arena_pos)
	local path = self:get_path_to_pos(num)
	self._steps = self._steps - #path
	
	local ac_table  = {}
	local next_pos

	for i = #path, 1, -1 do
		local pos = pve_game_ctrl:instance():get_position_by_int(path[i])
		
		if self:is_fly() then
			pos.y = pos.y + 10
		else
			pos.y = pos.y - 10
		end
		
		local action = self.node:runAction(cc.MoveTo:create(0.5, pos))
		self.node:stopAction(action)
		
		local cb = function()
			self:toward_to_int_pos(path[i], path[i - 1])
		end
		local callback = cc.CallFunc:create(handler(self, cb))
		local seq = cc.Sequence:create(action, callback)
		table.insert(ac_table, seq)
	end
	
	table.insert(ac_table, callback_final)

	local all_seq = cc.Sequence:create(unpack(ac_table))
	self:toward_to_int_pos(self:get_cur_pos_num(), path[#path])
	self.node:runAction(all_seq)
end

monster_base.get_distance_to_pos = function(self, num, update)
	if update then
		self._distance_info = self:get_distance_info()
	end
	return self._distance_info[num]
end

monster_base.get_distance_info = function(self)
	local distanc_table = {}
    local temp_list = {}
    
    local path_find_help = function(num, step)
        if not distanc_table[num] and gtool:is_legal_pos_num(num) then
            distanc_table[num] = step
        end
    end
    
    local find_gezi = function(pos, step)
        path_find_help(pos + 10, step)
        path_find_help(pos - 10, step)
        path_find_help(pos + 1, step)
        path_find_help(pos - 1, step)
        if pos % 2 == 0 then
            path_find_help(pos + 11,step)
            path_find_help(pos + 9,step)
        else
            path_find_help(pos - 11,step)
            path_find_help(pos - 9,step)
        end
    end

    find_gezi(self:get_cur_pos_num(), 1)
    for k, v in pairs(distanc_table) do
        table.insert(temp_list, k)
    end

	local steps = math.abs(self._cur_pos.x - 4) + math.abs(self._cur_pos.y - 4) + 4
	if steps > 8 then 
		steps = 8 
	end

    for i = 2, steps do
        for _, v in pairs(temp_list) do
            find_gezi(v, i)      
        end
        temp_list = {}

        for k, v in pairs(distanc_table) do
            table.insert(temp_list, k)
        end
    end

    return distanc_table
end

monster_base.create_attack_particle = function(self, target)
	local particle = cc.ParticleSystemQuad:create(self._attack_particle)
	particle:setScale(0.3)
	particle:setName("attack")
	local start_pos = pve_game_ctrl:instance():get_position_by_int(self:get_cur_pos_num())
	particle:setPosition(start_pos.x, start_pos.y)
	local node = pve_game_ctrl:instance():get_map_top_arena_node()
	node:addChild(particle)
	local end_pos = pve_game_ctrl:instance():get_position_by_int(target:get_cur_pos_num())
	local ac1 = particle:runAction(cc.MoveTo:create(0.5,cc.p(start_pos.x, start_pos.y + 30)))
	particle:stopAction(ac1)
	local ac2 = particle:runAction(cc.MoveTo:create(0.3,cc.p(end_pos.x, end_pos.y + 15)))
	particle:stopAction(ac2)
	local seq = cc.Sequence:create(ac1, ac2)
	particle:runAction(seq)
end
----------------------------ÒÆ¶¯¸¨Öú----------------------------------
----------------------------ÒÆ¶¯¸¨Öú----------------------------------
----------------------------ÒÆ¶¯¸¨Öú----------------------------------

monster_base.get_around_info = function(self, is_to_show)
	local steps = self._steps
	if is_to_show then
		if steps < 1 and not self:has_waited() then
			steps = self:get_cur_mobility()
		end
	end

	local map_info = pve_game_ctrl:instance():get_map_info()
	self._can_reach_area_info = {}

	if steps > 0 then
		
		self._can_reach_area_info = self:get_can_reach_area_info(self:get_cur_pos_num(), map_info, steps)

		if self:is_fly() then
			self._fly_path = self:get_fly_path()
		end

		for k, v in pairs(map_info) do
			if type(v) == type({}) and v:get_team_side() == self._team_side then
				self._can_reach_area_info[k] = pve_game_ctrl.map_item.FRIEND
			end
		end
	end

	local can_attack_table = {}
	for k, v in pairs(map_info) do
		if type(v) == type({}) and v:get_team_side() ~= self._team_side then
			if self:can_reach_and_attack(k) then
				table.insert(can_attack_table, k)
			else
				self._can_reach_area_info[k] = nil
			end
		else 
			self._can_reach_area_info[k] = nil
		end
	end

	self._distance_info = self:get_distance_info()
	
	for k, v in pairs(can_attack_table) do
		self._can_reach_area_info[v] = pve_game_ctrl.map_item.ENEMY * 100 + self:get_distance_to_pos(v)
	end
	
	self._can_reach_area_info[0] = self._cur_pos
	return self._can_reach_area_info
end

monster_base.get_can_reach_area_info = function(self, center_pos_num, map_info, steps)
    local area_table = {}
    local temp_list = {}
    
    local path_find_help = function(pos, num)
        if not area_table[num] and gtool:is_legal_pos_num(num) and ((not map_info[num]) or self:is_fly()) then
            area_table[num] = pos
        end
    end

    gtool:find_gezi(center_pos_num, path_find_help)
    for k, v in pairs(area_table) do
        table.insert(temp_list, k)
    end

    for i = 2, steps do
        for _, v in pairs(temp_list) do

            gtool:find_gezi(v, path_find_help)
            
        end
        temp_list = {}

        for k, v in pairs(area_table) do
            table.insert(temp_list, k)
        end
    end

    return area_table
end

monster_base.get_fly_path = function(self)
    local fly_path = {}
    local temp_list = {}
    
    local path_find_help = function(pos, num)
        if not fly_path[num] and gtool:is_legal_pos_num(num) then
            fly_path[num] = pos
        end
    end

    gtool:find_gezi(self:get_cur_pos_num(), path_find_help)
    for k, v in pairs(fly_path) do
        table.insert(temp_list, k)
    end

	local steps = math.abs(self._cur_pos.x - 4) + math.abs(self._cur_pos.y - 4) + 4
	if steps > 8 then 
		steps = 8 
	end

    for i = 2, steps do
        for _, v in pairs(temp_list) do
            gtool:find_gezi(v, path_find_help)    
        end
        temp_list = {}

        for k, v in pairs(fly_path) do
            table.insert(temp_list, k)
        end
    end

    return fly_path
end

monster_base.get_path_info_to_target = function(self, map_info, target)
    local area_table = {}
    local temp_list = {}
    
    local path_find_help = function(pos, num)
        if num == target then
            area_table[num] = pos
            return true
        end
        if not area_table[num] 
        	and gtool:is_legal_pos_num(num) 
        	and ((not map_info[num]) or self:is_fly()) then
            area_table[num] = pos
        end

        return false
    end
    
    local find_gezi = function(pos)
        if path_find_help(pos, pos + 10)
            or path_find_help(pos, pos - 10)
            or path_find_help(pos, pos + 1)
            or path_find_help(pos, pos - 1) then
            return true
        end
        if pos % 2 == 0 then
            if path_find_help(pos, pos + 11)
                or path_find_help(pos, pos + 9) then

                return true
            end
        else
            if path_find_help(pos, pos - 11)
                or path_find_help(pos, pos - 9) then

                return true
            end
        end

        return false
    end

    find_gezi(self:get_cur_pos_num())
    for k, v in pairs(area_table) do
        table.insert(temp_list, k)
    end

    local last_list_size = #temp_list

    for i = 2, 20 do
        for _, v in pairs(temp_list) do
            if find_gezi(v) then
                return area_table
            end
        end
        temp_list = {}

       	for k, v in pairs(area_table) do
       	    table.insert(temp_list, k)
       	end
       	if last_list_size == #temp_list then
       		return area_table
       	end
    end

    return area_table
end

monster_base.get_path_to_pos = function(self, num, path_table)
	path_table = path_table or {}
	table.insert(path_table, num)
	local last_geizi
	if self:is_fly() then 
		last_geizi = self._fly_path[num]
	else
		last_geizi = self._can_reach_area_info[num]
	end

	if self:get_cur_pos_num() == last_geizi then
		return path_table
	else
		return self:get_path_to_pos(last_geizi, path_table)
	end
end

monster_base.get_near_pos_num = function(self, num)

	if num % 2 == 0 then
		if self:can_move_to_pos_num(num + 10) then
			return num + 10
		elseif self:can_move_to_pos_num(num - 10) then
			return num - 10
		elseif self:can_move_to_pos_num(num + 1) then
			return num + 1
		elseif self:can_move_to_pos_num(num - 1) then
			return num - 1
		elseif self:can_move_to_pos_num(num + 11) then
			return num + 11
		elseif self:can_move_to_pos_num(num + 9) then
			return num + 9
		end
	else
		if self:can_move_to_pos_num(num + 10) then
			return num + 10
		elseif self:can_move_to_pos_num(num - 10) then
			return num - 10
		elseif self:can_move_to_pos_num(num + 1) then
			return num + 1
		elseif self:can_move_to_pos_num(num - 1) then
			return num - 1
		elseif self:can_move_to_pos_num(num - 11) then
			return num - 11
		elseif self:can_move_to_pos_num(num - 9) then
			return num - 9
		end
	end

	return false
end

----------------------------¸¨ÖúÅÐ¶Ï----------------------------------
----------------------------¸¨ÖúÅÐ¶Ï----------------------------------
----------------------------¸¨ÖúÅÐ¶Ï----------------------------------
monster_base.nothing_can_do = function(self)
	if pve_game_ctrl:instance():get_auto() then
		return true
	end
	if not self:is_melee() then
		return false
	else
		self:get_around_info()
		
		local count = 0
		for k, v in pairs(self._can_reach_area_info) do
		    count = count + 1
		    if count > 1 then
		    	return false
		    end
		end
		return true
	end
end

monster_base.can_reach_and_attack = function(self, num)
	if self:can_attack() then
		if self:is_near(num) or not self:is_melee() then
			return true
		end
	
		return self:get_near_pos_num(num)
	else
		return false
	end
end

monster_base.is_near = function(self, num)
	local cur = self:get_cur_pos_num()
	if num % 2 == 0 then
		if cur == num + 10
			or cur == num - 10
			or cur == num + 1
			or cur == num - 1
			or cur == num + 11
			or cur == num + 9 then
			
			return true
		end
	else
		if cur == num + 10
			or cur == num - 10
			or cur == num + 1
			or cur == num - 1
			or cur == num - 11
			or cur == num - 9 then
			
			return true
		end
	end

	return false
end

monster_base.can_move_to_pos_num = function(self, num)
	return self._can_reach_area_info[num] and self._can_reach_area_info[num] > 10 and 100 > self._can_reach_area_info[num]
end
----------------------------×´Ì¬¶¯×÷----------------------------------
----------------------------×´Ì¬¶¯×÷----------------------------------
----------------------------×´Ì¬¶¯×÷----------------------------------
monster_base.change_monster_status = function(self, status)
	status = status or self._last_status or monster_base.status.ALIVE
	self._last_status = self._status
	self._status = status
	
	if status == monster_base.status.ALIVE then
		self:repeat_animation("alive")
	elseif status == monster_base.status.DEFEND then
		self:repeat_animation("defend")
	elseif status == monster_base.status.WAITING then
		self:do_animation("wait")
	end
end

monster_base.add_monster_status = function(self, status)
	self._last_status = self._status
	self._status = self._status + status
end

monster_base.remove_monster_status = function(self, status)
	self._last_status = self._status
	self._status = self._status - status

	if self._status < monster_base.status.CANT_ATTACK then
		self:repeat_animation("alive")
	end
end

monster_base.go_back_repeat_animate = function(self)
	if self._status == monster_base.status.ALIVE then
		self:repeat_animation("alive")
	elseif self._status == monster_base.status.DEFEND then
		self:repeat_animation("defend")
	else
		self:repeat_animation("alive")
	end
end

monster_base.repeat_animation = function(self, name)
	if g_config.monster_animate[self:get_id()][name] then
    	local animate = g_config.monster_animate[self:get_id()][name](self.animation)
		self.model:stopAllActions()
        self.model:runAction(cc.RepeatForever:create(animate))

        return true
    end

    return false
end

monster_base.do_animation = function(self, name, cb)
	if g_config.monster_animate[self:get_id()][name] then
    	local animate = g_config.monster_animate[self:get_id()][name](self.animation)
		local callback = cc.CallFunc:create(handler(self, self.go_back_repeat_animate))
		self.model:stopAllActions()
		local seq
		if self:is_dead() then
			seq = cc.Sequence:create(animate, cb)
        else
        	seq = cc.Sequence:create(animate, callback, cb)
        end
        self.model:runAction(seq)
    elseif cb then
    	self:do_something_later(cb, 1)
    end
end

monster_base.do_something_later = function(self, callback, time)
	local ac_node = cc.Node:create()
    pve_game_ctrl:instance():get_action_node():addChild(ac_node)
    local default_ac = ac_node:runAction(cc.ScaleTo:create(time, 1))
    local seq = cc.Sequence:create(default_ac, callback)
    ac_node:runAction(seq)
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
--------------------------AI------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

monster_base.run_ai = function(self)
	local enemy_list = self:get_alive_enemy_monsters()

	self._can_reach_area_info = self:get_around_info()
	
	local target_enemy = self:get_enemy_can_attack(enemy_list)
	
	if target_enemy then
		local pos_num = gtool:ccp_2_int(target_enemy._cur_pos)
		local distance = self:get_distance_to_pos(pos_num)
		if self:can_use_skill() then
			return self:use_skill(target_enemy:get_cur_pos_num())
		end
		if self:is_melee() then
			self:move_and_attack(target_enemy)
		else
			if distance < 6 and distance > 2 then
				self:attack(target_enemy, distance)
			else
				local pos = self:get_good_pos_to_attack(target_enemy, distance)
				if pos then
					self:move_to(pos, target_enemy)
				else
					self:attack(target_enemy, distance)
				end
			end
		end

	else
		local map_info = pve_game_ctrl:instance():get_map_info()
		self:move_close_to_lowest_hp_enemy(enemy_list, map_info)
	end
end

monster_base.get_enemy_can_attack = function(self, enemy_list)
	local can_attack_list = {}
	for k, v in pairs(enemy_list) do
		if self:can_reach_and_attack(gtool:ccp_2_int(v._cur_pos)) then
			table.insert(can_attack_list, v)
		end
	end
	
	return self:get_lowest_hp_enemy(can_attack_list)
end

monster_base.get_lowest_hp_enemy = function(self, enemy_list)
	local sort_by_hp = function(a, b)
		return a:get_cur_hp() < b:get_cur_hp()
	end

	if #enemy_list>2 then
		table.sort(enemy_list,sort_by_hp)
	end
	
	return enemy_list[1]
end

monster_base.move_close_to_lowest_hp_enemy = function(self, enemy_list, map_info)
	local enemy = self:get_lowest_hp_enemy(enemy_list)

	if not enemy then
		return
	end
	local pos_num = gtool:ccp_2_int(enemy._cur_pos)

	local all_path = self:get_path_info_to_target(map_info,pos_num)

	local path
	if all_path[pos_num] then
		path = self:get_path_to_pos_plus(pos_num, all_path)
	end

	if path then
		local index
		for i, v in ipairs(path) do
			if self._can_reach_area_info[v] 
				and self._can_reach_area_info[v] < 100 
				and self._can_reach_area_info[v] > 10 then

				index = i
				break

			end
		end
		
		self:move_to(gtool:int_2_ccp(path[index]))
	else
		self:wait(true)
	end
end

monster_base.get_good_pos_to_attack = function(self, enemy, distance)
	local enemy_direction = self:toward_to_int_pos(self:get_cur_pos_num(), enemy:get_cur_pos_num(), true)
	local pos_num
	if distance < 3 then
		pos_num = self:get_pos_num_by_direction_and_steps(self:get_cur_pos_num(),enemy_direction + 3, 2)
	else
		pos_num = self:get_pos_num_by_direction_and_steps(self:get_cur_pos_num(),enemy_direction,distance - 5)
	end

	if self:can_move_to_pos_num(pos_num) then
		return gtool:int_2_ccp(pos_num)
	else
		return nil
	end
end

monster_base.get_pos_num_by_direction_and_steps = function(self, pos, towards, steps)
	if steps < 1 then
		return pos
	end
	local temp_table
	if pos % 2 == 0 then
		temp_table = {
			[1] = pos + 10,
			[2] = pos + 9,
			[3] = pos - 1,
			[4] = pos - 10,
			[5] = pos + 1,
			[6] = pos + 11,
		}
	else
		temp_table = {
			[1] = pos + 10,
			[2] = pos - 1,
			[3] = pos - 11,
			[4] = pos - 10,
			[5] = pos - 9,
			[6] = pos + 1,
		}
	end

	towards = gtool:normalize_towards(towards)
	if steps == 1 then
		return temp_table[towards]
	else
		return self:get_pos_num_by_direction_and_steps(temp_table[towards], towards, steps - 1)
	end
end

monster_base.get_path_to_pos_plus = function(self, num, all_path, path_table)
	path_table = path_table or {}
	table.insert(path_table, num)
	local last_geizi
	if self:is_fly() then 
		last_geizi = self._fly_path[num]
	else
		last_geizi = all_path[num]
	end

	if self:get_cur_pos_num() == last_geizi then
		return path_table
	else
		return self:get_path_to_pos_plus(last_geizi, all_path, path_table)
	end
end

monster_base.get_back_first_near_pos_num = function(self, num, target_toward)
	local help = function (a)
		return self:can_move_to_pos_num(a) or a == self:get_cur_pos_num()
	end

	local temp_table
	if num % 2 == 0 then
		temp_table = {
			[1] = num + 10,
			[2] = num + 9,
			[3] = num - 1,
			[4] = num - 10,
			[5] = num + 1,
			[6] = num + 11,
		}
	else
		temp_table = {
			[1] = num + 10,
			[2] = num - 1,
			[3] = num - 11,
			[4] = num - 10,
			[5] = num - 9,
			[6] = num + 1,
		}
	end

	local first_toward = gtool:normalize_towards(target_toward - 3)

	if help(temp_table[first_toward]) then
		return temp_table[first_toward]
	end
	
	local next_first

	for i = 1, 2 do
		next_first = gtool:normalize_towards(first_toward - i)
		if help(temp_table[next_first]) then
			return temp_table[next_first]
		end
		next_first = gtool:normalize_towards(first_toward + i)
		
		if help(temp_table[next_first]) then
			return temp_table[next_first]
		end
	end

	if help(temp_table[target_toward]) then
		return temp_table[target_toward]
	end
end

return monster_base