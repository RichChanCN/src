local view = require("packages.mvc.view_base")

local confirm_view = view:instance()

confirm_view.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_img"]				= {["varname"] = "go_img"},
    ["stage_text"]			= {["varname"] = "stage_text"},
    ["star_1_sp"]			= {["varname"] = "star_1_sp"},
    ["star_2_sp"]			= {["varname"] = "star_2_sp"},
    ["star_3_sp"]			= {["varname"] = "star_3_sp"},
    ["info_btn"]			= {["varname"] = "info_btn"},
    ["got_img"]				= {["varname"] = "got_img"},
    ["reward_node"]			= {["varname"] = "reward_node"},
    ["reward_template"]		= {["varname"] = "reward_template"},
}

confirm_view.init_info = function(self)
	self.chapter_num = 1
	self.level_num = 1
	self.reward_list = {}
end

confirm_view.init_events = function(self)
	self.close_btn:addClickEventListener(function(sender)
        self._ctrl:close_confirm_view()
    end)
    uitool:make_img_to_button(self.go_img, function(sender)
    	self._ctrl:close_confirm_view()
    	self._ctrl:open_specific_embattle_view(self.chapter_num, self.level_num)
    end)
end

confirm_view.update_info = function(self, chapter_num, level_num)
	self.reward_data = game_data_ctrl:instance():get_reward_by_chapter_and_level(chapter_num, level_num)
	self.reward_list = {}

	self.star_num = game_data_ctrl:instance():get_star_num_by_chapter_and_level(chapter_num, level_num)
	self.all_star_condition = "emmmmmmmmm"

	self.chapter_num = chapter_num
	self.level_num = level_num
end

confirm_view.update_view = function(self)
	self.stage_text:setString("Stage " .. self.chapter_num .. "-" .. self.level_num)

	for i = 1, 3 do
		local star_sp = "star_" .. i .. "_sp"
		if not (i > self.star_num) then
			self[star_sp]:setTexture(g_config.sprite.lager_star_got)
			self[star_sp]:setScale(1)
		else
			self[star_sp]:setTexture(g_config.sprite.lager_star_empty)
			self[star_sp]:setScale(1.5)
		end
	end
	self:update_reward()
end

confirm_view.update_reward = function(self)
	self.reward_node:removeAllChildren()
	self.got_img:setVisible(false)
	self.reward_node:setVisible(true)
	for k1, v1 in pairs(self.reward_data) do
		if k1 == "monster" then
			for k2, v2 in pairs(v1) do
				local card = self.reward_template:clone()
				uitool:init_monster_card_with_id_and_num(card, k2, v2)
				self.reward_node:addChild(card)
				table.insert(self.reward_list, card)
			end
		elseif (k1 == "coin" or k1 == "crystal") and v1 > 0 then
			local card = self.reward_template:clone()
			uitool:init_other_card_with_type_and_num(card, k1, v1)
			self.reward_node:addChild(card)
			table.insert(self.reward_list, card)
		end
	end
	local offset = 0
	local interval =  self.reward_template:getContentSize().width + 50
	if (#self.reward_list) % 2 == 0 then
		offset = interval / 2
	end
	local mid = math.floor((#self.reward_list) / 2) + 1
	
	for i, v in ipairs(self.reward_list) do
		v:setPosition((i - mid) * interval + offset, 0)
	end
end

confirm_view.on_open = function(self, ...)
	local params = {...}
	self:update_info(params[1], params[2])
	self:update_view()
end


return confirm_view