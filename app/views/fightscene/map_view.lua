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
		self:initArena()
		self:initEvents()

		self.isInited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function map_view:initInfo()
	self.arena_node:setRotation3D(cc.vec3(-30,0,0))
    self.camera = self.ctrl:getScene():getDefaultCamera()
end

function map_view:initEvents()

	local x,y = self.gezi_2_7:getPosition()


	self:addArenaListener(self.gezi_2_7)

end

function map_view:updateView()
	
end

----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

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

        local start_location = touch:getLocation()

        print(node:hitTest(start_location, self.camera, nil))

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
--------------------------战场部分结束-------------------------

return map_view