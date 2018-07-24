local LayoutBase = require("packages.mvc.LayoutBase")
local adventure_panel = {}

adventure_panel.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["chapter_sv"]			= {["varname"] = "chapter_sv"},
	["left_btn"]			= {["varname"] = "left_btn"},
	["right_btn"]			= {["varname"] = "right_btn"},
}

function adventure_panel:new( root, ctrl, data )
	local o = LayoutBase:new(root,ctrl,data)
  	setmetatable(o, self)
  	self.__index = self

	return o
end

function adventure_panel:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)
	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function adventure_panel:initInfo()
	self.cur_chapter_num = 1
end

function adventure_panel:initEvents()
	if self.cur_chapter_num == 1 then
		self.left_btn:setVisible(false)
	elseif self.cur_chapter_num == 3 then
		self.right_btn:setVisible(false)
	end

	self.back_btn:addClickEventListener(function(sender)
        self:closeView()
    end)

	self.right_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 1 then
			self.chapter_sv:scrollToPercentHorizontal(50,0.5,true)
			self.cur_chapter_num = 2
			self.left_btn:setVisible(true)
		elseif self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToRight(0.5,true)
			self.cur_chapter_num = 3
			self.right_btn:setVisible(false)
		end
    end)

	self.left_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToLeft(0.5,true)
			self.left_btn:setVisible(false)
			self.cur_chapter_num = 1
		elseif self.cur_chapter_num == 3 then
			self.chapter_sv:scrollToPercentHorizontal(50,0.5,true)
			self.right_btn:setVisible(true)
			self.cur_chapter_num = 2
		end
    end)
end

function adventure_panel:updateView()

end

function adventure_panel:openView()
	self.root:setPosition(uitool:zero())
end

function adventure_panel:closeView()
	self.root:setPosition(uitool:farAway())
end

return adventure_panel