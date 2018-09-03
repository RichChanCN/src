local view = require("packages.mvc.view_base")

local adventure_view = view:instance()

adventure_view.RESOURCE_BINDING = 
{
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["chapter_sv"]			= {["varname"] = "chapter_sv"},
	["left_btn"]			= {["varname"] = "left_btn"},
	["right_btn"]			= {["varname"] = "right_btn"},
}

adventure_view.init_ui = function(self)
	for i = 1, #g_config.map do
		local chapter_key = "chapter_" .. i .. "_node"
		self[chapter_key] = self.chapter_sv:getChildByName(chapter_key)
		for j = 1, #g_config.map[i] do
			local site_key = "site_" .. i .. "_" .. j .. "_img"
			self[site_key] = self[chapter_key]:getChildByName(site_key)
		end
	end
end

adventure_view.init_info = function(self)
	self.cur_chapter_num = 1
end

adventure_view.init_events = function(self)

	self.back_btn:addClickEventListener(function(sender)
        self._ctrl:close_adventure_view()
    end)
    
	if self.cur_chapter_num == 1 then
		self.left_btn:setVisible(false)
	elseif self.cur_chapter_num == 3 then
		self.right_btn:setVisible(false)
	end

	self.right_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 1 then
			self.chapter_sv:scrollToPercentHorizontal(50, 0.5, true)
			self.cur_chapter_num = 2
			self.left_btn:setVisible(true)
		elseif self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToRight(0.5, true)
			self.cur_chapter_num = 3
			self.right_btn:setVisible(false)
		end
    end)

	self.left_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToLeft(0.5, true)
			self.left_btn:setVisible(false)
			self.cur_chapter_num = 1
		elseif self.cur_chapter_num == 3 then
			self.chapter_sv:scrollToPercentHorizontal(50, 0.5, true)
			self.right_btn:setVisible(true)
			self.cur_chapter_num = 2
		end
    end)

	for i = 1, 5 do
		self["site_1_" .. i .. "_img"]:addClickEventListener(function(sender)
			self._ctrl:open_confirm_view(1, i)
		end)
	end

end

adventure_view.update_view = function(self)
	for i = 1, #g_config.map do
		for j = 1, #g_config.map[i] do
			local site_key = "site_" .. i .. "_" .. j .. "_img"
			local star_num = game_data_ctrl:instance():get_star_num_by_chapter_and_level(i, j)
			self[site_key]:loadTexture(g_config.sprite["star_" .. star_num .. "_site"])
			
			local challenge_img = self[site_key]:getChildByName("challenged_img")
			if star_num > 2 then
				challenge_img:setVisible(true)
				challenge_img:loadTexture(g_config.sprite.challenge_best)
			elseif star_num > 0 then
				challenge_img:setVisible(true)
				challenge_img:loadTexture(g_config.sprite.challenge_normal)
			else
				challenge_img:setVisible(false)
			end

			for n = 1, 3 do
				local star = self[site_key]:getChildByName("star_" .. n)
				if not (n > star_num) then
					star:loadTexture(g_config.sprite.site_star_get)
				else
					star:loadTexture(g_config.sprite.site_star_empty)
				end
			end
		end
	end
end

adventure_view.on_open = function(self)
	self:update_view()
end

return adventure_view