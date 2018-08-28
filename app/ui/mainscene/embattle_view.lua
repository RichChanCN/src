local view = require("packages.mvc.view_base")

local embattle_view = view:instance()

embattle_view.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["arena_node"]			= {["varname"] = "arena_node"},
    ["monster_lv"]			= {["varname"] = "monster_lv"},
    ["template_panel"]		= {["varname"] = "template_panel"},
    ["hex_node"]			= {["varname"] = "hex_node"},
    ["select_num_text"]		= {["varname"] = "select_num_text"},
    ["fight_img"]           = {["varname"] = "fight_img"},
}
----------------------------------------------------------------
-------------------------------公有方法--------------------------
----------------------------------------------------------------
embattle_view.init_ui = function(self)
	self:init_arena()
end

embattle_view.init_arena = function(self)
	for x = 1, 8 do
		for y = 1, 7 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			local geizi_key = "gezi_" .. x .. "_" .. y
			self[geizi_key] = self.arena_node:getChildByName(geizi_key)
			if self[geizi_key] then
				self[geizi_key].pos = cc.p(x, y)
			end
		end
	end

	self.highlight_border_sp = self.arena_node:getChildByName("highlight_border_sp")
	self.selected_sp = self.arena_node:getChildByName("selected_sp")
end

embattle_view.init_info = function(self)
	self._enable_gezi = {}
	self._other_gezi = {}
end

embattle_view.update_info = function(self, map_data)
	self._chapter_num = map_data.chapter_num
	self._level_num = map_data.level_num
	--上场怪物数量限制
	self._monster_num_limit = map_data.monster_num_limit
	--可以使用的怪物信息
	self._can_use_monster_list = map_data.can_use_monster_list or game_data_ctrl:instance():get_collected_monster_list()
	--竞技场的布局信息
	self._enable_gezi = map_data.enable_gezi
	self._other_gezi = map_data.other_gezi
	--敌人的队伍信息
	self._enemy_team = map_data.enemy_team
	--当前抓住的棋子
	self._cur_drag_chesspiece = nil
	--对准的放置节点
	self._target_node = nil
	--棋子是否来源于竞技场
	self._is_chesspiece_from_arena = false
	--牌池的有边缘
	self._pool_right_boder = -460
	--已经上场的怪物列表
	self._monster_team = {}
	--当前添加了事件监听器的卡片列表   优化使用
	self._card_list = {}
	--当前的队伍大小
	self._team_size = 0
	--将要在下次被清理掉的棋子节点   这里是因为有个动画效果，所以延迟清理
	self._chesspiece_willbe_removed = nil
end

embattle_view.init_events = function(self)
	self:add_arena_listener()
	self.back_btn:addClickEventListener(function(sender)
        self._ctrl:close_embattle_view()
    end)

    uitool:make_img_to_button(self.fight_img, function()
    	if self._team_size < 1 then
    		uitool:create_top_tip("you should select 1 monster at least!", "red")
    		return
    	end
    	local left_team = self:make_team()
    	pve_game_ctrl:instance():init_game(left_team, self._enemy_team, self._other_gezi, self._chapter_num, self._level_num)
        self._ctrl:go_to_fight_scene()
    end)
end

embattle_view.update_view = function(self, map_data)
		self:update_info(map_data)
		self:update_arena()
		self:init_events()
		self:init_monster_lv()
		self:updateMonstersNum()
		self.is_updated = true 
end

embattle_view.updateMonstersNum = function(self)
	self.select_num_text:setString("MonsterSelect (" .. self._team_size .. "/" .. self._monster_num_limit .. ")")
end

embattle_view.on_open = function(self, ...)
	local params = {...}
	local chapter_num = params[1]
	local level_num = params[2]

	if chapter_num and level_num then
		local map_data = game_data_ctrl:instance():get_map_data_by_chapter_and_level(chapter_num, level_num)
		self:reset_arena()
		self.monster_lv:removeAllItems()
		self.hex_node:removeAllChildren()
		self:update_view(map_data)
	end
	if self.is_updated then
		self:resume_monster_list_listener()
		self:resume_arena_listener()
	end
