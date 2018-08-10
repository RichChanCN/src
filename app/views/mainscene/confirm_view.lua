local view = require("packages.mvc.ViewBase")

local confirm_view = view:instance()

confirm_view.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_img"]				= {["varname"] = "go_img"},
}

function confirm_view:initInfo()
	self.story_num = 1
	self.level_num = 1
end

function confirm_view:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self.ctrl:closeConfirmView()
    end)
    uitool:makeImgToButton(self.go_img,function(sender)
    	self.ctrl:closeConfirmView()
    	self.ctrl:openSpecificEmbattleView(self.story_num,self.level_num)
    end)
end

function confirm_view:updateInfo(story_num,level_num)
	self.story_num = story_num
	self.level_num = level_num
	-- self.star_num = level_info.star_num
	-- self.reward = level_info.reward
end

function confirm_view:updateView()

end

function confirm_view:openView(story_num,level_num)
	if not self.is_inited then
		self:init()
	end
	self:updateInfo(story_num,level_num)
	self:updateView()
	self.root:setPosition(uitool:zero())
end

return confirm_view