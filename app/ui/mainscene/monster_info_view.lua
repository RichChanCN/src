local view = require("packages.mvc.view_base")

local monster_info_view = view:instance()

monster_info_view.RESOURCE_BINDING = 
{
	["left_node"]		    = {["varname"] = "left_node"},
    ["info_bg_img"]         = {["varname"] = "info_bg_img"},
    ["title_text"]          = {["varname"] = "title_text"},
    ["back_btn"]            = {["varname"] = "back_btn"},
}

monster_info_view.init_ui = function(self)
    self:init_left_model_node()
    self:init_right_info_node()
end

monster_info_view.init_left_model_node = function(self)
    self.left_btn           = self.left_node:getChildByName("left_btn")
    self.right_btn          = self.left_node:getChildByName("right_btn")
    self.rarity_sp          = self.left_node:getChildByName("rarity_sp")
    self.type_sp            = self.left_node:getChildByName("type_sp")
    self.type_text          = self.left_node:getChildByName("type_text")
    self.rarity_text        = self.left_node:getChildByName("rarity_text")
    self.description_btn    = self.left_node:getChildByName("description_btn")
    self.progress_img       = self.left_node:getChildByName("progress_img")
    self.progress_text      = self.left_node:getChildByName("progress_text")
    self.up_sp              = self.left_node:getChildByName("up_sp")
    self.model_panel        = self.left_node:getChildByName("model_panel")
end

monster_info_view.init_right_info_node = function(self)
    self.upgrade_img                = self.info_bg_img:getChildByName("upgrade_img")
    self.details_btn                = self.info_bg_img:getChildByName("details_btn")
    self.video_btn                  = self.info_bg_img:getChildByName("video_btn")
    self.hp_text                    = self.info_bg_img:getChildByName("hp_text")
    self.damage_text                = self.info_bg_img:getChildByName("damage_text")
    self.physical_defense_text      = self.info_bg_img:getChildByName("physical_defense_text")
    self.magic_defense_text         = self.info_bg_img:getChildByName("magic_defense_text")
    self.initiative_text            = self.info_bg_img:getChildByName("initiative_text")
    self.mobility_text              = self.info_bg_img:getChildByName("mobility_text")
    self.defense_penetration_text   = self.info_bg_img:getChildByName("defense_penetration_text")

    self.no_skill_text              = self.info_bg_img:getChildByName("no_skill_text")
    self.skill_sp                   = self.info_bg_img:getChildByName("skill_sp")
    self.skill_icon_sp              = self.skill_sp:getChildByName("skill_icon_sp")
    self.skill_description_text     = self.info_bg_img:getChildByName("skill_description_text")
end

monster_info_view.init_info = function(self)
    self._left_node_start_pos = cc.p(-545, 540)
    self._left_node_final_pos = cc.p(545, 540)
    self._right_node_start_pos = cc.p(2350, 500)
    self._right_node_final_pos = cc.p(1490, 500)

    self._monster_list = {}
    self._next_animate = 2
    self._is_model_loaded = false
    self._monster_model = nil
    self._model_camera = nil
    self._monster_data = {}
end

monster_info_view.update_info = function(self, monster_list, index)
    self._next_animate = 2
    self._is_model_loaded = false
    self._monster_list = monster_list
    self._cur_index = index
    self._monster_data = monster_list[index]
    self._last_index = self._cur_index - 1
    if self._last_index < 1 then
        self._last_index = #self._monster_list
    end

    self._next_index = self._cur_index + 1
    if self._next_index > #self._monster_list then
        self._next_index = 1
    end
end

monster_info_view.init_events = function(self)
	self.back_btn:addClickEventListener(function(sender)
        self._ctrl:close_monster_info_view()
    end)

    self.left_btn:addClickEventListener(function(sender)
        self:update_view(self._monster_list, self._next_index)
    end)

    self.right_btn:addClickEventListener(function(sender)
        self:update_view(self._monster_list, self._last_index)
    end)
    uitool:make_img_to_button(self.upgrade_img, function()
        if self._monster_data.card_num and not(self._monster_data.card_num < self._monster_data.level) then
            game_data_ctrl:instance():requestUpgradeMonster(self._monster_data.id)
            self:upgrade_update()
        end
    end)
    --------------左边节点事件-------------
    self:init_model_events()
end

monster_info_view.update_view = function(self, monster_list, index)
	self.title_text:setString("LEVEL " .. monster_list[index].level .. " " .. monster_list[index].name)
    self:update_info(monster_list, index)
    self:update_left_model_node(monster_list[index])
    self:update_right_info_node(monster_list[index])
end

monster_info_view.on_open = function(self, ...)
    local params = {...}
    self:update_view(params[1], params[2])
    self.left_node:runAction(cc.MoveTo:create(0.2, self._left_node_final_pos))
    self.info_bg_img:runAction(cc.MoveTo:create(0.2, self._right_node_final_pos))
end

monster_info_view.on_close = function(self)
    self.left_node:setPosition(self._left_node_start_pos)
    self.info_bg_img:setPosition(self._right_node_start_pos)
end
----------------------------------------------------------------
----------------------------------------------------------------

monster_info_view.update_monster_by_id = function(self, id)
    self._monster_list[self._cur_index] = game_data_ctrl:instance():get_monster_data_by_id(id)
end

