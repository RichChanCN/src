local view = require("packages.mvc.ViewBase")

local map_view = view:instance()

map_view.RESOURCE_BINDING = {
    ["map_img"]				= {["varname"] = "map_img"},
    ["arena_show_node"]		= {["varname"] = "arena_show_node"},
    ["arena_bottom_node"]	= {["varname"] = "arena_bottom_node"},
    ["arena_event_node"]	= {["varname"] = "arena_event_node"},
    ["model_panel"]			= {["varname"] = "model_panel"},
    ["arena_top_node"]		= {["varname"] = "arena_top_node"},
    ["mask_img"]			= {["varname"] = "mask_img"},
    ["blood_template"]		= {["varname"] = "blood_template"},
    ["fly_word_template"]	= {["varname"] = "fly_word_template"},
}

function map_view:init()
	if not self.is_inited then
		uitool:createUIBinding(self, self.RESOURCE_BINDING)

		self:initInfo()
		self:initArena()
		self:initArenaBottomNode()
		self:initEvents()

		self.is_inited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function map_view:initInfo()
	self.monster_model_list = {}
	self.monster_loaded_num = 0
	self.skew_angle = 60
	self.arena_event_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.arena_show_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.arena_bottom_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.arena_top_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.model_panel:setRotation3D(cc.vec3(self.skew_angle,0,0))
    self.camera = self.ctrl:getScene():getDefaultCamera()
    self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
end

function map_view:initEvents()
	self:pauseArenaListener()
end

function map_view:updateView()
	if Judgment:Instance():getGameStatus() == Judgment.GameStatus.WAIT_ORDER then
		self:showGuide()
	else
		self:hideGuide()
	end
end

function map_view:beginAnimation()
    local ac1 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Wait_Time,0.75))
    local ac2 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Action_Time,1))
    local callback = cc.CallFunc:create(handler(self.ctrl,self.ctrl.startGame))

    local seq = cc.Sequence:create(ac1,ac2,callback)
	
	self:showMask()
	self.root:runAction(seq)
end

function map_view:endAnimation()
	local ac1 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Wait_Time,1))
	local ac2 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Action_Time,0.75))
	local callback = cc.CallFunc:create(handler(self.ctrl,self.ctrl.openResultView))

	local seq = cc.Sequence:create(ac1,ac2,callback)
		
	self.root:runAction(seq)
	self:hideMask()
	self.ctrl:closeBattleInfoView()
end

function map_view:getPositionByInt(num)
	local pos = gtool:intToCcp(num)
	local a,b = self["gezi_"..pos.x.."_"..pos.y]:getPosition()
	return cc.p(a,b)
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------
function map_view:showGuide()
	local cur_active_monster = Judgment:Instance():getCurActiveMonster()
	local gezi_list = cur_active_monster:getAroundInfo()
	
	local a,b = self["gezi_"..gezi_list[0].x.."_"..gezi_list[0].y.."_black"]:getPosition()
	self.cur_monster_pos_sp:setPosition(cc.p(a,b))
	
	for k,v in pairs(gezi_list) do
		if k > 10 and v > 10 then
			self:showCanMoveToGezi(k)
		else
			if v == Judgment.MapItem.ENEMY then
				self:showEnemy(k)
			end
		end
    end
end

function map_view:showOtherAroundInfo(monster)
	self:hideGuide()
	local gezi_list = monster:getAroundInfoToShow()
	local a,b = self["gezi_"..gezi_list[0].x.."_"..gezi_list[0].y.."_black"]:getPosition()
	self.cur_monster_pos_sp:setPosition(cc.p(a,b))
	
	for k,v in pairs(gezi_list) do
		if k > 10 and v > 10 then
			local x,y = math.modf(k/10),k%10
			if self["gezi_"..x.."_"..y.."_black"] then 
				self["gezi_"..x.."_"..y.."_black"]:setVisible(true)
				self["gezi_"..x.."_"..y.."_black"]:setScale(0.1)
				local time = math.random()/3+0.1
				self["gezi_"..x.."_"..y.."_black"]:runAction(cc.FadeIn:create(time))
				self["gezi_"..x.."_"..y.."_black"]:runAction(cc.ScaleTo:create(time,1))
			end
		end
    end
end

