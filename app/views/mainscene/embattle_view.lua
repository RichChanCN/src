local view = require("packages.mvc.ViewBase")

local embattle_view = view:instance()

embattle_view.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["arena_node"]			= {["varname"] = "arena_node"},
    ["monster_lv"]			= {["varname"] = "monster_lv"},
    ["template_panel"]		= {["varname"] = "template_panel"},
    ["hex_node"]			= {["varname"] = "hex_node"},
    ["select_num_text"]		= {["varname"] = "select_num_text"},
    ["chesspiece_template"]		= {["varname"] = "chesspiece_template"},

}
----------------------------------------------------------------
-------------------------------公有方法--------------------------
----------------------------------------------------------------
function embattle_view:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)
	self:initInfo()
	self:initArena()
	self:initEvents()
	self:initMonsterLV()
	self.isInited = true
end

function embattle_view:initInfo()
	self.gezi_cell_num = 44
	self.cur_drag_chesspiece = nil
	self.target_node = nil
	self.is_chesspiece_from_arena = false
	self.pool_right_boder = -460
	self.monster_team = {}
	self.team_size = 0
	self.chesspiece_willbe_removed = nil

	self.monsters_list = Config.Monster

	self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
end

function embattle_view:initEvents()
	self:addArenaListener()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:openAdventureView()
        self:closeView()
    end)

end


function embattle_view:updateView()
	self.select_num_text:setString("MonsterSelect ("..self.team_size.."/5)")
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
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

------------左边卡池部分开始------------
function embattle_view:initMonsterLV()
	local monsters_num = #self.monsters_list
	local mod_num = monsters_num%3
	local rows_num = monsters_num/3

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local test_item = self.template_panel:clone()
		self:initLVItem(test_item, i-1)
		self.monster_lv:pushBackCustomItem(test_item)
	end
end

function embattle_view:initLVItem(item, index)
	local monster = {}
	for i=1,3 do
		if self.monsters_list[i+3*index] then
			monster[i+3*index] = {}
			monster[i+3*index].head_img = item:getChildByName("monster_"..i.."_img")
			monster[i+3*index].border_img = item:getChildByName("border_img")
			monster[i+3*index].type_img = item:getChildByName("type_img")
			self:addMonsterCardEvent(monster[i+3*index].head_img, i+3*index)
		else
			monster[i+3*index] = {}
			monster[i+3*index].head_img = item:getChildByName("monster_"..i.."_img")
			monster[i+3*index].head_img:setVisible(false)
		end
	end
end

function embattle_view:addMonsterCardEvent(img,index)
	   
	local function touchBegan( touch, event )
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

		if math.abs(cur_pos.y-start_pos.y)<50 and math.abs(cur_pos.x-start_pos.x)>50 and not self.cur_drag_chesspiece then
			self.is_chesspiece_from_arena = false
			self.cur_drag_chesspiece = self:createChesspiece(index)
			node.listener:setSwallowTouches(true)
		end

		if self.cur_drag_chesspiece then
			self.cur_drag_chesspiece:setPosition(cc.p(cur_pos.x, cur_pos.y))
		end

        if uitool:isTouchInNodeRect(node, touch, event) then
            node:setScale(1.06)
        else
            node:setScale(1.0)
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()

        if self.cur_drag_chesspiece and not self.target_node then
        	local pos = self.hex_node:convertToNodeSpace(touch:getStartLocation())
			uitool:moveToAndFadeOut(self.cur_drag_chesspiece,pos)
			self:setChesspieceWillBeRemoved(self.cur_drag_chesspiece)
		elseif self.target_node then
			if self.target_node.chesspiece then
				self:removeOneChesspieceFromArena(self.target_node.chesspiece)
				self:addDragedChesspieceToArena(true)
			else
				self.cur_drag_chesspiece.from_card = node
				self:addDragedChesspieceToArena(true)
				self:selectTheCard(node)
				self.target_node = nil
			end
		end

        if uitool:isTouchInNodeRect(node, touch, event) then
            node:setScale(1.0)
        end

        if not self.is_chesspiece_from_arena then
			self.cur_drag_chesspiece = nil
		end

		node.listener:setSwallowTouches(false)
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    --img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    
    self.eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

function embattle_view:selectTheCard(card)
	self.eventDispatcher:pauseEventListenersForTarget(card)
