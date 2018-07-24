local layout = require("packages.mvc.LayoutBase")

local adventure_panel = {}

setmetatable(adventure_panel, { __index = layout })

adventure_panel.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["chapter_sv"]			= {["varname"] = "chapter_sv"},
	["left_btn"]			= {["varname"] = "left_btn"},
	["right_btn"]			= {["varname"] = "right_btn"},
	["site_1_img"]			= {["varname"] = "site_1_img"},
}

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

    self.site_1_img:addClickEventListener(function(sender)
		self.ctrl:openConfirmView()
    end)
end

function adventure_panel:updateView()

end


return adventure_panel