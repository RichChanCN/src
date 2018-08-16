local SaveData = {}

SaveData.number_index = {
	["exp"] = 1,
	["level"] = 1,
	["id"] = 1,
	["coin_num"] = 1,
	["crystal_num"] = 1,
	["card_num"] = 1,
}

function SaveData:init(ctrl)
	self.ctrl = ctrl
	self.collected_monsters = {}
	self:initInfo()
	self:loadData()
end

function SaveData:initInfo()
	self.player = {}
	self.story = {}
	self.monsters = {}
end

function SaveData:getStarNumByChapterAndLevel(chapter_num, level_num)
	return tonumber(self.story[chapter_num][level_num])
end

function SaveData:getPlayerData()
	return self.player
end

function SaveData:initCollectedMonsters()
	for key,value in pairs(self.monsters) do
		self:addNewMonsterInCollected(key,value)
	end

	table.print(self.collected_monsters)
end

function SaveData:addNewMonsterInCollected(key,value)
	local monster = {}
	for k,v in pairs(Config.Monster[key]) do
		monster[k] = v
	end
	monster.level = value.level
	monster.card_num = value.card_num

	table.insert(self.collected_monsters,monster)
end

function SaveData:updateCollectedMonsters()
	for key,value in pairs(self.monsters) do
		if self.collected_monsters[key] then
			self.collected_monsters[key].card_num = value.card_num
			self.collected_monsters[key].level = value.level
		else
			self:addNewMonsterInCollected(key,value)
		end
	end
end

function SaveData:getCollectedMonsterList()
	self:updateCollectedMonsters()
	return self.collected_monsters
end

function SaveData:getNotCollectedMonsterList()
	local monster_list = {}
	for k,v in pairs(Config.Monster) do
		if not self.monsters[v.id] then
			table.insert(monster_list,v)
		end
	end

	return monster_list
end

function SaveData:getMonsterCardNumAndLevelByID(id)
	if self.monsters[id] then
		return self.monsters[id].card_num,self.monsters[id].level
	else
		return 0,1
	end
end

function SaveData:setStarNum(chapter_num,level_num,num)
	if not self.story[chapter_num] then
		self.story[chapter_num] = {}
		self.story[chapter_num][level_num] = num
	elseif (not self.story[chapter_num][level_num]) or self.story[chapter_num][level_num]<num then
		self.story[chapter_num][level_num] = num
	end
end

function SaveData:addMonsterCardNum(id,num)
	if self.monsters[id] then
		self.monsters[id].card_num = self.monsters[id].card_num + num
	else
		self.monsters[id] = {}
		self.monsters[id].card_num = num
		self.monsters[id].level = 1
	end
end

function SaveData:addCoinNum(num)
	self.player.coin_num = self.player.coin_num + num
end

function SaveData:addCrystalNum(num)
	self.player.crystal_num = self.player.crystal_num + num
end

function SaveData:addExp(exp)
	self.player.exp = self.player.exp + exp
	if not (self.player.exp < self.player.cur_max_exp) then
		self.player.level = self.player.level + 1
		self.player.exp = 0
		exp = exp - self.player.cur_max_exp
		self.player.cur_max_exp = (100+(self.player.level-1)*20)
		self:addExp(exp)
	end
end

function SaveData:upgradeMonster(id)
	if self.monsters[id] and (self.monsters[id].card_num > self.monsters[id].level - 1) then
		self.monsters[id].card_num = self.monsters[id].card_num - self.monsters[id].level
		self.monsters[id].level = self.monsters[id].level+1
		return true
	else
		return false
	end
end

function SaveData:loadData()
	local xmlfile = xml.load(Config.XML_path.."save1.data")
	self.time = xmlfile.time

	for key,value in pairs(self) do
		if type(value) == "table" then
			local object = xmlfile:find(key)
			if object ~= nil then
				self[key] = self:loadHelp(object)
			end
		end
	end

	for k,v in pairs(self.player) do
		if SaveData.number_index[k] then
			self.player[k] = tonumber(v)
		end
	end

	for key,value in pairs(self.monsters) do
		for k,v in pairs(value) do
			if SaveData.number_index[k] then
				self.monsters[key][k] = tonumber(v)
			end
		end
	end

	self.player.cur_max_exp = (100+(self.player.level-1)*20)

	self:initCollectedMonsters()
end

function SaveData:loadHelp(xml)
	local data = {}
	if type(xml) == "table" then
		for index,value in ipairs(xml) do
			if value.id then
				data[tonumber(value.id)] = self:loadHelp(value)
			elseif type(value) == "table" then
				data[value[0]] = self:loadHelp(value)
			else
				data = value
			end
		end
	else
		data = xml
	end

	return data
end

function SaveData:save()
	self.time = os.date("%Y-%m-%d %H:%M:%S")
	local xmlfile = xml.new("save")
	xmlfile.time = self.time

	local object = xmlfile:append("player")
	for key,value in pairs(self.player) do
		object:append(key)[1] = value
	end

	local story = xmlfile:append("story")
	for key,value in pairs(self.story) do
		if type(value) == "table" then
			local chapter = story:append("chapter")
			chapter.id = key
			for k1,v1 in pairs(value) do
				local level = chapter:append("level")
				level.id = k1
				level[1] = v1
			end
		else
			object:append(key)[1] = value
		end
	end

	local monsters = xmlfile:append("monsters")
	for key,value in pairs(self.monsters) do
		local monster = monsters:append("monster")
		monster.id = key
		for k1,v1 in pairs(value) do
			monster:append(k1)[1] = v1
		end
	end
	xmlfile:save(Config.XML_path.."save1.data")
end

return SaveData