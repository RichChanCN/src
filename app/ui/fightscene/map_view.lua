local view = require("packages.mvc.view_base")

local map_view = view:instance()

map_view.RESOURCE_BINDING = 
{
    ["map_img"]				= {["varname"] = "map_img"},
    ["arena_show_node"]		= {["varname"] = "arena_show_node"},
    ["arena_bottom_node"]	= {["varname"] = "arena_bottom_node"},
    ["arena_event_node"]	= {["varname"] = "arena_event_node"},
    ["model_panel"]			= {["varname"] = "model_panel"},
    ["arena_top_node"]		= {["varname"] = "arena_top_node"},
    ["mask_img"]			= {["varname"] = "mask_img"},
    ["blood_template"]		= {["varname"] = "blood_template"},
    ["fly_word_template"]	= {["varname"] = "fly_word_template"},
    ["pre_panel"]			= {["varname"] = "pre_panel"},
    ["logo_node"]			= {["varname"] = "logo_node"},
}

map_view.init_ui = function(self)
	self:init_pre_panel()
	self:init_arena()
	self:init_arena_bottom_node()
end

map_view.init_pre_panel = function(self)
	self.shield_img 	= self.logo_node:getChildByName("shield_img")
	self.sword_img	 	= self.logo_node:getChildByName("sword_img")
	self.em_img 		= self.logo_node:getChildByName("em_img")
	self.ts_img 		= self.logo_node:getChildByName("ts_img")
	self.word_img 		= self.logo_node:getChildByName("word_img")
end

map_view.init_arena = function(self)
	for x = 1, 8 do
		for y = 1, 7 do
			local gezi_key = "gezi_" .. x .. "_" .. y
			self[gezi_key] = self.arena_event_node:getChildByName(gezi_key)
			self[gezi_key .. "_black"] = self.arena_bottom_node:getChildByName(gezi_key)
			if self[gezi_key] then
				self[gezi_key].arena_pos = cc.p(x, y)
                self:add_arena_listener(self[gezi_key])
			end
		end
	end
end

map_view.init_arena_bottom_node = function(self)
	self.moveto_point_sp 		= self.arena_bottom_node:getChildByName("moveto_point_sp")
	self.cur_monster_pos_sp 	= self.arena_bottom_node:getChildByName("cur_monster_pos_sp")
	self.far_attack_img 		= self.arena_bottom_node:getChildByName("far_attack_img")
	self.too_far_attack_img 	= self.arena_bottom_node:getChildByName("too_far_attack_img")
	self.close_attack_img 		= self.arena_bottom_node:getChildByName("close_attack_img")
end

map_view.init_info = function(self)
	self._monster_model_list = {}
	self._model_node_list = {}
	self._monster_loaded_num = 0
	self._skew_angle = 60
	self.arena_event_node:setRotation3D(cc.vec3(self._skew_angle, 0, 0))
	self.arena_show_node:setRotation3D(cc.vec3(self._skew_angle, 0, 0))
	self.arena_bottom_node:setRotation3D(cc.vec3(self._skew_angle, 0, 0))
	self.arena_top_node:setRotation3D(cc.vec3(self._skew_angle, 0, 0))
	self.model_panel:setRotation3D(cc.vec3(self._skew_angle, 0, 0))
    self._camera = self._ctrl:getScene():getDefaultCamera()
end

map_view.init_events = function(self)
	self:pause_arena_listener()
end

map_view.update_view = function(self)
	if pve_game_ctrl:instance():is_wait_order() then
		self:show_guide()
	else
		self:hide_guide()
	end
end

map_view.beginAnimation = function(self)
	self:play_enter_animation()
	self:cameraAnimation()
end

map_view.cameraAnimation = function(self)
	local ac1 = self._root:runAction(cc.ScaleTo:create(self._ctrl.WAIT_TIME + 3, 0.75))
	local ac2 = self._root:runAction(cc.ScaleTo:create(self._ctrl.ACTION_TIME, 1))
	local callback = cc.CallFunc:create(handler(self._ctrl, self._ctrl.start_game))

	local seq = cc.Sequence:create(ac1, ac2, callback)
		
	self:show_mask()
	self._root:runAction(seq)
end

map_view.endAnimation = function(self)
	self:hide_guide()
	local ac1 = self._root:runAction(cc.ScaleTo:create(self._ctrl.WAIT_TIME, 1))
	local ac2 = self._root:runAction(cc.ScaleTo:create(self._ctrl.ACTION_TIME, 0.75))
	local callback = cc.CallFunc:create(handler(self._ctrl, self._ctrl.open_result_view))

	local seq = cc.Sequence:create(ac1, ac2, callback)
		
	self._root:runAction(seq)
	self:hide_mask()
