action_ctrl = {}
 
action_ctrl.instance = function(self)
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

action_ctrl.new = function(self)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	self._package = {}
	self._final_call_back = nil

	return o
end

action_ctrl.reset_package = function(self)
	self._package = {}
end

action_ctrl.get_package = function(self)
	return self._package
end

action_ctrl.add_param_in_package = function(self, key, value)
	self._package[key] = value
end


action_ctrl.play = function(self)
	pve_game_ctrl:instance():change_game_status(pve_game_ctrl.GAME_STATUS.RUNNING)
	self:set_final_call_back()
	if self._package.end_pos then
		self:move(self._package.monster, self._package.start_pos, self._package.end_pos, self._package.attack_target, self._package.skill_target_pos)
	elseif self._package.atk_dmg then
		self:attack_directly(self._package.monster, self._package.attack_target)
	end
end

action_ctrl.set_final_call_back = function(self)
	local callback = function()
		pve_game_ctrl:instance():next_monster_activate()
	end
	if self._package.callback then
		callback = self._package.callback
	end

	self._final_call_back = function()
		self:reset_package()
		callback()
	end

end

action_ctrl.move = function(self, monster, start_pos, end_pos, attack_target, skill_target_pos)
	local cb = function()
		if attack_target then
			self:attack_directly(monster, attack_target)
		elseif skill_target_pos then
			monster:use_skill(skill_target_pos)
		else
			monster:change_monster_status(g_config.monster_status.ALIVE)
			if not monster:nothing_can_do() then
				pve_game_ctrl:instance():change_game_status(pve_game_ctrl.GAME_STATUS.WAIT_ORDER)
			else
				self._final_call_back()
			end
		end
	end
	local callback = cc.CallFunc:create(cb)

	if start_pos == end_pos or not end_pos then
		cb()
	else
		monster:repeat_animation("walk")
		self:move_follow_path(monster, start_pos, end_pos, callback)
	end
end

action_ctrl.move_follow_path = function(self, monster, start_pos, end_pos, callback_final)
	local path = self._package.follow_path or monster:get_path_to_pos(end_pos, start_pos)
	
	local ac_table  = {}
	local next_pos

	for i = #path, 1, -1 do
		local pos = pve_game_ctrl:instance():get_position_by_int(path[i])
		
		if monster:is_fly() then
			pos.y = pos.y + 10
		else
			pos.y = pos.y - 10
		end
		
		local action = monster.node:runAction(cc.MoveTo:create(0.5, pos))
		monster.node:stopAction(action)
		
		local cb = function()
			self:toward_to_int_pos(monster, path[i], path[i - 1])
		end
		local callback = cc.CallFunc:create(cb)
		local seq = cc.Sequence:create(action, callback)
		table.insert(ac_table, seq)
	end
	
	table.insert(ac_table, callback_final)

	local all_seq = cc.Sequence:create(unpack(ac_table))
	self:toward_to_int_pos(monster, start_pos, path[#path])
	monster.node:runAction(all_seq)
end

action_ctrl.attack_directly = function(self, monster, target)
	
	if monster:get_attack_particle() then
		self:create_attack_particle(monster, target)
	end

	local cb = function()
		monster.card.update(monster:get_cur_anger())
		monster.blood_bar.update_anger(monster:get_cur_anger())
	end
	local callback = cc.CallFunc:create(cb)

	gtool:do_something_later(callback, 0.5)

	self:toward_to_int_pos(monster, monster:get_cur_pos_num(), target:get_cur_pos_num())
	monster:do_animation("attack1")
	self:be_attacked(target, monster, false)
end

action_ctrl.be_attacked = function(self, monster, murderer, is_counter_attack)
	local damage, damage_type
	if is_counter_attack then
		damage, damage_type = self._package.atk_dmg, self._package.atk_dmg_type
	else
		damage, damage_type = self._package.c_atk_dmg, g_config.damage_level.COMMON
	end

	self:update_hp(monster, is_counter_attack)

	if not monster:is_dead() then
		local cb = function()
			monster.card.update(monster:get_cur_anger())
			monster.blood_bar.update_anger(monster:get_cur_anger())
			self:toward_to_int_pos(monster, monster:get_cur_pos_num(), murderer:get_cur_pos_num())
			if self._package.c_atk_dmg and not is_counter_attack then
				self:counter_attack(monster ,murderer)
			else
				self._final_call_back()
			end
		end
		local callback = cc.CallFunc:create(handler(self, cb))
		monster:do_animation("beattacked", callback)
	else
		local cb = function()
			self:die(monster)
		end
		local callback = cc.CallFunc:create(cb) 
		gtool:do_something_later(callback, 0.5)
	end
end

action_ctrl.counter_attack = function(self, monster, target)
	local cur_num = monster:get_cur_pos_num()
	local to_num = target:get_cur_pos_num()
	self:toward_to_int_pos(monster, cur_num, to_num)
	monster:do_animation("attack1")
	self:be_attacked(target, monster, true)
end

action_ctrl.use_skill_directly = function(self, target_pos_num)
	self._skill:play()
	local cost = self._skill:get_cost()
	self:minus_anger(cost)
	
	local cb = function()
		self._skill:use(target_pos_num)
	end
	local callback = cc.CallFunc:create(cb)
	self:toward_to_int_pos(monster, self._cur_pos_num, target_pos_num)
	self:do_animation("skill", callback)
end

action_ctrl.die = function(self, monster)
	local ac = monster.model:runAction(cc.FadeOut:create(1))
	local cb = function()
		monster.node:setVisible(false)
		monster.card.remove_self()
		self._final_call_back()
	end

	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac, callback)
	monster:do_animation("die", seq)
end

action_ctrl.create_attack_particle = function(self, monster, target)
	local particle = cc.ParticleSystemQuad:create(monster:get_attack_particle())
	particle:setScale(0.3)
	particle:setName("attack")
	local start_pos = pve_game_ctrl:instance():get_position_by_int(monster:get_cur_pos_num())
	particle:setPosition(start_pos.x, start_pos.y)
	local node = pve_game_ctrl:instance():get_map_top_arena_node()
	node:addChild(particle)
	local end_pos = pve_game_ctrl:instance():get_position_by_int(target:get_cur_pos_num())
	local ac1 = particle:runAction(cc.MoveTo:create(0.5, cc.p(start_pos.x, start_pos.y + 30)))
	particle:stopAction(ac1)
	local ac2 = particle:runAction(cc.MoveTo:create(0.3, cc.p(end_pos.x, end_pos.y + 15)))
	particle:stopAction(ac2)
	local seq = cc.Sequence:create(ac1, ac2)
	particle:runAction(seq)
end

action_ctrl.update_hp = function(self, monster)
	local damage, damage_type
	if is_counter_attack then
		damage, damage_type = self._package.c_atk_dmg, g_config.damage_level.COMMON
	else
		damage, damage_type = self._package.atk_dmg, self._package.atk_dmg_type
	end

	local cb = function()
		monster.blood_bar.update_hp(monster:get_cur_hp() / monster:get_cur_max_hp() , damage , damage_type)
	end
	local callback = cc.CallFunc:create(handler(self, cb))
	gtool:do_something_later(callback, 0.5)
end

action_ctrl.toward_to = function(self, monster, num)
	if num then 
		monster.model:setRotation3D(cc.vec3(0, (1 - num) * 60, 0))
	end
end

action_ctrl.toward_to_int_pos = function(self, monster, cur_num, to_num)
	
	result_towards = gtool:get_toward_to_int_pos(cur_num, to_num)

	self:toward_to(monster, result_towards)
end