pve_game_ctrl = pve_game_ctrl or {}

pve_game_ctrl.map_item = {
	EMPTY			= 0,
	BARRIER			= 2,
	ENEMY			= 3,
	LEFT_MONSTER 	= 1,
	RIGHT_MONSTER 	= 4,
	FRIEND			= 5,
}

pve_game_ctrl.game_status = {
	ACTIVE 			= 0,
	RUNNING			= 1,
	WAIT_ORDER		= 2,
	OVER 			= 3,
	AUTO 			= 4,
}

pve_game_ctrl.order = {
	ACTIVATE	= 0,
	MOVE 		= 1,
	ATTACK 		= 2,
	DEFEND		= 3,
	WAIT 		= 4,
	USE_SKILL	= 5,
}

pve_game_ctrl.OPERATE = {
	[0] = function(is_wait, round_num)
		if pve_game_ctrl:Instance().scene.battle_info_view:isInited() then
			pve_game_ctrl:Instance().scene:updateBattleQueue(is_wait)
		end
		pve_game_ctrl:Instance().cur_active_monster:on_active(round_num)
	end,

	[1] = function(arena_pos)
		pve_game_ctrl:Instance().cur_active_monster:move_to(arena_pos)
	end,

	[2] = function(target,distance)
		pve_game_ctrl:Instance().cur_active_monster:attack(target,distance)
	end,

	[3] = function()
		pve_game_ctrl:Instance().cur_active_monster:defend()
	end,

	[4] = function()
		pve_game_ctrl:Instance().cur_active_monster:wait()
	end,

	[5] = function(target_pos_num)
		pve_game_ctrl:Instance().cur_active_monster:use_skill(target_pos_num)
	end,
}

pve_game_ctrl.new = function(self)
	local o = {}
	setmetatable(o,self)
	self.__index = self
	
	self.left_team = {}
	self.right_team = {}
	self.wait_list = {}
	self.all_monsters = {}
	self.map_info = {}
	self.cur_round_monster_queue = {}
	self.next_round_monster_queue = {}
	return o
end
 
pve_game_ctrl.instance = function(self)
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

pve_game_ctrl.init_game = function(self, left_team,right_team,map,chapter_num,level_num)
	self.game_speed = 1
	self.is_use_skill = false
	self.map = map
	self.chapter_num = chapter_num
	self.level_num = level_num

	self.left_team = {}
	for k,v in pairs(left_team) do
		table.insert(self.left_team,v)
	end
	self.right_team = {}
	for k,v in pairs(right_team) do
		table.insert(self.right_team,v)
	end

	self:sort_all_monsters_by_initiative()
	self.cur_round_monster_queue = self:get_all_monsters()
end

pve_game_ctrl.start_game = function(self)
	self.is_auto = false
	self.cur_round_num = 1
	self.cur_active_monster_index = 1
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_active_monster_index]
	self.cur_game_status = pve_game_ctrl.game_status.ACTIVE
	self:update_map_info()
	self:run_game(pve_game_ctrl.order.ACTIVATE)
end

pve_game_ctrl.run_game = function(self, order, param1, param2)
	local action = pve_game_ctrl.OPERATE[order]
	action(param1,param2)
end

pve_game_ctrl.game_over = function(self, win_side)
	self:set_game_status(pve_game_ctrl.game_status.OVER)
	local result = self:get_game_result(win_side)
	self.scene:game_over(result)
	if win_side == 1 then
		local table = self:get_left_alive_monsters()
		for k,v in pairs(table) do
			v:repeatAnimation("victory")
		end
	else
		local table = self:get_right_alive_monsters()
		for k,v in pairs(table) do
			v:repeatAnimation("victory")
		end
	end
end

pve_game_ctrl.next_monster_activate = function(self, is_wait)
	self:set_is_use_skill(false)
	if is_wait then
		table.insert(self.cur_round_monster_queue,self.cur_active_monster)
		table.insert(self.next_round_monster_queue,self.cur_active_monster)
	end
	if not self.cur_active_monster:has_waited() then
		table.insert(self.next_round_monster_queue,self.cur_active_monster)
	end
	self.cur_active_monster = self:get_next_monster()

	if not self.cur_active_monster then
		self:start_next_round()
	elseif self.cur_active_monster:is_dead() then
		self:next_monster_activate()
	else
		self:run_game(pve_game_ctrl.order.ACTIVATE,is_wait)
	end
end

