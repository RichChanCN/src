range_monster_class = gtool.class(monster_class)

range_monster_class.is_melee = function(self)
	return false
end

range_monster_class.can_counter_attack = function(self, murderer)
	return false
end

range_monster_class.attack = function(self, target, distance)

	self:attack_directly(target, distance)
end

range_monster_class.use_skill = function(self, target_pos_num)
	self:use_skill_directly(target_pos_num)
end

range_monster_class.nothing_can_do = function(self)
	if pve_game_ctrl:instance():get_auto() then
		return true
	end

	return false
end

range_monster_class.can_reach_and_attack = function(self, num)
	if self:can_attack() then
		return true
	else
		return false
	end
end

range_monster_class.ai_attack = function(self, target_enemy, distance)
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