end

embattle_view.on_close = function(self)
	self:remove_arena_listener()
	self:remove_monster_list_listener()
	self:put_all_chesspiece()
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------
embattle_view.make_team = function(self)
	local team = {}

	for _, v in pairs(self._monster_team) do
		local monster = monster_factory:instance():create_monster(v.monster, g_config.team_side.LEFT, v.arena_cell.pos)
		table.insert(team, monster)
	end

	return team
end
------------左边卡池部分开始------------
embattle_view.init_monster_lv = function(self)
	local monsters_num = #self._can_use_monster_list
	local mod_num = monsters_num % 3
	local rows_num = monsters_num / 3

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local item = self.template_panel:clone()
		self:init_lv_item(item, i - 1) --这里-1是为了里面好计算正真的索引值
		self.monster_lv:pushBackCustomItem(item)
	end
end

embattle_view.init_lv_item = function(self, item, index)
	for i = 1, 3 do
		local cur_index = i + 3 * index
		local cur_monster = {}
		local monster_img_key = "monster_" .. i .. "_img"
		if self._can_use_monster_list[cur_index] then
			cur_monster.head_img = item:getChildByName(monster_img_key)
			cur_monster.head_img:loadTexture(self._can_use_monster_list[cur_index].char_img_path)
			cur_monster.border_img = cur_monster.head_img:getChildByName("border_img")
			cur_monster.border_img:loadTexture(g_config.sprite["card_border_" .. self._can_use_monster_list[cur_index].rarity])
			cur_monster.type_img = cur_monster.head_img:getChildByName("type_img")
			cur_monster.type_img:loadTexture(g_config.sprite["attack_type_" .. self._can_use_monster_list[cur_index].attack_type])
			self:add_monster_card_event(cur_monster.head_img, cur_index)
			table.insert(self._card_list, cur_monster.head_img)
		else
			cur_monster.head_img = item:getChildByName(monster_img_key)
			cur_monster.head_img:setVisible(false)
		end
	end
end

embattle_view.add_monster_card_event = function(self, img, index)
	   
	local touch_began = function(touch, event)
        local node = event:getCurrentTarget()
        local locationInNode = node:convertToNodeSpace(touch:getLocation())
        local s = node:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            node:setScale(1.06)
            return true
        end

        return false
    end

    local touch_moved = function(touch, event)
        local node = event:getCurrentTarget()
		local cur_pos = self.hex_node:convertToNodeSpace(touch:getLocation())
		local start_pos = self.hex_node:convertToNodeSpace(touch:getStartLocation())

		if math.abs(cur_pos.y - start_pos.y) < 50 
			and math.abs(cur_pos.x - start_pos.x) > 50 
			and not self._cur_drag_chesspiece then

			self._is_chesspiece_from_arena = false
			self._cur_drag_chesspiece = self:create_chesspiece(self._can_use_monster_list[index], index)
			node.listener:setSwallowTouches(true)
		end

		if self._cur_drag_chesspiece then
			self._cur_drag_chesspiece:setPosition(cc.p(cur_pos.x, cur_pos.y))
		end

        if uitool:is_touch_in_node_rect(node, touch, event) then
            node:setScale(1.06)
        else
            node:setScale(1.0)
        end
    end

    local touch_ended = function(touch, event)
        local node = event:getCurrentTarget()
		local pos = self.hex_node:convertToNodeSpace(touch:getStartLocation())
        
        if self._cur_drag_chesspiece and not self._target_node then
			uitool:move_to_and_fade_out(self._cur_drag_chesspiece, pos)
			self:set_chesspiece_will_remove(self._cur_drag_chesspiece)
		elseif self._target_node then
			if self._target_node.chesspiece then
				self:remove_one_chesspiece_from_arena(self._target_node.chesspiece)
				self:add_draged_chesspiece_to_arena(true, node)
				self:select_card(node)
			else
				if self._team_size < self._monster_num_limit then
					self:add_draged_chesspiece_to_arena(true, node)
					self:select_card(node)
					self._target_node = nil
				else
					uitool:create_top_tip("can't add more monsters!", "red")
					uitool:move_to_and_fade_out(self._cur_drag_chesspiece, pos)
					self:set_chesspiece_will_remove(self._cur_drag_chesspiece)
				end
			end
		end

        if uitool:is_touch_in_node_rect(node, touch, event) then
            node:setScale(1.0)
        end

        if not self._is_chesspiece_from_arena then
			self._cur_drag_chesspiece = nil
		end

		node.listener:setSwallowTouches(false)
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:registerScriptHandler(touch_began, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touch_moved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touch_ended, cc.Handler.EVENT_TOUCH_ENDED)
    
    self._event_dispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