monster_info_view.upgrade_update = function(self)
    local card_num, level = game_data_ctrl:instance():get_monster_card_num_and_level_by_id(self._monster_data.id)

    self.title_text:setString("LEVEL " .. level .. " " .. self._monster_data.name)
    self.progress_text:setString(card_num  .. "/" .. level)
    uitool:set_progress_bar(self.progress_img, card_num / level)
    self:update_monster_by_id(self._monster_data.id)
end

--------------------左边相关开始----------------------
monster_info_view.update_left_model_node = function(self, data)
    self:create_model(data)

    self.rarity_sp:setTexture(g_config.sprite["rarity_sp_" .. data.rarity])
    self.type_sp:setTexture(g_config.sprite["attack_type_" .. data.attack_type])
    self.type_text:setString(g_config.text["monster_type_" .. data.attack_type])
    self.rarity_text:setString(g_config.text["rarity_text_" .. data.rarity])
    self.rarity_text:setTextColor(g_config.color["rarity_color_" .. data.rarity])

    if not data.card_num then
        self.progress_text:setString(0  .. "/" .. data.level)
        uitool:set_progress_bar(self.progress_img, 0)
    else
        self.progress_text:setString(data.card_num .. "/" .. data.level)
        uitool:set_progress_bar(self.progress_img, data.card_num / data.level)
    end
end

monster_info_view.create_model = function(self, data)
    if self._monster_model then
        self.model_panel:removeChild(self._monster_model)
    end

	local callback = function(model)

		model:setScale(4.5)
        model:setRotation3D(cc.vec3(0, -90, 0))
        if data.move_type == g_config.monster_move_type.FLY then
            local center_pos = uitool:get_node_center_position(self.model_panel)
            model:setPosition(center_pos)
        else
            local center_pos = uitool:get_node_bottom_center_position(self.model_panel)
            model:setPosition(center_pos)
        end
        
        self.animation = cc.Animation3D:create(data.model_path)
        if self.animation then
            local monster = {}
            monster.id = data.id
            monster.animation = self.animation
            local animate = g_config:get_monster_animate(monster, "alive")
            model:runAction(cc.RepeatForever:create(animate))
        end

		self._monster_model = model
        self._cur_monster_id = data.id
		self.model_panel:addChild(model)
		self._is_model_loaded = true
	end
    cc.Sprite3D:createAsync(data.model_path, callback)
    
end

monster_info_view.init_model_events = function(self)
	local touch_began = function(touch, event)
	    local node = event:getCurrentTarget()

	    if uitool:is_touch_in_node_rect(node, touch, event) and self._is_model_loaded then
	        return true
	    end

	    return false
	end

	local touch_moved = function(touch, event)
	    local node = event:getCurrentTarget()
		local diff = touch:getDelta()
		local pos_3d = self._monster_model:getRotation3D()
		pos_3d.y = pos_3d.y + diff.x / 5
		self._monster_model:setRotation3D(pos_3d)

		local x = 1
	end

	local touch_ended = function(touch, event)
	    local node = event:getCurrentTarget()
	    local cur_pos = node:convertToNodeSpace(touch:getLocation())
	    local start_pos = node:convertToNodeSpace(touch:getStartLocation())
	    
	    if cur_pos.x - start_pos.x < 5 and cur_pos.y - start_pos.y < 5 then
	    	self:play_an_animation()
	    end
	end

	self.model_panel.listener = cc.EventListenerTouchOneByOne:create()
	self.model_panel.listener:setSwallowTouches(true)
	self.model_panel.listener:registerScriptHandler(touch_began, cc.Handler.EVENT_TOUCH_BEGAN)
	self.model_panel.listener:registerScriptHandler(touch_moved, cc.Handler.EVENT_TOUCH_MOVED)
	self.model_panel.listener:registerScriptHandler(touch_ended, cc.Handler.EVENT_TOUCH_ENDED)
	local event_dispatcher = cc.Director:getInstance():getEventDispatcher()
	event_dispatcher:addEventListenerWithSceneGraphPriority(self.model_panel.listener, self.model_panel)
end

monster_info_view.play_an_animation = function(self)
    self._monster_model:stopAllActions()
    local monster = {}
    monster.id = self._cur_monster_id
    monster.animation = self.animation
    local animate = g_config:get_monster_animate(monster, self._next_animate)

    self._monster_model:runAction(cc.RepeatForever:create(animate))

    self._next_animate = self._next_animate % g_config.monster_animate[self._cur_monster_id].show_num + 1
end
--------------------左边相关结束----------------------

--------------------右边相关开始----------------------
monster_info_view.update_right_info_node = function(self, data)
	self.hp_text:setString(data.hp)
	self.damage_text:setString(data.damage)
	self.physical_defense_text:setString(data.physical_defense)
	self.magic_defense_text:setString(data.magic_defense)
	self.initiative_text:setString(data.initiative)
	self.mobility_text:setString(data.mobility)
	self.defense_penetration_text:setString(data.defense_penetration)

    if data.skill then
        self.no_skill_text:setVisible(false)
        self.skill_sp:setVisible(true)
        self.skill_description_text:setVisible(true)
        self.skill_sp:setTexture(data.skill.img_path)
        self.skill_description_text:setString(data.skill.description)
    else
        self.no_skill_text:setVisible(true)
        self.skill_sp:setVisible(false)
        self.skill_description_text:setVisible(false)
    end
end
--------------------右边相关结束----------------------

return monster_info_view