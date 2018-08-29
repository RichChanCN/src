local view = require("packages.mvc.view_base")

local battle_info_view = view:instance()

battle_info_view.RESOURCE_BINDING = 
{
	["left_bottom_img"]         = {["varname"] = "left_bottom_img"},
    ["right_bottom_node"]       = {["varname"] = "right_bottom_node"},
    ["particle_node"]           = {["varname"] = "particle_node"},
}

battle_info_view.init_ui = function(self)
    self:init_right_bottom()
    self:init_left_bottom()
end

battle_info_view.init_right_bottom = function(self)
    self.defend_img     = self.right_bottom_node:getChildByName("defend_img")
    self.wait_img       = self.right_bottom_node:getChildByName("wait_img")
    self.auto_img       = self.right_bottom_node:getChildByName("auto_img")
    self.speed_img      = self.right_bottom_node:getChildByName("speed_img")
    self.exit_img       = self.right_bottom_node:getChildByName("exit_img")

    self.auto_icon      = self.auto_img:getChildByName("img")
    self.speed_icon     = self.speed_img:getChildByName("img")
end

battle_info_view.init_left_bottom = function(self)
    self.round_text         = self.left_bottom_img:getChildByName("round_text")
    self.queue_lv           = self.left_bottom_img:getChildByName("queue_lv")
    self.queue_template     = self.left_bottom_img:getChildByName("queue_template")
    self.cur_monster_img    = self.left_bottom_img:getChildByName("cur_monster_img")
    self.round_img          = self.left_bottom_img:getChildByName("round_img")
    self.skill_sp           = self.left_bottom_img:getChildByName("skill_sp")
    self.skill_icon_sp      = self.skill_sp:getChildByName("skill_icon_sp")
    
    self:init_queue_lv()
end

battle_info_view.init_info = function(self)
    self._left_bottom_img_start_pos = cc.p(0, -530)
    self._left_bottom_img_end_pos   = cc.p(0, 0)
    self._right_bottom_node_start_pos = cc.p(1750, -400)
    self._right_bottom_node_end_pos   = cc.p(1750, 150)

    self:update_info()
end

battle_info_view.init_events = function(self)
    uitool:make_img_to_button_no_scale(self.skill_sp, function()
        if pve_game_ctrl:instance():is_wait_order() then
            if not self.queue_first.monster:get_skill():is_need_target() then
                pve_game_ctrl:instance():run_game(pve_game_ctrl.ORDER.USE_SKILL)
            else
                local is_use_skill = not pve_game_ctrl:instance():get_is_use_skill()
                pve_game_ctrl:instance():set_is_use_skill(is_use_skill)
                self:update_skill_image()
            end
        end
    end)

    self:init_right_bottom_events()
end

battle_info_view.update_info = function(self)
    self.cur_active_index = pve_game_ctrl:instance():get_cur_active_monster_index()
    self.cur_round = pve_game_ctrl:instance():get_cur_round_num()
    self.cur_queue = pve_game_ctrl:instance():get_cur_round_monster_queue()
    self.next_queue = pve_game_ctrl:instance():get_next_round_monster_queue()
end

battle_info_view.update_view = function(self)
    self:update_info()
end

battle_info_view.on_open = function(self)
    self:update_view()
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3, self._left_bottom_img_end_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3, self._right_bottom_node_end_pos))
end

battle_info_view.on_close = function(self)
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3, self._left_bottom_img_start_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3, self._right_bottom_node_start_pos))
end

-----------------------右下按钮节点开始-----------------------

battle_info_view.init_right_bottom_events = function(self)
    uitool:make_img_to_button_no_scale(self.defend_img, function()
        if pve_game_ctrl:instance():is_wait_order() then
            pve_game_ctrl:instance():request_defend()
        end
    end)

    uitool:make_img_to_button_no_scale(self.wait_img, function()
        if pve_game_ctrl:instance():is_wait_order() then
            pve_game_ctrl:instance():request_wait()
        end
    end)

    uitool:make_img_to_button_no_scale(self.auto_img, function()
        if pve_game_ctrl:instance():is_wait_order() then
            self.auto_icon:loadTexture(g_config.sprite.autoOn)
            pve_game_ctrl:instance():request_auto()
        elseif pve_game_ctrl:instance():get_game_status() ~= pve_game_ctrl.GAME_STATUS.WAIT_ORDER then
            self.auto_icon:loadTexture(g_config.sprite.autoOff)
            pve_game_ctrl:instance():stop_auto()
        end
    end)

    uitool:make_img_to_button_no_scale(self.exit_img, function()
        self._ctrl:go_to_main_scene()
    end)
end

-----------------------右下按钮节点结束-----------------------

-----------------------左下队列节点开始-----------------------

battle_info_view.init_queue_lv = function(self)
    for i = 1, #self.cur_queue do
        if i == 1 then
            self.queue_first = self.cur_monster_img
            self:update_lv_item(self.queue_first, self.cur_queue[i])
        else
            local item = self.queue_template:clone()
            self:update_lv_item(item, self.cur_queue[i])
            self.queue_lv:pushBackCustomItem(item)
        end
    end

    self.next_round_in_queue = self.round_img:clone()
    self.queue_lv:pushBackCustomItem(self.next_round_in_queue)
    self:update_skill_image()
end