embattle_view.select_card = function(self, card)
	self._event_dispatcher:pauseEventListenersForTarget(card)
	local selected_sp = cc.Sprite:create(g_config.sprite.selected)
	selected_sp:setName("selected_sp")
	selected_sp:setScale(1.5)
	card:addChild(selected_sp, uitool.top_z_order)
	card.selected = true
	selected_sp:setPosition(uitool:get_node_center_position(card))
end

embattle_view.unselect_card = function(self, card)
	self._event_dispatcher:resumeEventListenersForTarget(card)

	if card:getChildByName("selected_sp") then
		card:removeChildByName("selected_sp")
	end
end

embattle_view.resume_monster_list_listener = function(self)
	for _, v in pairs(self._card_list) do
		if not v.selected then
			self._event_dispatcher:resumeEventListenersForTarget(v)
		end
	end
end

embattle_view.pause_monster_list_listener = function(self)
	for _, v in pairs(self._card_list) do
		if not v.selected then
			self._event_dispatcher:pauseEventListenersForTarget(v)
		end
	end
end


embattle_view.remove_monster_list_listener = function(self)
	for _, v in pairs(self._card_list) do
		if not v.selected then
			self._event_dispatcher:removeEventListenersForTarget(v)
		end
	end
end
------------左边卡池部分结束------------

------------棋子部分开始------------
embattle_view.create_chesspiece = function(self, monster, index)

	local chesspiece = chesspiece_pool_manager:instance():get(monster, index)

	self.hex_node:addChild(chesspiece, uitool.bottom_z_order)

	return chesspiece
end

embattle_view.set_chesspiece_will_remove = function(self, chesspiece)
	if self._chesspiece_willbe_removed then
		chesspiece_pool_manager:instance():put(self._chesspiece_willbe_removed)
	end
	self._chesspiece_willbe_removed = chesspiece
end

embattle_view.select_hex_effect = function(self, pos)
	self.highlight_border_sp:setPosition(pos)
	self.selected_sp:setPosition(pos)
	self.selected_sp:runAction(cc.FadeOut:create(3))
end

embattle_view.put_in_hex_effect = function(self)
	local ac1 = self.highlight_border_sp:runAction(cc.ScaleTo:create(1.0, 0.8))
    local ac2 = self.highlight_border_sp:runAction(cc.FadeOut:create(1.0))
	local callback  = cc.CallFunc:create(handler(self, self.reset_select_hex_effect))

	local seq = cc.Sequence:create(ac1, ac2, callback)
	self.highlight_border_sp:runAction(seq)
end

embattle_view.reset_select_hex_effect = function(self)
	self.highlight_border_sp:cleanup()
	self.selected_sp:cleanup()
	self.highlight_border_sp:setPosition(uitool.far_away_ccp)
	self.highlight_border_sp:setOpacity(255)
	self.highlight_border_sp:setScaleX(0.55)
	self.highlight_border_sp:setScaleY(0.6)
	self.selected_sp:setPosition(uitool.far_away_ccp)
	self.selected_sp:setOpacity(255)
end

embattle_view.add_draged_chesspiece_to_arena = function(self, add_to_team, card)
	self:put_in_hex_effect()

	if card then
		self._cur_drag_chesspiece.from_card = card
	end

	self._target_node.chesspiece = self._cur_drag_chesspiece
	self._cur_drag_chesspiece:setPosition(self._target_node:getPosition())
	self._cur_drag_chesspiece:setLocalZOrder(uitool.bottom_z_order)
	self._cur_drag_chesspiece.arena_cell = self._target_node
	if add_to_team then
		table.insert(self._monster_team, self._cur_drag_chesspiece)
		self._team_size = self._team_size + 1 
		self:updateMonstersNum()
	end
