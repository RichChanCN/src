local monster_data = {}

monster_data.init = function(self, save_data)
	self._save_data = save_data
	self._collected_monsters = {}

	self:init_collected_monsters()
end

monster_data.get_all_monster_list = function(self)
	return g_config.monster
end

monster_data.get_monster_data_by_id = function(self, id)
	local monster = {}
	for k, v in pairs(g_config.monster[id]) do
		monster[k] = v
	end

	local value = self._save_data:get_monsters_data()[id]
	if value then
		monster.level = value.level
		monster.card_num = value.card_num
	else
		monster.level = 1
		monster.card_num = 0
	end

	return monster
end

monster_data.init_collected_monsters = function(self)
	local monsters = self._save_data:get_monsters_data()
	for key, value in pairs(monsters) do
		self:add_new_monster_in_collected(key, value)
	end
end

monster_data.add_new_monster_in_collected = function(self, key, value)
	local monster = {}
	for k, v in pairs(g_config.monster[key]) do
		monster[k] = v
	end
	monster.level = value.level
	monster.card_num = value.card_num

	table.insert(self._collected_monsters, monster)
end

monster_data.update_collected_monsters = function(self)
	local monsters = self._save_data:get_monsters_data()
	for key, value in pairs(monsters) do
		local is_new = true
		for k, v in pairs(self._collected_monsters) do
			if v.id == key then
				v.card_num = value.card_num
				v.level = value.level
				is_new = false
				break
			end
		end
		
		if is_new then
			self:add_new_monster_in_collected(key, value)
		end
	end
end

monster_data.get_collected_monster_list = function(self)
	self:update_collected_monsters()
	return self._collected_monsters
end

monster_data.get_not_collected_monster_list = function(self)
	local monster_list = {}
	for k, v in pairs(g_config.monster) do
		if not self._save_data:get_monsters_data()[v.id] then
			v.level = 1
			table.insert(monster_list, v)
		end
	end

	return monster_list
end

return monster_data