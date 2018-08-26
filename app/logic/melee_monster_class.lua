melee_monster_class = gtool.class(monster_class)

melee_monster_class.is_melee = function(self)
	return true
end

melee_monster_class.can_counter_attack = function(self, murderer)
	return self:can_attack()
			and murderer:is_melee() 
			and self:is_near(gtool:ccp_2_int(murderer._cur_pos)) 
			and not(self:is_be_side_attacked(murderer) or self:is_be_back_attacked(murderer))
end

melee_monster_class.attack = function(self, target, distance)	
	if not self:is_near(gtool:ccp_2_int(target._cur_pos)) then
		self:move_and_attack(target)
	else
		self:attack_directly(target, distance)
	end
end

melee_monster_class.use_skill = function(self, target_pos_num)
	if (not self._skill:is_need_target()) 
		or self:is_near(target_pos_num) then

		self:use_skill_directly(target_pos_num)
	else
		self:move_and_use_skill(target_pos_num)
	end
end

melee_monster_class.nothing_can_do = function(self)
	if pve_game_ctrl:instance():get_auto() then
		return true
	end
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

melee_monster_class.can_reach_and_attack = function(self, num)
	if self:can_attack() then
		if self:is_near(num) then
			return true
		end
	
		return self:get_near_pos_num(num)
	else
		return false
	end
end

melee_monster_class.ai_attack = function(self, target_enemy, distance)
	self:move_and_attack(target_enemy)
end