battle_info_view.update_lv_item = function(self, item, monster, update_only)
    item.monster = monster 
    item.child = {}
    item.child.border_img = item:getChildByName("border_img")
    item.child.level_text = item:getChildByName("level_text")
    
    local path = game_data_ctrl:instance():get_monster_data_by_id(monster.id).char_img_path
    item:loadTexture(path)
    item.child.border_img:loadTexture(g_config.sprite["team_card_border_"..monster:get_team_side()])
    item.child.level_text:setString(monster.level)

    self:update_anger(item)
    if update_only then
        return
    end

    local update = function(anger)
        for i = 1, item.monster:get_max_anger() do
            local star = item:getChildByName("star_img_"..i)
            if not (i > anger) then
                star:setVisible(true)
            else
                star:setVisible(false)
            end
        end
    end

    local remove_self = function()
        self.queue_lv:removeChild(item)
    end

    item.update = update
    item.remove_self = remove_self

    monster.card = item
    self:add_queue_item_event(item)
end

battle_info_view.add_queue_item_event = function(self, img)
    local touch_began = function(touch, event)
        local node = event:getCurrentTarget()
        if pve_game_ctrl:instance():is_wait_order() then
            if uitool:is_touch_in_node_rect(node, touch, event) then
                self._ctrl:show_other_around_info(node.monster)
                return true
            end
        end
        return false
    end

    local touch_ended = function(touch, event)
        self._ctrl:hide_other_around_info()
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:registerScriptHandler(touch_began, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touch_ended, cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher = cc.Director:getInstance():getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

battle_info_view.update_anger = function(self, item)
    for i = 1, item.monster:get_max_anger() do
        local star = item:getChildByName("star_img_"..i)
        if not (i > item.monster:get_cur_anger()) then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end
end

battle_info_view.update_right_bottom_queue = function(self, is_wait)
    self:update_info()

    local last_item = self.queue_template:clone()
    self:update_lv_item(last_item, self.queue_first.monster)
    
    if self.animate_card then 
        self.left_bottom_img:removeChild(self.animate_card)
    end
    self.animate_card = last_item:clone()
    self:update_lv_item(self.animate_card, self.queue_first.monster, true)
    
    self.left_bottom_img:addChild(self.animate_card)
    local px, py = self.queue_first:getPosition()
    self.animate_card:setPosition(px, py)
    local x, y = self.animate_card:getPosition()
    self.animate_card:runAction(cc.JumpTo:create(0.3, cc.p(x + 700, y), 300, 1))
    self.animate_card:runAction(cc.FadeOut:create(0.3))
    self.animate_card:runAction(cc.ScaleTo:create(0.7, 0.3))
    
    if not is_wait then
        if not self.queue_lv:getItem(0) then
            return
        end
        if not self.queue_lv:getItem(0).monster then
            self.queue_lv:removeItem(0)

            if not self.queue_lv:getItem(0) then
                return
            end
            if not last_item.monster:is_dead() then
                local index = pve_game_ctrl:instance():get_monster_index_in_cur_round_alive_monster(last_item.monster) - 1
                if self.queue_lv:getItem(index) then
                    self.queue_lv:insertCustomItem(last_item, index)
                else
                    self.queue_lv:pushBackCustomItem(last_item)
                end
                
                last_item:setOpacity(0)
                last_item:runAction(cc.FadeIn:create(0.3))
            end
            self:update_lv_item(self.queue_first, self.queue_lv:getItem(0).monster)
            self.queue_lv:removeItem(0)

            
            self.next_round_in_queue = self.round_img:clone()
            local text = self.next_round_in_queue:getChildByName("round_text")
            text:setString(self.cur_round + 1)
            self.round_text:setString("ROUND "..self.cur_round)
            
            self.queue_lv:pushBackCustomItem(self.next_round_in_queue)
        else
            self:update_lv_item(self.queue_first, self.queue_lv:getItem(0).monster)
            self.queue_lv:removeItem(0)

            if not last_item.monster:is_dead() then
                local index = self.queue_lv:getIndex(self.next_round_in_queue)
                index = index + pve_game_ctrl:instance():get_monster_index_in_next_round_alive_monster(last_item.monster)
                if self.queue_lv:getItem(index) then
                    self.queue_lv:insertCustomItem(last_item, index)
                else
                    self.queue_lv:pushBackCustomItem(last_item)
                end
                
                last_item:setOpacity(0)
                last_item:runAction(cc.FadeIn:create(0.3))
            end
        end
    else
        if not self.queue_lv:getItem(0).monster then
            return
        end
        self:update_lv_item(self.queue_first, self.queue_lv:getItem(0).monster)
        self.queue_lv:removeItem(0)
        local index = self.queue_lv:getIndex(self.next_round_in_queue)
        self.queue_lv:insertCustomItem(last_item, index)
    end
    self:update_skill_image()
end

battle_info_view.update_skill_image = function(self)
    if self.queue_first.monster:can_use_skill() then
        if self.skill_sp.particle then
            self.skill_sp:removeChildByName("skillicon")
        end

        if pve_game_ctrl:instance():get_is_use_skill() then
            local particle = cc.ParticleSystemQuad:create(g_config.Particle.skill_will_use)
            particle:setName("skillicon")
            particle:setScale(0.6)
            particle:setGlobalZOrder(uitool.mid_z_order)
            local x, y = uitool:get_node_center_position(self.skill_sp)
            particle:setPosition(x, y)
            self.skill_sp:addChild(particle)
            self.skill_sp.particle = particle
            self.skill_sp:setVisible(true)
        else
            local img_path = self.queue_first.monster:get_skill():get_img_path()
            self.skill_sp:setTexture(img_path)
            local particle = cc.ParticleSystemQuad:create(g_config.Particle.skill_can_use)
            particle:setName("skillicon")
            particle:setScale(1)
            particle:setGlobalZOrder(uitool.mid_z_order)
            particle:setPosition(uitool:get_node_center_position(self.skill_sp))
            self.skill_sp:addChild(particle)
            self.skill_sp.particle = particle
            self.skill_sp:setVisible(true)
        end
    else
        self.skill_sp:setVisible(false)
    end
end
-----------------------左下队列节点开始-----------------------
return battle_info_view