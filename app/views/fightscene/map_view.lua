local view = require("packages.mvc.ViewBase")

local map_view = view:instance()

map_view.RESOURCE_BINDING = {
    ["map_img"]				= {["varname"] = "map_img"},
    ["arena_node"]			= {["varname"] = "arena_node"},
    ["arena_up_node"]		= {["varname"] = "arena_up_node"},
}

function map_view:init()
	if not self.isInited then
		uitool:createUIBinding(self, self.RESOURCE_BINDING)

		self:initInfo()
		self:initArena()
		self:initArenaUpNode()
		self:initEvents()

		self.isInited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function map_view:initInfo()
	self.monster_model_list = {}
	self.arena_node:setRotation3D(cc.vec3(-40,0,0))
	self.arena_up_node:setRotation3D(cc.vec3(-40,0,0))
    self.camera = self.ctrl:getScene():getDefaultCamera()
    self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
end

function map_view:initEvents()
	self.test_monster = {}
	self:createModel(self.test_monster)
end

function map_view:updateView()
	
end

----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

--------------------------战场部分开始-------------------------
function map_view:createModel(monster)
    if monster.model then
        self.arena_node:removeChild(monster.model)
        monster.model = nil
    end

	local callback = function(model)
		model:setScaleX(30)
		model:setScaleY(30)
		model:setScaleZ(30)
		model:setRotation3D(cc.vec3(0,45,0))
		
		model:setGlobalZOrder(1)

        local x,y = self.gezi_2_1:getPosition()
		model:setPosition(x,y-10)
		x,y = self.gezi_7_1:getPosition()
		monster.model = model
		self.arena_node:addChild(model)
	end
    cc.Sprite3D:createAsync(Config.model_path.."cube.obj",callback)
    
end

function map_view:initArena()
	for x=1,8 do
		for y=1,7 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..x.."_"..y] = self.arena_node:getChildByName("gezi_"..x.."_"..y)
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

        return true
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

        table.print(Judgment:Instance().left_team)
        if node:hitTest(cur_location, self.camera, nil) then
            local x,y = node:getPosition()
            self.test_monster.model:runAction((cc.MoveTo:create(0.5,cc.p(x,y))))
        end
        -- if self.target_gezi then
        --     local x,y = self.target_gezi:getPosition()
        --     self.test_monster.model:runAction((cc.MoveTo:create(0.5,cc.p(x,y))))
        -- end
        
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

function map_view:initArenaUpNode()
	self.moveto_point_sp = self.arena_up_node:getChildByName("moveto_point_sp")
end

--------------------------战场部分结束-------------------------

return map_view