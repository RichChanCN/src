local layout = require("packages.mvc.LayoutBase")

local ready_panel = {}

setmetatable(ready_panel, { __index = layout })

ready_panel.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["arena_node"]			= {["varname"] = "arena_node"},
}

function ready_panel:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)
	self:initArena()
	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function ready_panel:initArena()
	print("ready_panel:initArena()")
	for i=1,7 do
		for j=1,8 do
			self["gezi_"..i.."_"..j] = uitool:seekChildNode(self.arena_node,"gezi_"..j.."_"..i)
		end
	end
end

function ready_panel:initInfo()
	self.gezi_cell_num = 44
end

function ready_panel:initEvents()
	self.back_btn:addClickEventListener(function(sender)
        self:closeView()
    end)

end

function ready_panel:updateView()

end

function ready_panel:openView()
	if not self.isInited then
		self:init()
	end

	local function touchBegan( touch, event )
		local node = event:getCurrentTarget()
		local locationInNode = node:convertToNodeSpace(touch:getLocation())
		local s = node:getContentSize()
		print(locationInNode.x,locationInNode.y)
		local rect = cc.rect(-s.width/2,-s.height/2,s.width/2,s.height/2)
		if cc.rectContainsPoint(rect, locationInNode) then
			print(node:getTag())
			return true
		end

		return false
	end

	local function touchMoved( touch, event )
		local node = event:getCurrentTarget()
		print(node:getPosition())
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	
	for i=1,7 do
		for j=1,8 don   
			if(self["gezi_"..i.."_"..j] ~= nil) then
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener:clone(), self["gezi_"..i.."_"..j])
			end
		end
	end
	self.root:setPosition(uitool:zero())
end

function ready_panel:closeView()
	--local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	--eventDispatcher:removeEventListener(self.listener)
	self.root:setPosition(uitool:farAway())
end

return ready_panel