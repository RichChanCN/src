local save_data = {}

save_data.number_index = {
	["exp"] = 1,
	["level"] = 1,
	["id"] = 1,
	["coin_num"] = 1,
	["crystal_num"] = 1,
	["card_num"] = 1,
}

save_data.init = function(self, ctrl)
	self._ctrl = ctrl
	self._load_file = "save_show.data"
	self._save_file = "data2.data"
	self._collected_monsters = {}
	self:init_info()
	self:load_data()
end

save_data.init_info = function(self)
	self._player = {}
	self._story = {}
	self._monsters = {}
end

save_data.get_star_num_by_chapter_and_level = function(self, chapter_num, level_num)
	if self._story[chapter_num] and self._story[chapter_num][level_num] then
		return tonumber(self._story[chapter_num][level_num])
	else
		return 0
	end
end

save_data.get_player_data = function(self)
	return self._player
end

save_data.init_collected_monsters = function(self)
	for key,value in pairs(self._monsters) do
		self:add_new_monster_in_collected(key, value)
	end
end

save_data.add_new_monster_in_collected = function(self, key, value)
	local monster = {}
	for k, v in pairs(g_config.monter[key]) do
		monster[k] = v
	end
	monster.level = value.level
	monster.card_num = value.card_num

	table.insert(self._collected_monsters, monster)
end

save_data.update_collected_monsters = function(self)
	for key, value in pairs(self._monsters) do
		if self._collected_monsters[key] then
			self._collected_monsters[key].card_num = value.card_num
			self._collected_monsters[key].level = value.level
		else
			self:add_new_monster_in_collected(key, value)
		end
	end
end

save_data.get_collected_monster_list = function(self)
	self:update_collected_monsters()
	return self._collected_monsters
end

save_data.get_not_collected_monster_list = function(self)
	local monster_list = {}
	for k, v in pairs(g_config.monter) do
		if not self._monsters[v.id] then
			table.insert(monster_list, v)
		end
	end

	return monster_list
end

save_data.get_monster_card_num_and_level_by_id = function(self, id)
	if self._monsters[id] then
		return self._monsters[id].card_num, self._monsters[id].level
	else
		return 0, 1
	end
end

save_data.set_star_num = function(self, chapter_num, level_num, num)
	if not self._story[chapter_num] then
		self._story[chapter_num] = {}
		self._story[chapter_num][level_num] = num
	elseif (not self._story[chapter_num][level_num]) or self._story[chapter_num][level_num] < num then
		self._story[chapter_num][level_num] = num
	end
end

save_data.add_monster_card_num = function(self, id, num)
	if self._monsters[id] then
		self._monsters[id].card_num = self._monsters[id].card_num + num
	else
		self._monsters[id] = {}
		self._monsters[id].card_num = num
		self._monsters[id].level = 1
	end
end

save_data.add_coin_num = function(self, num)
	self._player.coin_num = self._player.coin_num + num
end

save_data.add_crystal_num = function(self, num)
	self._player.crystal_num = self._player.crystal_num + num
end

save_data.add_exp = function(self, exp)
	self._player.exp = self._player.exp + exp
	if not (self._player.exp < self._player.cur_max_exp) then
		exp = self._player.exp - self._player.cur_max_exp
		self._player.level = self._player.level + 1
		self._player.exp = 0
		self._player.cur_max_exp = (100 + (self._player.level - 1) * 20)
		self:add_exp(exp)
		uitool:create_top_tip("Level up!", "green")
	end
end

save_data.upgrade_monster = function(self, id)
	if self._monsters[id] and (self._monsters[id].card_num > self._monsters[id].level - 1) then
		self._monsters[id].card_num = self._monsters[id].card_num - self._monsters[id].level
		self._monsters[id].level = self._monsters[id].level + 1
		return true
	else
		return false
	end
end

save_data.get_monster_data_by_id = function(self, id)
	local value = self._monsters[id]
	local monster = {}
	for k, v in pairs(g_config.monter[id]) do
		monster[k] = v
	end
	monster.level = value.level
	monster.card_num = value.card_num

	return monster
end

save_data.load_data = function(self)
	local xml_file = xml.load(g_config.xml_path .. self._load_file)
	self.time = xml_file.time

	for key, value in pairs(self) do
		if type(value) == "table" then
			local object = xml_file:find(key)
			if object ~= nil then
				self[key] = self:load_help(object)
			end
		end
	end

	for k, v in pairs(self._player) do
		if save_data.number_index[k] then
			self._player[k] = tonumber(v)
		end
	end

	for key, value in pairs(self._monsters) do
		for k, v in pairs(value) do
			if save_data.number_index[k] then
				self._monsters[key][k] = tonumber(v)
			end
		end
	end

	for key, value in pairs(self._story) do
		for k, v in pairs(value) do
			self._story[key][k] = tonumber(v)
		end
	end

	self._player.cur_max_exp = (100 + (self._player.level - 1) * 20)

	self:init_collected_monsters()
end

save_data.load_help = function(self, xml)
	local data = {}
	if type(xml) == "table" then
		for index, value in ipairs(xml) do
			if value.id then
				data[tonumber(value.id)] = self:load_help(value)
			elseif type(value) == "table" then
				data[value[0]] = self:load_help(value)
			else
				data = value
			end
		end
	else
		data = xml
	end

	return data
end

save_data.save = function(self)
	self.time = os.date("%Y-%m-%d %H:%M:%S")
	local xml_file = xml.new("save")
	xml_file.time = self.time

	local object = xml_file:append("_player")
	for key, value in pairs(self._player) do
		object:append(key)[1] = value
	end

	local story = xml_file:append("_story")
	for key, value in pairs(self._story) do
		if type(value) == "table" then
			local chapter = story:append("chapter")
			chapter.id = key
			for k1, v1 in pairs(value) do
				local level = chapter:append("level")
				level.id = k1
				level[1] = v1
			end
		else
			object:append(key)[1] = value
		end
	end

	local monsters = xml_file:append("_monsters")
	for key, value in pairs(self._monsters) do
		local monster = monsters:append("monster")
		monster.id = key
		for k1, v1 in pairs(value) do
			monster:append(k1)[1] = v1
		end
	end
	xml_file:save(g_config.xml_path .. self._save_file)
end

return save_data