end

map_view.get_position_by_int = function(self, num)
	local pos = gtool:int_2_ccp(num)
	local a, b = self["gezi_" .. pos.x .. "_" .. pos.y]:getPosition()
	return cc.p(a, b)
end

map_view.show_other_around_info = function(self, monster)
	self:hide_guide()
	self:show_guide(monster)
end

map_view.hide_other_around_info = function(self)
	self:hide_guide()
	self:show_guide()
end

map_view.show_guide = function(self, monster)
	local cur_active_monster = monster or pve_game_ctrl:instance():get_cur_active_monster()
	
	local gezi_list = cur_active_monster:get_around_info(monster)

	local a, b = self["gezi_" .. gezi_list[0].x .. "_" .. gezi_list[0].y .. "_black"]:getPosition()
	self.cur_monster_pos_sp:setPosition(cc.p(a, b))
	
	for k, v in pairs(gezi_list) do
		if k > 10 and v < 100 and v > 10 then
			self:show_can_move_to_gezi(k)
		elseif k > 10 and v > 100 then
			if math.floor(v / 100) == pve_game_ctrl.MAP_ITEM.ENEMY then
				self:show_enemy(k, monster, v % 100)
			end
		end
    end
end

map_view.show_enemy = function(self, num, monster, distance)
	local cur_active_monster = monster or pve_game_ctrl:instance():get_cur_active_monster()
	local atk_img
	
	if cur_active_monster:is_melee() then
		atk_img = self.close_attack_img:clone()
	elseif distance > 5 or distance < 3 then
		atk_img = self.too_far_attack_img:clone()
	else
		atk_img = self.far_attack_img:clone()
	end

	local x, y = math.modf(num / 10), num % 10
	local px, py = self["gezi_" .. x .. "_" .. y]:getPosition()
	atk_img:setPosition(px, py)

	self.arena_top_node:addChild(atk_img)
	uitool:repeat_fade_in_and_out(atk_img)

	local img = atk_img:getChildByName("img")
	uitool:make_img_to_button_ht(img, self._camera, function()
		pve_game_ctrl:instance():select_target(num, distance)
	end)
end

map_view.show_can_move_to_gezi = function(self, num)
	local x, y = math.modf(num / 10), num % 10
	local gezi_key = "gezi_" .. x .. "_" .. y .. "_black"
	if self[gezi_key] then 
		self[gezi_key]:setVisible(true)
		self[gezi_key]:setScale(0.1)
		local time = math.random() / 3 + 0.1
		self[gezi_key]:runAction(cc.FadeIn:create(time))
		self[gezi_key]:runAction(cc.ScaleTo:create(time, 1))
		self._event_dispatcher:resumeEventListenersForTarget(self["gezi_" .. x .. "_" .. y])
	end
end

map_view.hide_guide = function(self)
	self.arena_top_node:removeAllChildren()
	self.cur_monster_pos_sp:setPosition(uitool.far_away_ccp)
    for x = 1, 8 do
    	for y = 1, 7 do
    		local gezi_key = "gezi_" .. x .. "_" .. y .. "_black"
    		if self[gezi_key] then 
    			self[gezi_key]:setOpacity(0)
    			self[gezi_key]:setVisible(false)
    			self._event_dispatcher:pauseEventListenersForTarget(self[gezi_key])
    		end
    	end
    end
end

map_view.show_mask = function(self)
	local ac1 = self.mask_img:runAction(cc.FadeOut:create(self._ctrl.WAIT_TIME + 3))
	local ac2 = self.mask_img:runAction(cc.FadeIn:create(self._ctrl.ACTION_TIME))

	local seq = cc.Sequence:create(ac1, ac2)
	
	self.mask_img:runAction(seq)
end

map_view.hide_mask = function(self)
	local ac1 = self.mask_img:runAction(cc.FadeIn:create(self._ctrl.WAIT_TIME))
	local ac2 = self.mask_img:runAction(cc.FadeOut:create(self._ctrl.ACTION_TIME))

	local seq = cc.Sequence:create(ac1, ac2)
	
	self.mask_img:runAction(seq)
