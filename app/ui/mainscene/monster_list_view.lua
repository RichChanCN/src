local view = require("packages.mvc.view_base")

local monster_list_view = view:instance()

monster_list_view.RESOURCE_BINDING = {
    ["back_btn"]				= {["varname"] = "back_btn"},
    ["monster_lv"]				= {["varname"] = "monster_lv"},
    ["template_panel"]			= {["varname"] = "template_panel"},
}

monster_list_view.init_info = function(self)
	self._card_list = {}
end

monster_list_view.init_events = function(self)
	self.back_btn:addClickEventListener(function(sender)
        self._ctrl:close_monster_list_view()
    end)
end

monster_list_view.update_info = function(self)
    self.collected_monster_list = game_data_ctrl:instance():get_collected_monster_list()
	self.uncollected_monster_list = game_data_ctrl:instance():get_not_collected_monster_list()
end

monster_list_view.update_view = function(self)
	self:init_monster_lv()
end

monster_list_view.on_open = function(self)
	self:update_info()
	self:update_view()
end

monster_list_view.on_close = function(self)
	local collected_title = self.monster_lv:getItem(0):clone()
	self.monster_lv:removeAllItems()

	self.monster_lv:pushBackCustomItem(collected_title)
end
----------------------------------------------------------------
----------------------------------------------------------------

monster_list_view.init_monster_lv = function(self)
	self:init_collected_monster_lv()
	self:init_not_collected_monster_lv()
end

monster_list_view.init_collected_monster_lv = function(self)
	local collected_title = self.monster_lv:getItem(0)
	local title_tip = collected_title:getChildByName("tip_text")

	title_tip:setString(g_config.text.collected_tip)

	local monsters_num = #self.collected_monster_list
	local mod_num = monsters_num % 5
	local rows_num = monsters_num / 5

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local test_item = self.template_panel:clone()
		self:init_lv_item(self.collected_monster_list, test_item, i - 1) --这里-1是为了里面好计算正真的索引值
		self.monster_lv:pushBackCustomItem(test_item)
	end
end

monster_list_view.init_not_collected_monster_lv = function(self)
	local not_collected_title = self.monster_lv:getItem(0):clone()
	local titile_text = not_collected_title:getChildByName("title_text")
	local tip_text = not_collected_title:getChildByName("tip_text")
	
	titile_text:setString("Not Collected")
	tip_text:setString(g_config.text.uncollected_tip)

	self.monster_lv:pushBackCustomItem(not_collected_title)

	local monsters_num = #self.uncollected_monster_list
	local mod_num = monsters_num % 5
	local rows_num = monsters_num / 5

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local test_item = self.template_panel:clone()
		self:init_lv_item(self.uncollected_monster_list, test_item, i - 1) --这里-1是为了里面好计算正真的索引值
		self.monster_lv:pushBackCustomItem(test_item)
	end
end

monster_list_view.init_lv_item = function(self, monster_list ,item, index)
	for i = 1, 5 do
		local cur_index = i + 5 * index
		local cur_monster = {}
		local monster_img_key = "monster_" .. i .. "_img"
		if monster_list[cur_index] then
			cur_monster.head_img = item:getChildByName(monster_img_key)
			cur_monster.head_img:loadTexture(monster_list[cur_index].char_img_path)
			cur_monster.border_img = cur_monster.head_img:getChildByName("border_img")
			cur_monster.border_img:loadTexture(g_config.sprite["card_border_" .. monster_list[cur_index].rarity])
			cur_monster.type_img = cur_monster.head_img:getChildByName("type_img")
			cur_monster.type_img:loadTexture(g_config.sprite["attack_type_" .. monster_list[cur_index].attack_type])
			cur_monster.head_img:addClickEventListener(function(sender)
				self._ctrl:open_monster_info_view(monster_list, cur_index)
			end)
			table.insert(self._card_list, cur_monster.head_img)
		else
			cur_monster.head_img = item:getChildByName(monster_img_key)
			cur_monster.head_img:setVisible(false)
		end
	end
end

monster_list_view.resume_monster_list_listener = function(self)
	for _, v in pairs(self._card_list) do
		self._event_dispatcher:resumeEventListenersForTarget(v)
	end
end

monster_list_view.pause_monster_list_listener = function(self)
	for _, v in pairs(self._card_list) do
		self._event_dispatcher:pauseEventListenersForTarget(v)
	end
end

return monster_list_view