end

embattle_view.exchange_draged_and_target_chesspiece = function(self)
	self:put_in_hex_effect()

	self._cur_drag_chesspiece:setLocalZOrder(uitool.bottom_z_order)

	local temp_cell = self._cur_drag_chesspiece.arena_cell
	self._cur_drag_chesspiece.arena_cell = self._target_node
	self._target_node.chesspiece.arena_cell = temp_cell

	local temp_chesspiece = self._cur_drag_chesspiece
	temp_cell.chesspiece = self._target_node.chesspiece
	self._target_node.chesspiece = temp_chesspiece

	temp_cell.chesspiece:setPosition(temp_cell:getPosition())
	self._target_node.chesspiece:setPosition(self._target_node:getPosition())

end

embattle_view.remove_one_chesspiece_from_arena = function(self, chesspiece)
	for k, v in pairs(self._monster_team) do
		if v:getName() == chesspiece:getName() then
			table.remove(self._monster_team, k)
		end
	end
	self._team_size = self._team_size - 1 

	if chesspiece.arena_cell then
		chesspiece.arena_cell.chesspiece = nil
		chesspiece.arena_cell = nil
	end
	
	if chesspiece.from_card then
		self:unselect_card(chesspiece.from_card)
	end

	chesspiece_pool_manager:instance():put(chesspiece)

	self:updateMonstersNum()
end
------------棋子部分结束------------

------------右边战场部分开始------------

embattle_view.update_arena = function(self)

	for k, v in pairs(self._enable_gezi) do
		local pos = gtool:int_2_ccp(k)
		local gezi_wid = self:get_gezi_wid_by_pos(pos)
		gezi_wid:loadTexture(g_config.sprite.gezi_enable)
		gezi_wid:setScaleX(0.9)
		gezi_wid:setScaleY(0.8)
	end

	for k, v in pairs(self._other_gezi) do
		if v == 2 then 
			local pos = gtool:int_2_ccp(k)
		local gezi_wid = self:get_gezi_wid_by_pos(pos)
			gezi_wid:loadTexture(g_config.sprite.gezi_barrier)
			gezi_wid:setScale(0.8)
		end
	end

	for k, v in pairs(self._enemy_team) do
		local chesspiece = self:create_chesspiece(v, 300 + v:get_id())
		local pos = v:get_start_pos()
		local gezi_key = "gezi_" .. pos.x .. "_" .. pos.y
		chesspiece:setPosition(self[gezi_key]:getPosition())
	end

end