end
----------------------------------------------------------------------------
map_view.create_monster_model = function(self, monster)
    if monster.model then
        self.model_panel:removeChild(monster.model)
        monster.model = nil
    end

	self._model_node_list[monster:get_tag()] = cc.Node:create()
	self._model_node_list[monster:get_tag()]:retain()

	local path = game_data_ctrl:instance():get_monster_data_by_id(monster.id).model_path
	local callback = function(model)
		model:setScale(0.5)
		local node = self._model_node_list[monster:get_tag()]
		local pos = monster:get_start_pos()
        local x, y = self["gezi_" .. pos.x .. "_" .. pos.y]:getPosition()
        if monster:is_fly() then
        	node:setPosition(x, y + 10)
        else
        	node:setPosition(x, y - 10)
        end
		node:addChild(model)
        monster.node = node
		local blood_bar = self:init_blood_bar(node, monster)
		self.model_panel:addChild(node)

		monster.model = model
		monster.animation = cc.Animation3D:create(path)
		monster:reset()

		self._monster_loaded_num = self._monster_loaded_num + 1
	end
	cc.Sprite3D:createAsync(path, callback)
    
end

map_view.create_other_model = function(self, other_model, pos)
	local callback = function(model)
		model:setScale(4)
        local x, y = self["gezi_" .. pos.x .. "_" .. pos.y]:getPosition()
        model:setPosition(x, y)
		self.model_panel:addChild(model)
	end
	if other_model == 2 then
		local chapter_num, level_num = pve_game_ctrl:instance():get_cur_chapter_and_level()
		local barrier = self._ctrl:get_map_data():get_barrier_model_by_chapter_and_level(chapter_num, level_num)
    	cc.Sprite3D:createAsync(barrier, callback)
    end
end

map_view.init_blood_bar = function(self, node, monster)
	local blood_bar = self.blood_template:clone()
	blood_bar.child = {}
	blood_bar.child.blood_img = blood_bar:getChildByName("blood_img")
	blood_bar.child.level_text = blood_bar:getChildByName("level_text")

	blood_bar.child.blood_img:loadTexture(g_config.sprite["team_hp_img_" .. monster:get_team_side()])
	blood_bar.child.level_text:setString(monster:get_level())

	local update_hp = function(percent, damage, type)
		self:create_damage_fly_words(damage, monster, type)
		uitool:set_progress_bar(blood_bar.child.blood_img, percent)
	end

	local update_anger = function(anger)
		for i = 1, 4 do
			local star_index = "star_" .. i
			if not (i > anger) then
				blood_bar:getChildByName(star_index):setVisible(true)
			else
				blood_bar:getChildByName(star_index):setVisible(false)
			end
		end
	end

	blood_bar.update_hp = update_hp
	blood_bar.update_anger = update_anger
	blood_bar:setPosition(0, 75)
	uitool:set_node_to_global_top(blood_bar)
	blood_bar:setName("blood_bar")
	monster.blood_bar = blood_bar
	node:addChild(blood_bar)
end

map_view.create_damage_fly_words = function(self, damage, monster, level)
	local fly_word = self.fly_word_template:clone()
	fly_word:setString(damage)
	fly_word:setTextColor(g_config.color["damage_" .. level])
	local x, y = monster.node:getPosition()

	fly_word:setPosition(x, y + 60)
	fly_word:setScale(0.2)
	
	self.arena_top_node:addChild(fly_word)

	local ac1 = fly_word:runAction(cc.ScaleTo:create(0.2, 1))
	fly_word:stopAction(ac1)
	local ac2 = fly_word:runAction(cc.MoveTo:create(0.5, cc.p(x, y + 80)))
	fly_word:stopAction(ac2)
	local ac3 = fly_word:runAction(cc.FadeOut:create(0.1))
	fly_word:stopAction(ac3)
	
	local seq = cc.Sequence:create(ac1, ac2, ac3)

	fly_word:runAction(seq)
end

