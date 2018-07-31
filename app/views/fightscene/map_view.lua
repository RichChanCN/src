local view = require("packages.mvc.ViewBase")

local map_view = view:instance()

map_view.RESOURCE_BINDING = {
    ["map_img"]				= {["varname"] = "map_img"},
    ["arena_node"]			= {["varname"] = "arena_node"},
}

function map_view:init()
	if not self.isInited then
		uitool:createUIBinding(self, self.RESOURCE_BINDING)

		self:initInfo()
		self:initCamera()
		self:initArena()
		self:initEvents()

		self.isInited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function map_view:initInfo()
	self.arena_node:setRotation3D(cc.vec3(-30,0,0))
	self.camera = nil
end

function map_view:initEvents()

	local x,y = self.gezi_2_7:getPosition()
	print(self.gezi_2_7:getBoundingBox())
	-- print(x,y)
	-- pos = self.gezi_2_7:convertToWorldSpace(cc.p(x,y))
	-- print(pos.x,pos.y)

	-- local x,y = self.arena_node:getPosition()
	-- print(x,y)
	-- pos = self.arena_node:convertToWorldSpace(cc.p(x,y))
	-- print(pos.x,pos.y)

	self:addArenaListener(self.gezi_2_7)

end

function map_view:updateView()
	
end

----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

function map_view:initCamera()
	self.camera = self.ctrl:getScene():getDefaultCamera()
	-- local pos = self.camera:getPosition3D()
	-- pos.z = pos.z*math.cos(math.pi/6)
	-- pos.y = pos.y - 2.5*pos.y*math.sin(math.pi/6)
	-- self.camera:setPosition3D(pos)
	-- self.camera:setRotation3D(cc.vec3(30,0,0))
end


--------------------------战场部分开始-------------------------
function map_view:initArena()
	for i=1,7 do
		for j=1,8 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..i.."_"..j] = self.arena_node:getChildByName("gezi_"..i.."_"..j)
			if self["gezi_"..i.."_"..j] then
				self["gezi_"..i.."_"..j].arena_pos = cc.p(i,j)
			end
		end
	end

end

--因为棋盘做过倾斜处理，所以这里要用射线来处理
function map_view:addArenaListener(img,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()

        local locationInNode = touch:getLocationInView()

        local win_size = cc.Director:getInstance():getWinSizeInPixels()
        local near_p = cc.vec3(locationInNode.x,locationInNode.y,0)
        local far_p = cc.vec3(locationInNode.x,locationInNode.y,1)
        print(near_p.x,near_p.y,near_p.z)
        -- self.camera:unproject(win_size,near_p,near_p)
        far_p = self.camera:unproject(far_p)
        near_p = self.camera:unproject(near_p)
        print(near_p.x,near_p.y,near_p.z)
        print(far_p.x,far_p.y,far_p.z)

        local dir = cc.vec3sub(far_p,near_p)
        print(dir.x,dir.y,dir.z)
        dir = cc.vec3normalize(dir)
        print(dir.x,dir.y,dir.z)

        local ray = cc.Ray:new(near_p,dir)
        local rect = node:getBoundingBox()
        print(ray:intersects(rect))
        -- if self:isTouchInNodeRect(node,touch,event) then
        --     node:setScale(1.06)
        --     return true
        -- end

        return false
    end

    local function touchMoved( touch, event )
        local node = event:getCurrentTarget()

        if self:isTouchInNodeRect(node,touch,event) then
            node:setScale(1.06)
        else
            node:setScale(1.0)
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        
        if self:isTouchInNodeRect(node,touch,event) then
            node:setScale(1.0)
            if callback then
                callback()
            end
        end
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

return map_view