embattle_view.add_arena_listener = function(self)

	local touch_began = function(touch, event)
		local node = event:getCurrentTarget()
		if uitool:is_touch_in_node_rect(node, touch, event ,0.8) then
			if node.chesspiece then
				self._cur_drag_chesspiece = node.chesspiece
				self._cur_drag_chesspiece:setLocalZOrder(uitool.top_z_order)
				self._is_chesspiece_from_arena = true
			end
		end

		return true
	end

	local touch_moved = function(touch, event)
		local node = event:getCurrentTarget()
		local x, y = node:getPosition()
		local cur_pos = self.hex_node:convertToNodeSpace(touch:getLocation())

		if self._is_chesspiece_from_arena and self._cur_drag_chesspiece then
			self._cur_drag_chesspiece:setPosition(cc.p(cur_pos.x, cur_pos.y))
		end

		if self._cur_drag_chesspiece and uitool:is_touch_in_node_rect(node, touch, event, 0.8) then
			self:select_hex_effect(cc.p(x, y))
			self._target_node = node
		elseif self._target_node and self._target_node:getTag() == node:getTag() then
			self:reset_select_hex_effect()
			self._target_node = nil
		end
	end

	local touch_ended = function(touch, event)
		local node = event:getCurrentTarget()
		local cur_pos = self.hex_node:convertToNodeSpace(touch:getLocation())

        if self._is_chesspiece_from_arena then
        	if self._cur_drag_chesspiece and not self._target_node then
				if self._cur_drag_chesspiece.arena_cell and cur_pos.x < self._pool_right_boder then
					self:remove_one_chesspiece_from_arena(self._cur_drag_chesspiece)
				else
					self._cur_drag_chesspiece:setPosition(self._cur_drag_chesspiece.arena_cell:getPosition())
					self._cur_drag_chesspiece:setLocalZOrder(uitool.bottom_z_order)
				end
			elseif self._cur_drag_chesspiece and self._target_node then
				--判断如果该位置已经有棋子，那么就交换
				if self._cur_drag_chesspiece and self._target_node.chesspiece then
					self:exchange_draged_and_target_chesspiece()
				elseif self._cur_drag_chesspiece then
					self._cur_drag_chesspiece.arena_cell.chesspiece = nil
					self:add_draged_chesspiece_to_arena()
				end
				self._target_node = nil
			elseif self._cur_drag_chesspiece and self._cur_drag_chesspiece.arena_cell then
				if cur_pos.x < self._pool_right_boder then
					self:remove_one_chesspiece_from_arena(self._cur_drag_chesspiece)
				elseif node:getTag() == self._target_node:getTag() then
					self._cur_drag_chesspiece:setPosition(self._cur_drag_chesspiece.arena_cell:getPosition())
					self._cur_drag_chesspiece:setLocalZOrder(uitool.bottom_z_order)
				end
			end
			self._cur_drag_chesspiece = nil
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(touch_began, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(touch_moved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(touch_ended, cc.Handler.EVENT_TOUCH_ENDED)
	
	
	--注意！！！如果一个界面监听的事件很多会导致降帧！
	for k, v in pairs(self._enable_gezi) do
		local pos = gtool:int_2_ccp(k)
		local gezi_wid = self:get_gezi_wid_by_pos(pos)
		gezi_wid.listener = listener:clone()
		self._event_dispatcher:addEventListenerWithSceneGraphPriority(gezi_wid.listener, gezi_wid)
	end

	self:pause_arena_listener()
end

embattle_view.resume_arena_listener = function(self)
	for k, v in pairs(self._enable_gezi) do
		local pos = gtool:int_2_ccp(k)
		self._event_dispatcher:resumeEventListenersForTarget(self["gezi_" .. pos.x .. "_" .. pos.y])
	end
end

embattle_view.pause_arena_listener = function(self)
	for k, v in pairs(self._enable_gezi) do
		local pos = gtool:int_2_ccp(k)
		self._event_dispatcher:pauseEventListenersForTarget(self["gezi_" .. pos.x .. "_" .. pos.y])
	end
end

embattle_view.remove_arena_listener = function(self)
	for k, v in pairs(self._enable_gezi) do
		local pos = gtool:int_2_ccp(k)
		self._event_dispatcher:removeEventListener(self["gezi_" .. pos.x .. "_" .. pos.y].listener)
	end
end

embattle_view.reset_arena = function(self)
	for k, v in pairs(self._enable_gezi) do
		local pos = gtool:int_2_ccp(k)
		local gezi_wid = self:get_gezi_wid_by_pos(pos)
		gezi_wid.chesspiece = nil
		gezi_wid:loadTexture(g_config.sprite.gezi_disable)
		gezi_wid:setScale(1)
	end

	for k, v in pairs(self._other_gezi) do
		local pos = gtool:int_2_ccp(k)
		local gezi_wid = self:get_gezi_wid_by_pos(pos)
		gezi_wid:loadTexture(g_config.sprite.gezi_disable)
		gezi_wid:setScale(1)
	end
end

embattle_view.put_all_chesspiece = function(self)
	chesspiece_pool_manager:recycle_all()
end

embattle_view.get_gezi_wid_by_pos = function(self, pos)
	return self["gezi_" .. pos.x .. "_" .. pos.y]
end
------------右边战场部分结束------------


return embattle_view