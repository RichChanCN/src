local map_data = {}

map_data.get_map_data_by_chapter_and_level = function(self, chapter_num, level_num)
	local monster_base = require("app.logic.monster_base")
	local raw_data = g_config.Map[chapter_num][level_num]
	local ret_data = {}

	ret_data.chapter_num = chapter_num
	ret_data.level_num = level_num
	ret_data.enable_gezi = {}
	ret_data.other_gezi = {}
	ret_data.enemy_team = {}

	for k, v in pairs(raw_data.arena_info) do
		if v == 0 then
			table.insert(ret_data.enable_gezi, k, v)
		elseif v > 1 and v < 10 then
			table.insert(ret_data.other_gezi, k, v)
		elseif v and v > 100 then
			local enemy = monster_base:instance():new(g_config.monter[v % 100], monster_base.team_side.RIGHT, gtool:int_2_ccp(k))
			table.insert(ret_data.enemy_team, enemy)
		end
	end
	
	ret_data.monster_num_limit = raw_data.monster_num_limit

	ret_data.can_use_monster_list = {}
	if raw_data.can_use_monster_list and type(raw_data.can_use_monster_list) == type({}) then
		for k,v in pairs(raw_data.can_use_monster_list) do
			table.insert(ret_data.can_use_monster_list, g_config.monter[v])
		end
	else
		ret_data.can_use_monster_list = nil
	end

	return ret_data
end

map_data.get_reward_by_chapter_and_level = function(self, chapter_num, level_num)
	return g_config.Map[chapter_num][level_num].reward
end

map_data.get_barrier_model_by_chapter_and_level = function(self, chapter_num, level_num)
	local monster_base = require("app.logic.monster_base")

	return g_config.Map[chapter_num][level_num].barrier_model
end

return map_data