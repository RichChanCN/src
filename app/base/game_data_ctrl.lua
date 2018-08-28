game_data_ctrl = game_data_ctrl or {}

game_data_ctrl.new = function(self)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	-- 存到本地的数据
	self._save_data 	= {}
	-- 配置里的地图数据
	self._map_data 		= {}
	-- 配置里的怪兽数据
	self._monster_data 	= {}
	-- 注册的场景列表，为广播模式准备
	self._scene_list 	= {}

	return o
end
 
game_data_ctrl.instance = function(self)
	if not self._instance then
		self._instance = self:new()
	end
	return self._instance
end

game_data_ctrl.init = function(self)
 	self._save_data = require("app.data.save_data")
 	self._save_data:init()
 	self._map_data = require("app.data.map_data")
 	self._monster_data = require("app.data.monster_data")
 end

game_data_ctrl.register_scene = function(self, scene)
	self._scene_list[scene:get_name()] = scene
end

game_data_ctrl.get_map_data = function(self)
	return self._map_data
end

game_data_ctrl.get_map_data_by_chapter_and_level = function(self, chapter_num, level_num)
	return self._map_data:get_map_data_by_chapter_and_level(chapter_num, level_num)
end

game_data_ctrl.get_reward_by_chapter_and_level = function(self, chapter_num, level_num)
	return self._map_data:get_reward_by_chapter_and_level(chapter_num, level_num)
end

game_data_ctrl.get_save_data = function(self)
	return self._save_data
end

game_data_ctrl.save_data_to_file = function(self)
	self._save_data:save()
end

game_data_ctrl.set_star_num = function(self, chapter_num, level_num, num)
	self._save_data:set_star_num(chapter_num, level_num, num)
end

game_data_ctrl.add_reward_to_save_data = function(self, reward)
	for k1, v1 in pairs(reward) do
	    if k1 == "monster" then
	        for k2, v2 in pairs(v1) do
	            self._save_data:add_monster_card_num(k2, v2)
	        end
	    elseif k1 == "coin" and v1 > 0 then
	        self._save_data:add_coin_num(v1)
	    elseif k1 == "crystal" and v1 > 0 then
	        self._save_data:add_crystal_num(v1)
	    elseif k1 == "exp" and v1 > 0 then
	        self._save_data:add_exp(v1)
	    end
	end

	self._save_data:save()
end

game_data_ctrl.get_star_num_by_chapter_and_level = function(self, chapter_num, level_num)
	return self._save_data:get_star_num_by_chapter_and_level(chapter_num, level_num)
end

game_data_ctrl.get_player_data = function(self)
	return self._save_data:get_player_data()
end

game_data_ctrl.get_monster_card_num_and_level_by_id = function(self, id)
	return self._save_data:get_monster_card_num_and_level_by_id(id)
end

game_data_ctrl.get_collected_monster_list = function(self)
	return self._save_data:get_collected_monster_list()
end

game_data_ctrl.get_not_collected_monster_list = function(self)
	return self._save_data:get_not_collected_monster_list()
end

game_data_ctrl.get_save_monster_data_by_id = function(self, id)
	return self._save_data:get_monster_data_by_id(id)
end

game_data_ctrl.get_monster_data = function(self)
	return self._monster_data
end

game_data_ctrl.requestUpgradeMonster = function(self, id)
	if self._save_data:upgrade_monster(id) then
		self:save_data_to_file()
	end
end