end

function embattle_view:unselectTheCard(card)
	self.eventDispatcher:resumeEventListenersForTarget(card)
end
------------左边卡池部分结束------------

------------棋子部分开始------------
function embattle_view:createChesspiece(index)
	local chesspiece = self.chesspiece_template:clone()
	local face_sp = chesspiece:getChildByName("face_sp")
	local hex_border = chesspiece:getChildByName("hex_border")
	chesspiece:setName("chesspiece_"..index)
	self.hex_node:addChild(chesspiece, 100)

	return chesspiece
end

function embattle_view:setChesspieceWillBeRemoved(chesspiece)
	if self.chesspiece_willbe_removed then
		self.hex_node:removeChild(self.chesspiece_willbe_removed)
	end
	self.chesspiece_willbe_removed = chesspiece
end

function embattle_view:selectHexEffect(pos)
	self.highlight_border_sp:setPosition(pos)
	self.selected_sp:setPosition(pos)
	self.selected_sp:runAction(cc.FadeOut:create(3))
end

function embattle_view:putInHexEffect()
	local ac1 = self.highlight_border_sp:runAction(cc.ScaleTo:create(1.0,0.8))
    local ac2 = self.highlight_border_sp:runAction(cc.FadeOut:create(1.0))
	local callback  = cc.CallFunc:create(handler(self,self.resetSelectHexEffect))

	local seq = cc.Sequence:create(ac1,ac2,callback)
	self.highlight_border_sp:runAction(seq)
end

function embattle_view:resetSelectHexEffect()
	self.highlight_border_sp:cleanup()
	self.selected_sp:cleanup()
	self.highlight_border_sp:setPosition(uitool:farAway())
	self.highlight_border_sp:setOpacity(255)
	self.highlight_border_sp:setScaleX(0.55)
	self.highlight_border_sp:setScaleY(0.6)
	self.selected_sp:setPosition(uitool:farAway())
	self.selected_sp:setOpacity(255)
end

function embattle_view:addDragedChesspieceToArena(add_to_team)
	self.target_node.chesspiece = self.cur_drag_chesspiece
	self.cur_drag_chesspiece:setPosition(self.target_node:getPosition())
	self.cur_drag_chesspiece:setLocalZOrder(0)
	self.cur_drag_chesspiece.arena_cell = self.target_node
	if add_to_team then
		table.insert(self.monster_team,self.cur_drag_chesspiece)
		self.team_size = self.team_size + 1 
		self:updateView()
	end
end

function embattle_view:exchangeDragedAndTargetChesspiece()
	self.cur_drag_chesspiece:setLocalZOrder(0)

	local temp_cell = self.cur_drag_chesspiece.arena_cell
	self.cur_drag_chesspiece.arena_cell = self.target_node
	self.target_node.chesspiece.arena_cell = temp_cell

	local temp_chesspiece = self.cur_drag_chesspiece
	temp_cell.chesspiece = self.target_node.chesspiece
	self.target_node.chesspiece = temp_chesspiece

	temp_cell.chesspiece:setPosition(temp_cell:getPosition())
	self.target_node.chesspiece:setPosition(self.target_node:getPosition())

end

function embattle_view:removeOneChesspieceFromArena(chesspiece)
	for k,v in pairs(self.monster_team) do
		if v:getName() == chesspiece:getName() then
			table.remove(self.monster_team,k)
		end
	end
	self.team_size = self.team_size - 1 

	if chesspiece.arena_cell then
		chesspiece.arena_cell.chesspiece = nil
		chesspiece.arena_cell = nil
	end
	if chesspiece.from_card then
		self:unselectTheCard(chesspiece.from_card)
	end
	self.hex_node:removeChild(chesspiece)
	self:updateView()
end
------------棋子部分结束------------

------------右边战场部分开始------------
function embattle_view:initArena()
	for i=1,7 do
		for j=1,8 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..i.."_"..j] = self.arena_node:getChildByName("gezi_"..i.."_"..j)
			if self["gezi_"..i.."_"..j] then
				self["gezi_"..i.."_"..j].arena_pos = cc.p(i,j)
			end
			if j<3 and self["gezi_"..i.."_"..j] then
				self["gezi_"..i.."_"..j]:loadTexture(Config.embattle_sprite.gezi_raw)
				self["gezi_"..i.."_"..j]:setScaleX(0.9)
				self["gezi_"..i.."_"..j]:setScaleY(0.8)
			end
		end
	end

	self.highlight_border_sp = self.arena_node:getChildByName("highlight_border_sp")
	self.selected_sp = self.arena_node:getChildByName("selected_sp")

