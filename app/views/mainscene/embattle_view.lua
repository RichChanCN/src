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
    ["chesspiece_template"]	= {["varname"] = "chesspiece_template"},
    ["fight_img"]           = {["varname"] = "fight_img"},

}
----------------------------------------------------------------
-------------------------------公有方法--------------------------
----------------------------------------------------------------
function embattle_view:init()
	if not self.isInited then
		uitool:createUIBinding(self, self.RESOURCE_BINDING)

		self:initInfo()
		self:initArena()
		self:initEvents()
		self:initMonsterLV()
		
		self.isInited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function embattle_view:initInfo()
	self.gezi_cell_num = 44
	--竞技场的布局信息
	self.arena_info = nil
	--敌人的队伍信息
	self.enemy_team = nil
	--当前抓住的棋子
	self.cur_drag_chesspiece = nil
	--对准的放置节点
	self.target_node = nil
	--棋子是否来源于竞技场
	self.is_chesspiece_from_arena = false
	--牌池的有边缘
	self.pool_right_boder = -460
	--已经上场的怪物列表
	self.monster_team = {}
	--当前添加了事件监听器的卡片列表   优化使用
	self.card_list = {}
	--当前的队伍大小
	self.team_size = 0
	--将要在下次被清理掉的棋子节点   这里是因为有个动画效果，所以延迟清理
	self.chesspiece_willbe_removed = nil
	--已经收集到的怪物卡片列表
	self.collected_monster_list = self.ctrl:getCollectedMonsterList()
	--事件分发器
	self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
end

function embattle_view:initEvents()
	self:addArenaListener()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:closeEmbattleView()
    end)

    uitool:makeImgToButton(self.fight_img,function()
    	local left_team = self:makeTeam()
    	local right_team = self:makeEnemyTeam()
    	Judgment:Instance():initGame(left_team,right_team)
        self.ctrl:goToFightScene()
    end)
end


function embattle_view:updateView()
	self.select_num_text:setString("MonsterSelect ("..self.team_size.."/5)")
end

function embattle_view:openView()
	if not self.isInited then
		self:init()
	end
	self:resumeMonsterListListener()
	self:resumeArenaListener()
	self.root:setPosition(uitool:zero())
end

function embattle_view:closeView()
	self:pauseMonsterListListener()
	self:pauseArenaListener()
	self.root:setPosition(uitool:farAway())
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------
function embattle_view:makeTeam()
	local team = {}
	local MonsterBase = require("app.logic.MonsterBase")

	for _,v in pairs(self.monster_team) do
		table.insert(team, MonsterBase:instance():new(Config.Monster[v.monster_id],MonsterBase.TeamSide.Left,v.arena_cell.pos))
	end

	return team
end

function embattle_view:makeEnemyTeam()
	local team = {}
	local MonsterBase = require("app.logic.MonsterBase")

	table.insert(team, MonsterBase:instance():new(Config.Monster[1],MonsterBase.TeamSide.RIGHT,cc.p(8,3)))
	table.insert(team, MonsterBase:instance():new(Config.Monster[1],MonsterBase.TeamSide.RIGHT,cc.p(8,5)))

	return team
end
------------左边卡池部分开始------------
function embattle_view:initMonsterLV()
	local monsters_num = #self.collected_monster_list
	local mod_num = monsters_num%3
	local rows_num = monsters_num/3

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local test_item = self.template_panel:clone()
		self:initLVItem(test_item, i-1) --这里-1是为了里面好计算正真的索引值
		self.monster_lv:pushBackCustomItem(test_item)
	end
end

function embattle_view:initLVItem(item, index)
	for i=1,3 do
		local cur_index = i+3*index
		local cur_monster = {}
		if self.collected_monster_list[cur_index] then
			cur_monster.head_img = item:getChildByName("monster_"..i.."_img")
			cur_monster.head_img:loadTexture(self.collected_monster_list[cur_index].char_img_path)
			cur_monster.border_img = cur_monster.head_img:getChildByName("border_img")
			cur_monster.border_img:loadTexture(Config.sprite["card_border_"..self.collected_monster_list[cur_index].rarity])
			cur_monster.type_img = cur_monster.head_img:getChildByName("type_img")
			cur_monster.type_img:loadTexture(Config.sprite["attack_type_"..self.collected_monster_list[cur_index].attack_type])
			self:addMonsterCardEvent(cur_monster.head_img, cur_index)
			table.insert(self.card_list,cur_monster.head_img)
		else
			cur_monster.head_img = item:getChildByName("monster_"..i.."_img")
			cur_monster.head_img:setVisible(false)
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
	local selected_sp = cc.Sprite:create(Config.sprite.selected)
	selected_sp:setName("selected_sp")
	selected_sp:setScale(1.5)
	card:addChild(selected_sp, uitool:top_Z_order())
	card.selected = true
	selected_sp:setPosition(uitool:getNodeCenterPosition(card))
end

function embattle_view:unselectTheCard(card)
	self.eventDispatcher:resumeEventListenersForTarget(card)

	if card:getChildByName("selected_sp") then
		card:removeChildByName("selected_sp")
	end
end

