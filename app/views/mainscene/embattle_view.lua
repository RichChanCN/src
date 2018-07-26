local view = require("packages.mvc.ViewBase")

local embattle_view = view:instance()

embattle_view.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["arena_node"]			= {["varname"] = "arena_node"},
    ["monster_lv"]			= {["varname"] = "monster_lv"},
    ["default_panel"]		= {["varname"] = "default_panel"},
    ["hex_node"]			= {["varname"] = "hex_node"},
}

function embattle_view:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)
	self:initArena()
	self:initInfo()
	self:initEvents()
	self:initMonsterLV()
	self.isInited = true
end

function embattle_view:initInfo()
	self.gezi_cell_num = 44
	self.cur_drag_monster = nil
	self.target_pos = nil
	self.cur_focus_tag = nil
	self.monster_team = {}
end

function embattle_view:initEvents()
	self:addArenaListener()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:openAdventureView()
        self:closeView()
    end)

end


function embattle_view:updateView()

end

function embattle_view:openView()
	if not self.isInited then
		self:init()
	end

	self:resumeArenaListener()
	self.root:setPosition(uitool:zero())
end

function embattle_view:closeView()
	self:pauseArenaListener()
	self.root:setPosition(uitool:farAway())
end

------------左边卡池部分开始------------
function embattle_view:initMonsterLV()
	local test_item = self.default_panel
	self:initLVItem(test_item)
	--self.monster_lv:pushBackCustomItem(test_item)
end

function embattle_view:initLVItem(item, data)
	local monster = {}
	for i=1,3 do
		monster[i] = {}
		monster[i].head_img = item:getChildByName("monster_"..i.."_img")
		monster[i].border_img = item:getChildByName("border_img")
		monster[i].type_img = item:getChildByName("type_img")
		self:addMonsterCardEvent(monster[i].head_img)
	end
end

function embattle_view:addMonsterCardEvent(img)
	   
	local function touchBegan( touch, event )

		if self.cur_drag_monster then
			self.hex_node:removeChild(self.cur_drag_monster)
			self.cur_drag_monster = nil
		end

        local node = event:getCurrentTarget()
        local locationInNode = node:convertToNodeSpace(touch:getLocation())
        local s = node:getContentSize()
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            node:setScale(1.06)
            return true
        end

        return false
    end

    local function touchMoved( touch, event )
        local node = event:getCurrentTarget()
		local cur_pos = self.hex_node:convertToNodeSpace(touch:getLocation())
		local start_pos = self.hex_node:convertToNodeSpace(touch:getStartLocation())

		if math.abs(cur_pos.y-start_pos.y)<50 and math.abs(cur_pos.x-start_pos.x)>50 and not self.cur_drag_monster then
			self.cur_drag_monster = cc.Sprite:create(Config.embattle_sprite.hex_boder_1)
			self.hex_node:addChild(self.cur_drag_monster, 500)
		end

		if self.cur_drag_monster then
			self.cur_drag_monster:setPosition(cc.p(cur_pos.x, cur_pos.y))
		end

		local locationInNode = node:convertToNodeSpace(touch:getLocation())
        local s = node:getContentSize()
        local rect = cc.rect(0,0,s.width,s.height)
        

        if cc.rectContainsPoint(rect, locationInNode) then
            node:setScale(1.06)
        else
            node:setScale(1.0)
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        local locationInNode = node:convertToNodeSpace(touch:getLocation())
        local s = node:getContentSize()
        local rect = cc.rect(0,0,s.width,s.height)

        if self.cur_drag_monster and not self.target_pos then
        	local pos = self.hex_node:convertToNodeSpace(touch:getStartLocation())
			uitool:moveToAndFadeOut(self.cur_drag_monster,pos)
		elseif self.target_pos then
			self.cur_drag_monster:setPosition(self.target_pos)
			table.insert(self.monster_team, self.cur_drag_monster)
			self.target_pos = nil
			self.cur_drag_monster = nil
		end

        if cc.rectContainsPoint(rect, locationInNode) then
            node:setScale(1.0)
            if callback then
                callback()
            end
        end
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    --img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end
------------左边卡池部分结束------------
------------棋子部分开始------------

