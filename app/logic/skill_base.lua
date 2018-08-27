local skill_base = {}

skill_base.instance = function(self)
	return setmetatable({}, { __index = self })
end

skill_base.new = function(self, monster, skill_data)
	self._caster 				= monster
	self._name 					= skill_data.name 		
	self._description 			= skill_data.description 
	self._img_path				= skill_data.img_path
	self._range 				= skill_data.range
	self._is_need_target		= skill_data.is_need_target
	self._cost 					= skill_data.cost 
	self._damage 				= skill_data.damage
	self._damage_level_plus 	= skill_data.damage_level_plus
	self._healing				= skill_data.healing
	self._healing_level_plus	= skill_data.healing_level_plus
	self._particle_path 		= skill_data.particle_path
	self._particle_pos			= skill_data.particle_pos
	self._particle_scale		= skill_data.particle_scale
	self._particle_delay_time 	= skill_data.particle_delay_time
	self._buff					= skill_data.buff
	self._debuff				= skill_data.debuff

	return self
end

skill_base.use = function(self, target_pos_num)
	self.target_pos_num = target_pos_num
	
	if (not target_pos_num) and (not self._is_need_target) or self._range < 1 then
		self.target_pos_num = self._caster:get_cur_pos_num()
	elseif (not target_pos_num) and self._is_need_target then 
		uitool:create_top_tip(self._name.." need a target pos !")
		return
	end
	local monster_list = self:get_be_affected_monster_list()
	
	if #monster_list < 1 then
		uitool:create_top_tip("no monster is affected by " .. self._name)
		pve_game_ctrl:instance():next_monster_activate()
	else
		for i, v in ipairs(monster_list) do
			if not monster_list[i + 1] then
				v:be_affected_by_skill(self, true)
			else
				v:be_affected_by_skill(self)
			end
		end
	end

end

skill_base.play = function(self)
	if not self._particle_path then 
		return
	end

	local cb = function()
		local particle = cc.ParticleSystemQuad:create(self._particle_path)
		particle:setName(self._name)
		if self._particle_scale then
			particle:setScale(self._particle_scale)
		end
		particle:setGlobalZOrder(uitool:mid_z_order())
		particle:setPosition(self._particle_pos)
		if self._range < 1 then
			pve_game_ctrl:instance():get_scene():get_particle_node():addChild(particle)
		else
			local map_info = pve_game_ctrl:instance():get_map_info()
			map_info[self._caster:get_cur_pos_num()].node:addChild(particle)
		end
	end

	if self._particle_delay_time then
		local callback = cc.CallFunc:create(cb)
		gtool:do_something_later(callback, self._particle_delay_time)
	else
		cb()
	end
		

end

skill_base.get_be_affected_monster_list = function(self)
	local monster_list = {}
	if self._range < 1 then
		if (self._damage > 0 or self._debuff) and (self._healing > 0 or self._buff) then
			monster_list = pve_game_ctrl:instance():get_all_alive_monsters()
		elseif self._damage > 0 or self._debuff then
			monster_list = self._caster:get_alive_enemy_monsters()
		elseif self._healing > 0 or self._buff then
			monster_list = self._caster:get_alive_friend_monsters()
		end
	elseif (not self:is_need_target()) and self._range > 1 then
		local pos_list = gtool:get_pos_list_in_range(self._caster:get_cur_pos_num(), self._range)
		local map_info = pve_game_ctrl:instance():get_map_info()
		for k, v in pairs(pos_list) do
			if map_info[k] and type(map_info[k]) == type({}) and self._caster:is_enemy(map_info[k]) then
				table.insert(monster_list, map_info[k])
			end
		end
	elseif self.target_pos_num and self._range > 1 then
		local pos_list = gtool:get_pos_list_in_range(self.target_pos_num, self._range)
		local map_info = pve_game_ctrl:instance():get_map_info()
		for k, v in pairs(pos_list) do
			if map_info[k] and type(map_info[k]) == type({}) and self._caster:is_enemy(map_info[k]) then
				table.insert(monster_list, map_info[k])
			end
		end
	elseif self._range == 1 then
		local map_info = pve_game_ctrl:instance():get_map_info()
		table.insert(monster_list, map_info[self.target_pos_num])
	end

	return monster_list
end

skill_base.is_need_target = function(self)
	return self._is_need_target
end

skill_base.get_img_path = function(self)
	return self._img_path
end

skill_base.get_cost = function(self)
	return self._cost
end

skill_base.get_name = function(self)
	return self._name
end

skill_base.get_caster = function(self)
	return self._caster
end

skill_base.get_damage_level_plus = function(self)
	return self._damage_level_plus
end

skill_base.get_damage = function(self)
	return self._damage
end

skill_base.get_healing_level_plus = function(self)
	return self._healing_level_plus
end

skill_base.get_healing = function(self)
	return self._healing
end

skill_base.get_buff = function(self)
	return self._buff
end

skill_base.get_debuff = function(self)
	return self._debuff
end

skill_base.get_description = function(self)
	return self._description
end

return skill_base