function map_view:hideOtherAroundInfo()
	self.cur_monster_pos_sp:setPosition(uitool:farAway())
	for x=1,8 do
		for y=1,7 do
			if self["gezi_"..x.."_"..y.."_black"] then 
				self["gezi_"..x.."_"..y.."_black"]:setOpacity(0)
				self["gezi_"..x.."_"..y.."_black"]:setVisible(false)
			end
		end
	end
	self:showGuide()
end

function map_view:showEnemy(num)
	local cur_active_monster = Judgment:Instance():getCurActiveMonster()
	local atk_img
	
	if cur_active_monster:isMelee() then
		atk_img = self.close_attack_img:clone()
	else
		atk_img = self.far_attack_img:clone()
	end

	local x,y = math.modf(num/10),num%10
	atk_img:setPosition(self["gezi_"..x.."_"..y]:getPosition())

	self.arena_top_node:addChild(atk_img)
	uitool:repeatFadeInAndOut(atk_img)

	local img = atk_img:getChildByName("img")
	uitool:makeImgToButtonHT(img,self.camera,function()
		Judgment:Instance():selectTarget(num)
	end)
end

function map_view:showCanMoveToGezi(num)
	local x,y = math.modf(num/10),num%10
	if self["gezi_"..x.."_"..y.."_black"] then 
		self["gezi_"..x.."_"..y.."_black"]:setVisible(true)
		self["gezi_"..x.."_"..y.."_black"]:setScale(0.1)
		local time = math.random()/3+0.1
		self["gezi_"..x.."_"..y.."_black"]:runAction(cc.FadeIn:create(time))
		self["gezi_"..x.."_"..y.."_black"]:runAction(cc.ScaleTo:create(time,1))
		self.eventDispatcher:resumeEventListenersForTarget(self["gezi_"..x.."_"..y])
	end
end

function map_view:hideGuide()
	self.arena_top_node:removeAllChildren()
	self.cur_monster_pos_sp:setPosition(uitool:farAway())
    for x=1,8 do
    	for y=1,7 do
    		if self["gezi_"..x.."_"..y.."_black"] then 
    			self["gezi_"..x.."_"..y.."_black"]:setOpacity(0)
    			self["gezi_"..x.."_"..y.."_black"]:setVisible(false)
    			self.eventDispatcher:pauseEventListenersForTarget(self["gezi_"..x.."_"..y])
    		end
    	end
    end
end

function map_view:showMask()
	local ac1 = self.mask_img:runAction(cc.FadeOut:create(self.ctrl.Wait_Time))
	local ac2 = self.mask_img:runAction(cc.FadeIn:create(self.ctrl.Action_Time))

	local seq = cc.Sequence:create(ac1,ac2)
	
	self.mask_img:runAction(seq)
end

function map_view:hideMask()
	local ac1 = self.mask_img:runAction(cc.FadeIn:create(self.ctrl.Wait_Time))
	local ac2 = self.mask_img:runAction(cc.FadeOut:create(self.ctrl.Action_Time))

	local seq = cc.Sequence:create(ac1,ac2)
	
	self.mask_img:runAction(seq)
end
--------------------------战场部分开始-------------------------
function map_view:createModel(monster)
    if monster.model then
        self.model_panel:removeChild(monster.model)
        monster.model = nil
    end

	local callback = function(model)
		local node = cc.Node:create()
		model:setScale(0.5)
		
		local pos = monster.start_pos
        local x,y = self["gezi_"..pos.x.."_"..pos.y]:getPosition()
        if not monster:isFly() then
        	node:setPosition(x,y-10)
        else
        	node:setPosition(x,y+10)
        end
		node:addChild(model)
        monster.node = node
		local blood_bar = self:initBloodBar(node,monster)
		self.model_panel:addChild(node)

		monster.model = model
		monster.animation = cc.Animation3D:create(monster.model_path)
		monster:reset()

		
		self.monster_loaded_num = self.monster_loaded_num + 1
		
	end
    cc.Sprite3D:createAsync(monster.model_path,callback)
    
end

function map_view:initBloodBar(node,monster)
	local blood_bar = self.blood_template:clone()
	blood_bar.child = {}
	blood_bar.child.blood_img = blood_bar:getChildByName("blood_img")
	blood_bar.child.level_text = blood_bar:getChildByName("level_text")

	blood_bar.child.blood_img:loadTexture(Config.sprite["team_hp_img_"..monster.team_side])
	blood_bar.child.level_text:setString(monster.level)

	local updateHP = function(percent,damage,type)
		self:createDamageFlyWords(damage,monster,type)
		uitool:setProgressBar(blood_bar.child.blood_img,percent)
	end

	local updateAnger = function(anger)
		for i=1,4 do
			if not (i>anger) then
				blood_bar:getChildByName("star_"..i):setVisible(true)
			else
				blood_bar:getChildByName("star_"..i):setVisible(false)
			end
		end
	end

	blood_bar.updateHP = updateHP
	blood_bar.updateAnger = updateAnger
	blood_bar:setPosition(0,75)
	uitool:setNodeToGlobalTop(blood_bar)
	blood_bar:setName("blood_bar")
	monster.blood_bar = blood_bar
	node:addChild(blood_bar)
