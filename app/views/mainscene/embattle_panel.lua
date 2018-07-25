local layout = require("packages.mvc.LayoutBase")

local embattle_panel = layout:instance()

embattle_panel.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["arena_node"]			= {["varname"] = "arena_node"},
}

function embattle_panel:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)
	self:initArena()
	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function embattle_panel:initArena()
	for i=1,7 do
		for j=1,8 do
			--这里为了提高效率，调用了原本的接口，只在一层里面寻找节点。
			self["gezi_"..i.."_"..j] = self.arena_node:getChildByName("gezi_"..i.."_"..j)
		end
	end
end

function embattle_panel:initInfo()
	self.gezi_cell_num = 44
end

function embattle_panel:initEvents()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:openAdventureView()
        self:closeView()
    end)

end

function embattle_panel:updateView()

end

function embattle_panel:openView()
	if not self.isInited then
		self:init()
	end

	local function touchBegan( touch, event )
		return true
	end

	local function touchMoved( touch, event )
		local node = event:getCurrentTarget()
		--local currentPosX,currentPosY = node:getPosition()
		--local diff = touch:getDelta()
		--node:setPosition(cc.p(currentPosX+diff.x,currentPosY+diff.y))
		local locationInNode = node:convertToNodeSpace(touch:getLocation())
		local s = node:getContentSize()
		local rect = cc.rect(0,0,s.width*0.8,s.height*0.8)
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
		local rect = cc.rect(0,0,s.width*0.8,s.height*0.8)
		if cc.rectContainsPoint(rect, locationInNode) then
			node:setScale(1.0)
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	--eventDispatcher:addEventListenerWithSceneGraphPriority(listener:clone(), self.gezi_2_1)
	--注意！！！如果一个界面监听的事件很多会导致降帧！
	for i=1,7 do
		for j=1,2 do 
			if(self["gezi_"..i.."_"..j] ~= nil) then
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener:clone(), self["gezi_"..i.."_"..j])
			end
		end
	end
	self.root:setPosition(uitool:zero())
end

function embattle_panel:closeView()
	--local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	--eventDispatcher:removeEventListener(self.listener)
	self.root:setPosition(uitool:farAway())
end

return embattle_panel