pve_game_ctrl.start_next_round = function(self)
	print("round "..self.cur_round_num.."finish")
	self.cur_round_num = self.cur_round_num + 1
	self.cur_active_monster_index = 1
	self.cur_round_monster_queue = self.next_round_monster_queue
	self.next_round_monster_queue = {}
	
	self:alive_monster_enter_new_round()
	
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_active_monster_index]
	while self.cur_active_monster:is_dead() do
		self.cur_active_monster = self:get_next_monster()
	end
	self.cur_game_status = pve_game_ctrl.game_status.ACTIVE
	self:update_map_info()
	self:run_game(pve_game_ctrl.order.ACTIVATE)
end

pve_game_ctrl.alive_monster_enter_new_round = function(self)
	local all_alive_monster = self:get_all_alive_monsters()
	for k,v in pairs(all_alive_monster) do
		v:on_enter_new_round(self.cur_round_num)
	end
end

pve_game_ctrl.update_map_info = function(self)
	self.map_info = {}

	for k,v in pairs(self.map) do
		table.insert(self.map_info,k,v)
	end
	
	local monsters = self:get_all_alive_monsters()
	for k,v in pairs(monsters) do
		self.map_info[gtool:ccp_2_int(v.cur_pos)] = v
	end
end

pve_game_ctrl.change_game_status = function(self, status)
	self.cur_game_status = status
	self:update_map_info()
	self.scene:updateMapView()
end

pve_game_ctrl.select_pos = function(self, node)
	if self.map_info[gtool:ccp_2_int(node.arena_pos)] then
		uitool:createTopTip("you can't do that!")
	else
		self:run_game(pve_game_ctrl.order.MOVE, node.arena_pos)
	end
end

pve_game_ctrl.select_target = function(self, num, distance)
	if self.map_info[num] and self.map_info[num]:is_monster() then
		if not self:get_is_use_skill() then
			self:run_game(pve_game_ctrl.order.ATTACK, self.map_info[num],distance)
		else
			self:run_game(pve_game_ctrl.order.USE_SKILL, num)
			self:set_is_use_skill(false)
		end
	end
end

pve_game_ctrl.request_defend = function(self)
	self:run_game(pve_game_ctrl.order.DEFEND)
end

pve_game_ctrl.request_wait = function(self)
	self:run_game(pve_game_ctrl.order.WAIT)

end

pve_game_ctrl.request_auto = function(self)
	self:set_auto(true)
	if self:get_game_status() == pve_game_ctrl.game_status.WAIT_ORDER then
		self.cur_active_monster:runAI()
	end
	self:set_game_status(pve_game_ctrl.game_status.AUTO)
end

pve_game_ctrl.stop_auto = function(self)
	self:set_auto(false)
end

pve_game_ctrl.check_game_over = function(self, is_buff)
	local right = self:get_right_alive_monsters()
	local left = self:get_left_alive_monsters()
	
	if #right < 1 then
		self:game_over(1)
	elseif #left < 1 then
		self:game_over(4)
	elseif not is_buff then
		self:next_monster_activate()
	end

end

pve_game_ctrl.set_is_use_skill = function(self, is_use_skill)
	self.is_use_skill = is_use_skill
end

pve_game_ctrl.set_scene = function(self, scene)
	self.action_node = cc.Node:create()
	self.scene = scene
	self.scene:addChild(self.action_node)
end

pve_game_ctrl.get_scene = function(self, scene)
	return self.scene
end

pve_game_ctrl.get_game_result = function(self, win_side)
	local result = {}
	local star_num = 0

	if win_side == 1 then
		star_num = star_num + 1
		if self.cur_round_num < 6 then
			star_num = star_num + 1
		end
		if self:get_dead_monster_num() < 1 then
			star_num = star_num + 1
		end
	end

	result.star_num = star_num 

	result.chapter_num = self.chapter_num
	result.level_num = self.level_num

	return result
end

pve_game_ctrl.get_dead_monster_num = function(self)
	local num = 0

	for k,v in pairs(self.left_team) do
		if v:is_dead() then
			num = num + 1
		end
	end

	return num
end

pve_game_ctrl.get_next_monster = function(self)
	self.cur_active_monster_index = self.cur_active_monster_index + 1
	return self.cur_round_monster_queue[self.cur_active_monster_index]
end

pve_game_ctrl.get_is_use_skill = function(self)
	return self.is_use_skill
end

pve_game_ctrl.set_auto = function(self, is_auto)
	self.is_auto = is_auto
end

pve_game_ctrl.get_auto = function(self)
	return self.is_auto
end

pve_game_ctrl.get_map = function(self)
	return self.map
end

pve_game_ctrl.get_map_info = function(self)
	self:update_map_info()
	return self.map_info
end

pve_game_ctrl.get_action_node = function(self)
	return self.action_node
end

pve_game_ctrl.set_game_status = function(self, status)
	self.cur_game_status = status
end

