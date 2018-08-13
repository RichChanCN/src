local view = require("packages.mvc.ViewBase")

local battle_info_view = view:instance()

battle_info_view.RESOURCE_BINDING = {
	["left_bottom_img"]         = {["varname"] = "left_bottom_img"},
    ["right_bottom_node"]       = {["varname"] = "right_bottom_node"},
    ["particle_node"]           = {["varname"] = "particle_node"},
}

function battle_info_view:initUI()
    self:initRightBottom()
    self:initLeftBottom()
end

function battle_info_view:initInfo()
    self.left_bottom_img_start_pos = cc.p(0,-530)
    self.left_bottom_img_end_pos   = cc.p(0,0)
    self.right_bottom_node_start_pos = cc.p(1750,-400)
    self.right_bottom_node_end_pos   = cc.p(1750,150)

    self:updateInfo()
end

function battle_info_view:initEvents()
    self.skill_img:addClickEventListener(function(sender)
        if Judgment:Instance():isWaitOrder() then
            Judgment:Instance():runGame(Judgment.Order.USE_SKILL)
        end
    end)

    self:initRightBottomEvents()
end

function battle_info_view:updateInfo()
    self.cur_active_index = Judgment:Instance():getCurActiveMonsterIndex()
    self.cur_round = Judgment:Instance():getCurRoundNum()
    self.cur_queue = Judgment:Instance():getCurRoundMonsterQueue()
    self.next_queue = Judgment:Instance():getNextRoundMonsterQueue()
end

function battle_info_view:updateView()
    self:updateInfo()
end

function battle_info_view:openView()
    if not self.is_inited then
        self:init()
    end
    self:updateView()
    self.root:setPosition(uitool:zero())
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3,self.left_bottom_img_end_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3,self.right_bottom_node_end_pos))
end

function battle_info_view:closeView()
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
    self.exit_img    = self.right_bottom_node:getChildByName("exit_img")
end

function battle_info_view:initRightBottomEvents()
    uitool:makeImgToButtonNoScale(self.defend_img, function()
        if Judgment:Instance():isWaitOrder() then
            Judgment:Instance():requestDefend()
        end
    end)

    uitool:makeImgToButtonNoScale(self.wait_img, function()
        if Judgment:Instance():isWaitOrder() then
            Judgment:Instance():requestWait()
        end
    end)

    uitool:makeImgToButtonNoScale(self.auto_img, function()
        if Judgment:Instance():isWaitOrder() then
            Judgment:Instance():requestAuto()
        elseif Judgment:Instance():getGameStatus() ~= Judgment.GameStatus.WAIT_ORDER then
            Judgment:Instance():stopAuto()
        end
    end)

    uitool:makeImgToButtonNoScale(self.exit_img, function()
        self.ctrl:goToMainScene()
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
    self.skill_img = self.left_bottom_img:getChildByName("skill_img")

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
    self:updateSkill()
end

function battle_info_view:updateLVItem(item,monster,update_only)
    item.monster = monster 
    item.child = {}
    item.child.border_img = item:getChildByName("border_img")
    item.child.level_text = item:getChildByName("level_text")
    
    item:loadTexture(monster.char_img_path)
    item.child.border_img:loadTexture(Config.sprite["team_card_border_"..monster.team_side])
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
        local index = self.queue_lv:getIndex(item)
        self.queue_lv:removeItem(index)
    end

    item.update = update
    item.removeSelf = removeSelf

    monster.card = item
    self:addQueueItemEvent(item)
end

function battle_info_view:addQueueItemEvent(img)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()
        if Judgment:Instance():isWaitOrder() then
            if uitool:isTouchInNodeRect(node,touch,event) then
                self.ctrl:showOtherAroundInfo(node.monster)
                return true
            end
        end
        return false
    end

    local function touchEnded( touch, event )
        self.ctrl:hideOtherAroundInfo()
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
    self:updateInfo()

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

            self:updateLVItem(self.queue_first,self.queue_lv:getItem(0).monster)
            self.queue_lv:removeItem(0)
            self.queue_lv:pushBackCustomItem(last_item)

            last_item:setOpacity(0)
            last_item:runAction(cc.FadeIn:create(0.3))

            self.next_round_in_queue = self.round_img:clone()
            local text = self.next_round_in_queue:getChildByName("round_text")
            text:setString(self.cur_round+1)
            self.round_text:setString("ROUND "..self.cur_round)
            
            self.queue_lv:pushBackCustomItem(self.next_round_in_queue)
            
        else
            self:updateLVItem(self.queue_first,self.queue_lv:getItem(0).monster)
            self.queue_lv:removeItem(0)
            self.queue_lv:pushBackCustomItem(last_item)
            
            last_item:setOpacity(0)
            last_item:runAction(cc.FadeIn:create(0.3))
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

    self:updateSkill()
end

function battle_info_view:updateSkill()
    if self.queue_first.monster:canUseSkill() then
        self.skill_img:loadTexture(self.queue_first.monster.skill.img_path)
        self.skill_img:setVisible(true)
    else
        self.skill_img:setVisible(false)
    end
end
-----------------------左下队列节点开始-----------------------
return battle_info_view