map_view.add_arena_listener = function(self, gezi)
    local touch_began = function(touch, event)
        local node = event:getCurrentTarget()
		local start_location = touch:getLocation()
		if pve_game_ctrl:instance():is_wait_order() then
        	if node:hitTest(start_location, self._camera, nil) then
        		local x, y = node:getPosition()
        		self.moveto_point_sp:setPosition(x, y)
        		self.target_gezi = node
        	end
        	return true
        else
        	return false
        end
    end

    local touch_moved = function(touch, event)
        local node = event:getCurrentTarget()
        local cur_location = touch:getLocation()

        if node:hitTest(cur_location, self._camera, nil) then
        	local x, y = node:getPosition()
        	self.moveto_point_sp:setPosition(x, y)
        	self.target_gezi = node
        elseif self.target_gezi and self.target_gezi:getTag() == node:getTag() then
        	self.moveto_point_sp:setPosition(uitool.far_away_ccp)
            self.target_gezi = nil
        end
    end

    local touch_ended = function(touch, event)
        local node = event:getCurrentTarget()
        local cur_location = touch:getLocation()
        self.moveto_point_sp:setPosition(uitool.far_away_ccp)

        if node:hitTest(cur_location, self._camera, nil) then
            pve_game_ctrl:instance():select_pos(node)
        end
    end

    gezi.listener = cc.EventListenerTouchOneByOne:create()
    gezi.listener:registerScriptHandler(touch_began, cc.Handler.EVENT_TOUCH_BEGAN)
    gezi.listener:registerScriptHandler(touch_moved, cc.Handler.EVENT_TOUCH_MOVED)
    gezi.listener:registerScriptHandler(touch_ended, cc.Handler.EVENT_TOUCH_ENDED)
    self._event_dispatcher:addEventListenerWithSceneGraphPriority(gezi.listener, gezi)
end

map_view.resume_arena_listener = function(self)
	for x = 1, 8 do
		for y = 1, 7 do 
			local gezi_key = "gezi_" .. x .. "_" .. y
			if self[gezi_key] then
				self._event_dispatcher:resumeEventListenersForTarget(self[gezi_key])
			end
		end
	end
end

map_view.pause_arena_listener = function(self)
	
	for x = 1, 8 do
		for y = 1, 7 do 
			local gezi_key = "gezi_" .. x .. "_" .. y
			if self[gezi_key] then
				self._event_dispatcher:pauseEventListenersForTarget(self[gezi_key])
			end
		end
	end
end

map_view.release_model_node = function(self)
	for k, v in pairs(self._model_node_list) do
		v:release()
	end
end

map_view.clear_model_panel = function(self)
	self.model_panel:removeAllChildren()
end

map_view.play_enter_animation = function(self)

	self.shield_img:runAction(cc.FadeIn:create(0.5))
	local a1 = self.word_img:runAction(cc.FadeIn:create(0.5))
	local a2 = self.word_img:runAction(cc.ScaleTo:create(0.4, 1))
	local seq1 = cc.Sequence:create(a1, a2)
	self.word_img:runAction(seq1)

	local ac1 = self.sword_img:runAction(cc.ScaleTo:create(0.4, 1.2))
	self.sword_img:stopAction(ac1)
	local ac2 = self.sword_img:runAction(cc.MoveTo:create(0.3, uitool.zero_ccp))
	self.sword_img:stopAction(ac2)
	local callback = function()
		self.word_img:setVisible(true)
		self.ts_img:runAction(cc.RotateTo:create(0.4, 0))
		self.em_img:runAction(cc.RotateTo:create(0.4, 0))
		self.ts_img:runAction(cc.FadeIn:create(0.3))
		self.em_img:runAction(cc.FadeIn:create(0.3))
	end

	callback = cc.CallFunc:create(callback)

	local seq2 = cc.Sequence:create(ac1, ac2, callback)

	self.sword_img:runAction(seq2)

	local ac3 =  self.logo_node:runAction(cc.FadeIn:create(2))
	self.logo_node:stopAction(ac3)
	local ac4 =  self.logo_node:runAction(cc.ScaleTo:create(1, 0))
	self.logo_node:stopAction(ac4)

	local seq3 = cc.Sequence:create(ac3, ac4)

	self.logo_node:runAction(seq3)


	local ac5 =  self.pre_panel:runAction(cc.FadeIn:create(3))
	self.pre_panel:stopAction(ac5)
	local ac6 =  self.pre_panel:runAction(cc.MoveTo:create(0.2, cc.p(0, 4000)))
	self.pre_panel:stopAction(ac6)

	local seq4 = cc.Sequence:create(ac5, ac6)

	self.pre_panel:runAction(seq4)
end

map_view.init_enter_animation = function(self)
	self.shield_img:setOpacity(0)

	self.sword_img:setPositionY(1500)
	self.sword_img:setScale(1.2)

	self.ts_img:setRotation(-60)
	self.em_img:setRotation(60)
	self.ts_img:setOpacity(0)
	self.em_img:setOpacity(0)

	self.word_img:setScale(5)
	self.word_img:setVisible(false)

	self.logo_node:setScale(1)
	self.logo_node:setVisible(true)

	self.pre_panel:setPosition(960, 216)
end

map_view.get_arena_top_node = function(self)
	return self.arena_top_node
end

return map_view