------------棋子部分结束------------
------------右边战场部分开始------------
function embattle_view:initArena()
	for i=1,7 do
		for j=1,8 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..i.."_"..j] = self.arena_node:getChildByName("gezi_"..i.."_"..j)
			if j<3 and self["gezi_"..i.."_"..j] then
				self["gezi_"..i.."_"..j]:loadTexture(Config.embattle_sprite.gezi_raw)
				self["gezi_"..i.."_"..j]:setScaleX(0.9)
				self["gezi_"..i.."_"..j]:setScaleY(0.8)
			end
		end
	end

	self.highlight_border_sp = self.arena_node:getChildByName("highlight_border_sp")
	self.selected_sp = self.arena_node:getChildByName("selected_sp")
	print(self.highlight_border_sp:getOpacity())
end

function embattle_view:selectHex(pos)
	self.highlight_border_sp:setPosition(pos)
	self.selected_sp:setPosition(pos)
	self.selected_sp:runAction(cc.FadeOut:create(3))
end

function embattle_view:resetSelectEffect()
	self.highlight_border_sp:cleanup()
	self.selected_sp:cleanup()
	self.highlight_border_sp:setPosition(uitool:farAway())
	self.highlight_border_sp:setOpacity(255)
	self.highlight_border_sp:setScaleX(0.55)
	self.highlight_border_sp:setScaleY(0.6)
	self.selected_sp:setPosition(uitool:farAway())
	self.selected_sp:setOpacity(255)
end

function embattle_view:putInHex()
	local ac1 = self.highlight_border_sp:runAction(cc.ScaleTo:create(1.0,0.8))
    local ac2 = self.highlight_border_sp:runAction(cc.FadeOut:create(1.0))
	local callback  = cc.CallFunc:create(handler(self,self.resetSelectEffect))

	local seq = cc.Sequence:create(ac1,ac2,callback)
	self.highlight_border_sp:runAction(seq)
end

function embattle_view:addArenaListener()

	local function touchBegan( touch, event )
		return true
	end

	local function touchMoved( touch, event )
		local node = event:getCurrentTarget()
		local x,y = node:getPosition()
		local locationInNode = node:convertToNodeSpace(touch:getLocation())
		
		local border = node:getContentSize()
		
		local rect = cc.rect(0,0,border.width*0.8,border.height*0.8)
		
		if self.cur_drag_monster and cc.rectContainsPoint(rect, locationInNode) then
			self.cur_focus_tag = node:getTag()
			self:selectHex(cc.p(x,y))
			self.target_pos = cc.p(x,y)
		elseif self.cur_focus_tag == node:getTag() then
			self:resetSelectEffect()
			self.target_pos = nil
		end
	end

	local function touchEnded( touch, event )
		local node = event:getCurrentTarget()
		local locationInNode = node:convertToNodeSpace(touch:getLocation())
		local s = node:getContentSize()
		local rect = cc.rect(0,0,s.width*0.8,s.height*0.8)
		if cc.rectContainsPoint(rect, locationInNode) then
			self:putInHex()
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	--注意！！！如果一个界面监听的事件很多会导致降帧！
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				self["gezi_"..i.."_"..j].listener = listener:clone()
				eventDispatcher:addEventListenerWithSceneGraphPriority(self["gezi_"..i.."_"..j].listener, self["gezi_"..i.."_"..j])
				eventDispatcher:pauseEventListenersForTarget(self["gezi_"..i.."_"..j])
			end
		end
	end

end

function embattle_view:resumeArenaListener()
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				eventDispatcher:resumeEventListenersForTarget(self["gezi_"..i.."_"..j])
			end
		end
	end
end

function embattle_view:pauseArenaListener()
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				eventDispatcher:pauseEventListenersForTarget(self["gezi_"..i.."_"..j])
			end
		end
	end
end

function embattle_view:removeArenaListener()
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				eventDispatcher:removeEventListener(self["gezi_"..i.."_"..j].listener)
			end
		end
	end
end
------------右边战场部分结束------------


return embattle_view