end

function embattle_view:addArenaListener()

	local function touchBegan( touch, event )
		local node = event:getCurrentTarget()
		if uitool:isTouchInNodeRect(node, touch, event ,0.8) then
			if node.chesspiece then
				self.cur_drag_chesspiece = node.chesspiece
				self.cur_drag_chesspiece:setLocalZOrder(100)
				self.is_chesspiece_from_arena = true
			end
		end

		return true
	end

	local function touchMoved( touch, event )
		local node = event:getCurrentTarget()
		local x,y = node:getPosition()
		local cur_pos = self.hex_node:convertToNodeSpace(touch:getLocation())

		if self.is_chesspiece_from_arena and self.cur_drag_chesspiece then
			self.cur_drag_chesspiece:setPosition(cc.p(cur_pos.x, cur_pos.y))
		end

		if self.cur_drag_chesspiece and uitool:isTouchInNodeRect(node, touch, event, 0.8) then
			self:selectHexEffect(cc.p(x,y))
			self.target_node = node
		elseif self.target_node and self.target_node:getTag() == node:getTag() then
			self:resetSelectHexEffect()
			self.target_node = nil
		end
	end

	local function touchEnded( touch, event )
		local node = event:getCurrentTarget()
		local cur_pos = self.hex_node:convertToNodeSpace(touch:getLocation())

        if self.is_chesspiece_from_arena then
        	if self.cur_drag_chesspiece and not self.target_node then
				if self.cur_drag_chesspiece.arena_cell and cur_pos.x < self.pool_right_boder then
					self:removeOneChesspieceFromArena(self.cur_drag_chesspiece)
				else
					self.cur_drag_chesspiece:setPosition(self.cur_drag_chesspiece.arena_cell:getPosition())
					self.cur_drag_chesspiece:setLocalZOrder(0)
				end
			elseif self.cur_drag_chesspiece and self.target_node then
				--判断如果该位置已经有棋子，那么就交换
				if self.cur_drag_chesspiece and self.target_node.chesspiece then
					self:exchangeDragedAndTargetChesspiece()
				elseif self.cur_drag_chesspiece then
					self.cur_drag_chesspiece.arena_cell.chesspiece = nil
					self:addDragedChesspieceToArena()
				end
				self:putInHexEffect()
				self.target_node = nil
			elseif self.cur_drag_chesspiece and self.cur_drag_chesspiece.arena_cell then
				if cur_pos.x < self.pool_right_boder then
					self:removeOneChesspieceFromArena(self.cur_drag_chesspiece)
				elseif node:getTag() == self.target_node:getTag() then
					self.cur_drag_chesspiece:setPosition(self.cur_drag_chesspiece.arena_cell:getPosition())
					self.cur_drag_chesspiece:setLocalZOrder(0)
				end
			end
			self.cur_drag_chesspiece = nil
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	
	
	--注意！！！如果一个界面监听的事件很多会导致降帧！
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				self["gezi_"..i.."_"..j].listener = listener:clone()
				self.eventDispatcher:addEventListenerWithSceneGraphPriority(self["gezi_"..i.."_"..j].listener, self["gezi_"..i.."_"..j])
			end
		end
	end
	self:pauseArenaListener()
end

function embattle_view:resumeArenaListener()
	
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				self.eventDispatcher:resumeEventListenersForTarget(self["gezi_"..i.."_"..j])
			end
		end
	end
end

function embattle_view:pauseArenaListener()
	
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				self.eventDispatcher:pauseEventListenersForTarget(self["gezi_"..i.."_"..j])
			end
		end
	end
end

function embattle_view:removeArenaListener()
	
	for i=1,7 do
		for j=1,2 do 
			if self["gezi_"..i.."_"..j] then
				self.eventDispatcher:removeEventListener(self["gezi_"..i.."_"..j].listener)
			end
		end
	end
end
------------右边战场部分结束------------


return embattle_view