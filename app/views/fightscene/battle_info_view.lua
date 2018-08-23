local view = require("packages.mvc.view_base")

local battle_info_view = view:instance()

battle_info_view.RESOURCE_BINDING = {
	["left_bottom_img"]         = {["varname"] = "left_bottom_img"},
    ["right_bottom_node"]       = {["varname"] = "right_bottom_node"},
    ["particle_node"]           = {["varname"] = "particle_node"},
}

function battle_info_view:init_ui()
    self:initRightBottom()
    self:initLeftBottom()
end

function battle_info_view:init_info()
    self.left_bottom_img_start_pos = cc.p(0,-530)
    self.left_bottom_img_end_pos   = cc.p(0,0)
    self.right_bottom_node_start_pos = cc.p(1750,-400)
    self.right_bottom_node_end_pos   = cc.p(1750,150)

    self:update_info()
end

function battle_info_view:init_events()
    uitool:make_img_to_button_no_scale(self.skill_sp, function()
        if pve_game_ctrl:instance():is_wait_order() then
            if not self.queue_first.monster.skill:is_need_target() then
                pve_game_ctrl:instance():runGame(pve_game_ctrl.order.USE_SKILL)
            else
                pve_game_ctrl:instance():set_is_use_skill(not pve_game_ctrl:instance():get_is_use_skill())
                self:updateSkillImage()
            end
        end
    end)

    self:initRightBottomEvents()
end

function battle_info_view:update_info()
    self.cur_active_index = pve_game_ctrl:instance():getCurActiveMonsterIndex()
    self.cur_round = pve_game_ctrl:instance():get_cur_round_num()
    self.cur_queue = pve_game_ctrl:instance():get_cur_round_monster_queue()
    self.next_queue = pve_game_ctrl:instance():get_next_round_monster_queue()
end

function battle_info_view:update_view()
    self:update_info()
end

function battle_info_view:open_view()
    if not self.is_inited then
        self:init()
    end
    self:update_view()
    self.root:setPosition(uitool:zero())
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3,self.left_bottom_img_end_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3,self.right_bottom_node_end_pos))
end

function battle_info_view:close_view()
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3,self.left_bottom_img_start_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3,self.right_bottom_node_start_pos))
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

-----------------------右下按钮节点开始-----------------------
function battle_info_view:initRightBottom()
    self.defend_img     = self.right_bottom_node:getChildByName("defend_img")
    self.wait_img       = self.right_bottom_node:getChildByName("wait_img")
    self.auto_img       = self.right_bottom_node:getChildByName("auto_img")
    self.speed_img      = self.right_bottom_node:getChildByName("speed_img")
    self.exit_img       = self.right_bottom_node:getChildByName("exit_img")

    self.auto_icon = self.auto_img:getChildByName("img")
    self.speed_icon = self.speed_img:getChildByName("img")
end

function battle_info_view:initRightBottomEvents()
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
        elseif pve_game_ctrl:instance():get_game_status() ~= pve_game_ctrl.game_status.WAIT_ORDER then
            self.auto_icon:loadTexture(g_config.sprite.autoOff)
            pve_game_ctrl:instance():stop_auto()
        end
    end)

    uitool:make_img_to_button_no_scale(self.exit_img, function()
        self:get_ctrl():go_to_main_scene()
    end)
end

-----------------------右下按钮节点结束-----------------------

-----------------------左下队列节点开始-----------------------

function battle_info_view:initLeftBottom()
    self.round_text = self.left_bottom_img:getChildByName("round_text")
    self.queue_lv = self.left_bottom_img:getChildByName("queue_lv")
    self.queue_template = self.left_bottom_img:getChildByName("queue_template")
    self.cur_monster_img = self.left_bottom_img:getChildByName("cur_monster_img")
    self.round_img = self.left_bottom_img:getChildByName("round_img")
    self.skill_sp = self.left_bottom_img:getChildByName("skill_sp")
    self.skill_icon_sp = self.skill_sp:getChildByName("skill_icon_sp")
    self:initQueueLV()
end

function battle_info_view:initQueueLV()
    --self.queue = {}
    for i=1,#self.cur_queue do
        if i == 1 then
            self.queue_first = self.cur_monster_img
            self:updateLVItem(self.queue_first,self.cur_queue[i])
        else
            local item = self.queue_template:clone()
            self:updateLVItem(item,self.cur_queue[i])
            self.queue_lv:pushBackCustomItem(item)
        end
    end

    self.next_round_in_queue = self.round_img:clone()
    self.queue_lv:pushBackCustomItem(self.next_round_in_queue)
    self:updateSkillImage()
end