function embattle_view:resumeMonsterListListener()
	for _,v in pairs(self.card_list) do
		if not v.selected then
			self.eventDispatcher:resumeEventListenersForTarget(v)
		end
	end
end

function embattle_view:pauseMonsterListListener()
	for _,v in pairs(self.card_list) do
		if not v.selected then
			self.eventDispatcher:pauseEventListenersForTarget(v)
		end
	end
end
------------左边卡池部分结束------------

------------棋子部分开始------------
function embattle_view:createChesspiece(index)

	local chesspiece = cc.Sprite:create(Config.sprite.chesspiece_mask)
	chesspiece:setScale(0.5)
	local blendfunc = {src = gl.ONE_MINUS_SRC_ALPHA, dst = gl.ONE_MINUS_SRC_ALPHA}
	chesspiece:setBlendFunc(blendfunc)
	
	local face_sp = cc.Sprite:create(self.collected_monster_list[index].char_img_path)
	blendfunc = {src = gl.ONE_MINUS_DST_ALPHA, dst = gl.DST_ALPHA}
	face_sp:setBlendFunc(blendfunc)
	face_sp:setName("face_sp")

	local hex_border = cc.Sprite:create(Config.sprite["hex_border_"..self.collected_monster_list[index].rarity])
	hex_border:setScale(2.0)
	hex_border:setName("hex_border")
	chesspiece:addChild(hex_border, uitool:bottom_Z_order()+5)
	hex_border:setPosition(uitool:getNodeCenterPosition(chesspiece))
	chesspiece:addChild(face_sp, uitool:bottom_Z_order())
	face_sp:setPosition(uitool:getNodeCenterPosition(chesspiece))
	
	chesspiece:setName("chesspiece_"..index)
	self.hex_node:addChild(chesspiece, uitool:bottom_Z_order())

	chesspiece.monster_id = self.collected_monster_list[index].id

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
	self:putInHexEffect()

	self.target_node.chesspiece = self.cur_drag_chesspiece
	self.cur_drag_chesspiece:setPosition(self.target_node:getPosition())
	self.cur_drag_chesspiece:setLocalZOrder(uitool:bottom_Z_order())
	self.cur_drag_chesspiece.arena_cell = self.target_node
	if add_to_team then
		table.insert(self.monster_team,self.cur_drag_chesspiece)
		self.team_size = self.team_size + 1 
		self:updateView()
	end
end

function embattle_view:exchangeDragedAndTargetChesspiece()
	self:putInHexEffect()

	self.cur_drag_chesspiece:setLocalZOrder(uitool:bottom_Z_order())

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
	for x=1,8 do
		for y=1,7 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..x.."_"..y] = self.arena_node:getChildByName("gezi_"..x.."_"..y)
			if self["gezi_"..x.."_"..y] then
				self["gezi_"..x.."_"..y].pos = cc.p(x,y)
			end
			if x<3 and self["gezi_"..x.."_"..y] then
				self["gezi_"..x.."_"..y]:loadTexture(Config.sprite.gezi_raw)
				self["gezi_"..x.."_"..y]:setScaleX(0.9)
				self["gezi_"..x.."_"..y]:setScaleY(0.8)
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
				self.cur_drag_chesspiece:setLocalZOrder(uitool:top_Z_order())
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
					self.cur_drag_chesspiece:setLocalZOrder(uitool:bottom_Z_order())
				end
			elseif self.cur_drag_chesspiece and self.target_node then
				--判断如果该位置已经有棋子，那么就交换
				if self.cur_drag_chesspiece and self.target_node.chesspiece then
					self:exchangeDragedAndTargetChesspiece()
				elseif self.cur_drag_chesspiece then
					self.cur_drag_chesspiece.arena_cell.chesspiece = nil
					self:addDragedChesspieceToArena()
				end
				self.target_node = nil
			elseif self.cur_drag_chesspiece and self.cur_drag_chesspiece.arena_cell then
				if cur_pos.x < self.pool_right_boder then
					self:removeOneChesspieceFromArena(self.cur_drag_chesspiece)
				elseif node:getTag() == self.target_node:getTag() then
					self.cur_drag_chesspiece:setPosition(self.cur_drag_chesspiece.arena_cell:getPosition())
					self.cur_drag_chesspiece:setLocalZOrder(uitool:bottom_Z_order())
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
	for x=1,2 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self["gezi_"..x.."_"..y].listener = listener:clone()
				self.eventDispatcher:addEventListenerWithSceneGraphPriority(self["gezi_"..x.."_"..y].listener, self["gezi_"..x.."_"..y])
			end
		end
	end
	self:pauseArenaListener()
end

function embattle_view:resumeArenaListener()
	
	for x=1,2 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:resumeEventListenersForTarget(self["gezi_"..x.."_"..y])
			end
		end
	end
end

function embattle_view:pauseArenaListener()
	
	for x=1,2 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:pauseEventListenersForTarget(self["gezi_"..x.."_"..y])
			end
		end
	end
end

function embattle_view:removeArenaListener()
	
	for x=1,2 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:removeEventListener(self["gezi_"..x.."_"..y].listener)
			end
		end
	end
end
------------右边战场部分结束------------


return embattle_view