end

function map_view:createDamageFlyWords(damage,monster,type)
	local fly_word = self.fly_word_template:clone()
	fly_word:setString(damage)
	fly_word:setTextColor(Config.color["damage_"..type])
	local x,y = monster.node:getPosition()

	fly_word:setPosition(x,y+60)
	fly_word:setScale(0.2)

	self.arena_top_node:addChild(fly_word)

	local ac1 = fly_word:runAction(cc.ScaleTo:create(0.2,1))
	fly_word:stopAction(ac1)
	local ac2 = fly_word:runAction(cc.MoveTo:create(0.5,cc.p(x,y+80)))
	fly_word:stopAction(ac2)
	local ac3 = fly_word:runAction(cc.FadeOut:create(0.1))
	fly_word:stopAction(ac3)
	
	local seq = cc.Sequence:create(ac1,ac2,ac3)

	fly_word:runAction(seq)
end

function map_view:initArena()
	for x=1,8 do
		for y=1,7 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..x.."_"..y] = self.arena_event_node:getChildByName("gezi_"..x.."_"..y)
			self["gezi_"..x.."_"..y.."_black"] = self.arena_bottom_node:getChildByName("gezi_"..x.."_"..y)
			if self["gezi_"..x.."_"..y] then
				self["gezi_"..x.."_"..y].arena_pos = cc.p(x,y)
                self:addArenaListener(self["gezi_"..x.."_"..y])
			end
		end
	end

end

--因为棋盘做过倾斜处理，所以这里要用射线来处理
function map_view:addArenaListener(gezi)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()
		local start_location = touch:getLocation()
		if Judgment:Instance():getGameStatus() == Judgment.GameStatus.WAIT_ORDER then
        	if node:hitTest(start_location, self.camera, nil) then
        		local x,y = node:getPosition()
        		self.moveto_point_sp:setPosition(x,y)
        		self.target_gezi = node
        	end
        	return true
        else
        	return false
        end
    end

    local function touchMoved( touch, event )
        local node = event:getCurrentTarget()
        local cur_location = touch:getLocation()

        if node:hitTest(cur_location, self.camera, nil) then
        	local x,y = node:getPosition()
        	self.moveto_point_sp:setPosition(x,y)
        	self.target_gezi = node
        elseif self.target_gezi and self.target_gezi:getTag() == node:getTag() then
        	self.moveto_point_sp:setPosition(uitool:farAway())
            self.target_gezi = nil
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        local cur_location = touch:getLocation()
        self.moveto_point_sp:setPosition(uitool:farAway())

        if node:hitTest(cur_location, self.camera, nil) then
            Judgment:Instance():selectPos(node)
        end
    end

    gezi.listener = cc.EventListenerTouchOneByOne:create()
    --gezi.listener:setSwallowTouches(true)
    gezi.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    gezi.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    gezi.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.eventDispatcher:addEventListenerWithSceneGraphPriority(gezi.listener, gezi)
end

function map_view:resumeArenaListener()
	
	for x=1,8 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:resumeEventListenersForTarget(self["gezi_"..x.."_"..y])
			end
		end
	end
end

function map_view:pauseArenaListener()
	
	for x=1,8 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:pauseEventListenersForTarget(self["gezi_"..x.."_"..y])
			end
		end
	end
end

function map_view:initArenaBottomNode()
	self.moveto_point_sp 		= self.arena_bottom_node:getChildByName("moveto_point_sp")
	self.cur_monster_pos_sp 	= self.arena_bottom_node:getChildByName("cur_monster_pos_sp")
	self.far_attack_img 		= self.arena_bottom_node:getChildByName("far_attack_img")
	self.close_attack_img 		= self.arena_bottom_node:getChildByName("close_attack_img")
end

function map_view:clearModelPanel()
	self.model_panel:removeAllChildren()
end

--------------------------战场部分结束-------------------------

return map_view