function battle_info_view:updateLVItem(item,monster,update_only)
    item.monster = monster 
    item.child = {}
    item.child.border_img = item:getChildByName("border_img")
    item.child.level_text = item:getChildByName("level_text")
    
    item:loadTexture(monster.char_img_path)
    item.child.border_img:loadTexture(g_config.sprite["team_card_border_"..monster:get_team_side()])
    item.child.level_text:setString(monster.level)

    self:updateAnger(item)
    if update_only then
        return
    end

    local update = function(anger)
        for i=1,item.monster.max_anger do
            local star = item:getChildByName("star_img_"..i)
            if not (i>anger) then
                star:setVisible(true)
            else
                star:setVisible(false)
            end
        end
    end

    local removeSelf = function()
        self.queue_lv:removeChild(item)
    end

    item.update = update
    item.removeSelf = removeSelf

    monster.card = item
    self:addQueueItemEvent(item)
end

function battle_info_view:addQueueItemEvent(img)
    local touchBegan = function(touch, event)
        local node = event:getCurrentTarget()
        if pve_game_ctrl:instance():is_wait_order() then
            if uitool:is_touch_in_node_rect(node,touch,event) then
                self:get_ctrl():show_other_around_info(node.monster)
                return true
            end
        end
        return false
    end

    local touchEnded = function(touch, event)
        self:get_ctrl():hide_other_around_info()
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    --img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

function battle_info_view:updateAnger(item)
    for i=1,item.monster.max_anger do
        local star = item:getChildByName("star_img_"..i)
        if not (i>item.monster.cur_anger) then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end
end

function battle_info_view:updateRightBottomQueue(is_wait)
    self:update_info()

    local last_item = self.queue_template:clone()
    self:updateLVItem(last_item,self.queue_first.monster)
    
    if self.animate_card then 
        self.left_bottom_img:removeChild(self.animate_card)
    end
    self.animate_card = last_item:clone()
    self:updateLVItem(self.animate_card,self.queue_first.monster,true)
    
    self.left_bottom_img:addChild(self.animate_card)
    self.animate_card:setPosition(self.queue_first:getPosition())
    local x,y = self.animate_card:getPosition()
    self.animate_card:runAction(cc.JumpTo:create(0.3, cc.p(x+700,y), 300, 1))
    self.animate_card:runAction(cc.FadeOut:create(0.3))
    self.animate_card:runAction(cc.ScaleTo:create(0.7,0.3))
    
    if not is_wait then
        if not self.queue_lv:getItem(0).monster then
            self.queue_lv:removeItem(0)

            if not self.queue_lv:getItem(0) then
                return
            end
            if not last_item.monster:is_dead() then
                local index = pve_game_ctrl:instance():get_monster_index_in_cur_round_alive_monster(last_item.monster)-1
                if self.queue_lv:getItem(index) then
                    self.queue_lv:insertCustomItem(last_item,index)
                else
                    self.queue_lv:pushBackCustomItem(last_item)
                end
                
                last_item:setOpacity(0)
                last_item:runAction(cc.FadeIn:create(0.3))
            end
            self:updateLVItem(self.queue_first,self.queue_lv:getItem(0).monster)
            self.queue_lv:removeItem(0)

            
            self.next_round_in_queue = self.round_img:clone()
            local text = self.next_round_in_queue:getChildByName("round_text")
            text:setString(self.cur_round+1)
            self.round_text:setString("ROUND "..self.cur_round)
            
            self.queue_lv:pushBackCustomItem(self.next_round_in_queue)
        else
            self:updateLVItem(self.queue_first,self.queue_lv:getItem(0).monster)
            self.queue_lv:removeItem(0)

            if not last_item.monster:is_dead() then
                local index = self.queue_lv:getIndex(self.next_round_in_queue)
                index = index + pve_game_ctrl:instance():get_monster_index_in_next_round_alive_monster(last_item.monster)
                if self.queue_lv:getItem(index) then
                    self.queue_lv:insertCustomItem(last_item,index)
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
        self:updateLVItem(self.queue_first,self.queue_lv:getItem(0).monster)
        self.queue_lv:removeItem(0)
        local index = self.queue_lv:getIndex(self.next_round_in_queue)
        self.queue_lv:insertCustomItem(last_item,index)
    end
    self:updateSkillImage()
end

function battle_info_view:updateSkillImage()
    if self.queue_first.monster:can_use_skill() then
        if self.skill_sp.particle then
            self.skill_sp:removeChildByName("skillicon")
        end
        if pve_game_ctrl:instance():get_is_use_skill() then
            local particle = cc.ParticleSystemQuad:create(g_config.Particle.skill_will_use)
            particle:setName("skillicon")
            particle:setScale(0.6)
            particle:setGlobalZOrder(uitool:mid_z_order())
            particle:setPosition(uitool:get_node_center_position(self.skill_sp))
            self.skill_sp:addChild(particle)
            self.skill_sp.particle = particle
            self.skill_sp:setVisible(true)
        else
            self.skill_sp:setTexture(self.queue_first.monster.skill.img_path)
            local particle = cc.ParticleSystemQuad:create(g_config.Particle.skill_can_use)
            particle:setName("skillicon")
            particle:setScale(1)
            particle:setGlobalZOrder(uitool:mid_z_order())
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