pve_game_ctrl.get_game_status = function(self)
	return self.cur_game_status
end

pve_game_ctrl.set_game_speed = function(self, speed)
	self.game_speed = speed
end

pve_game_ctrl.get_game_speed = function(self)
	return self.game_speed
end

pve_game_ctrl.get_cur_round_num = function(self)
	return self.cur_round_num
end

pve_game_ctrl.get_cur_active_monster_index = function(self)
	return self.cur_active_monster_index
end

pve_game_ctrl.get_cur_active_monster = function(self)
	return self.cur_active_monster
end

pve_game_ctrl.get_cur_round_monster_queue = function(self)
	return self.cur_round_monster_queue
end

pve_game_ctrl.get_next_round_monster_queue = function(self)
	return self.next_round_monster_queue
end

pve_game_ctrl.get_cur_chapter_and_level = function(self)
	return self.chapter_num,self.level_num
end

pve_game_ctrl.is_wait_order = function(self)
	return self.cur_game_status == pve_game_ctrl.game_status.WAIT_ORDER
end

pve_game_ctrl.is_game_over = function(self)
	return self.cur_game_status == pve_game_ctrl.game_status.OVER
end

pve_game_ctrl.get_all_monsters = function(self)
	local all = {}
	
	for _,v in pairs(self.left_team) do
		table.insert(all,v)
	end

	for _,v in pairs(self.right_team) do
		table.insert(all,v)
	end

	return all
end


pve_game_ctrl.get_all_alive_monsters = function(self)
	local all = {}
	
	for _,v in pairs(self.left_team) do
		if not v:is_dead() then
			table.insert(all,v)
		end
	end

	for _,v in pairs(self.right_team) do
		if not v:is_dead() then
			table.insert(all,v)
		end
	end

	return all
end

pve_game_ctrl.get_left_alive_monsters = function(self)
	local all = {}
	
	for _,v in pairs(self.left_team) do
		if not v:is_dead() then
			table.insert(all,v)
		end
	end

	return all
end

pve_game_ctrl.get_right_alive_monsters = function(self)
	local all = {}
	
	for _,v in pairs(self.right_team) do
		if not v:is_dead() then
			table.insert(all,v)
		end
	end

	return all
end

pve_game_ctrl.sort_all_monsters_by_initiative = function(self)
	local sort_by_initiative = function(a,b)
		if a.initiative == b.initiative then
			if a.level == b.level then
				return a.rarity > b.rarity
			else
				return a.level > b.level
			end
		else
			return a.initiative > b.initiative
		end
	end

	table.sort(self.all_monsters,sort_by_initiative)
end

pve_game_ctrl.sort_monsters_by_initiative = function(self, list)
	local sort_by_initiative = function(a,b)
		if a.initiative == b.initiative then
			if a.level == b.level then
				return a.rarity > b.rarity
			else
				return a.level > b.level
			end
		else
			return a.initiative > b.initiative
		end
	end

	table.sort(list,sort_by_initiative)
end

pve_game_ctrl.get_all_alive_monsters_in_next_round_queue = function(self)
	local list = {}
	
	for _,v in pairs(self.next_round_monster_queue) do
		if not v:is_dead() then
			table.insert(list,v)
		end
	end

	return list
end

pve_game_ctrl.get_all_alive_monsters_in_cur_round_queue = function(self)
	local list = {}
	
	for _,v in pairs(self.cur_round_monster_queue) do
		if not v:is_dead() then
			table.insert(list,v)
		end
	end

	return list
end

pve_game_ctrl.get_monster_index_in_next_round_alive_monster = function(self, monster)
	local next_round_alive_monsters = self:get_all_alive_monsters_in_next_round_queue()
	local index = 1
	--self:sort_monsters_by_initiative(next_round_alive_monsters)
	for i,v in ipairs(next_round_alive_monsters) do
		if v:getTag() == monster:getTag() then
			index = i 
			break
		end
	end

	return index
end

pve_game_ctrl.get_monster_index_in_cur_round_alive_monster = function(self, monster)
	local cur_round_alive_monsters = self:get_all_alive_monsters_in_cur_round_queue()
	local index = 1
	--self:sort_monsters_by_initiative(cur_round_alive_monsters)
	for i,v in ipairs(cur_round_alive_monsters) do
		if v:getTag() == monster:getTag() then
			index = i 
			break
		end
	end

	return index
end

pve_game_ctrl.get_position_by_int = function(self, num)
	return self.scene.map_view:get_position_by_int(num)
end

pve_game_ctrl.get_map_top_arena_node = function(self)
	return self.scene.map_view.arena_top_node
end

pve_game_ctrl.clear_team = function(self)
	self.left_team = {}

	self.right_team = {}

end