local MapData = {}

function MapData:getMapDataByStoryAndLevel(story_num, level_num)
	local MonsterBase = require("app.logic.MonsterBase")
	local raw_data = Config.Map[story_num][level_num]
	local ret_data = {}

	ret_data.story_num = story_num
	ret_data.level_num = level_num
	ret_data.enable_gezi = {}
	ret_data.other_gezi = {}
	ret_data.enemy_team = {}
	for k,v in pairs(raw_data.arena_info) do
		if v == 0 then
			table.insert(ret_data.enable_gezi,k,v)
		elseif v > 1 and v < 10 then
			table.insert(ret_data.other_gezi,k,v)
		elseif v and v > 100 then
			local enemy = MonsterBase:instance():new(Config.Monster[v%100],MonsterBase.TeamSide.RIGHT,gtool:intToCcp(k))
			table.insert(ret_data.enemy_team,enemy)
		end
	end
	
	ret_data.monster_num_limit = raw_data.monster_num_limit

	ret_data.can_use_monster_list = {}
	if raw_data.can_use_monster_list and type(raw_data.can_use_monster_list) == type({}) then
		for k,v in pairs(raw_data.can_use_monster_list) do
			table.insert(ret_data.can_use_monster_list,Config.Monster[v])
		end
	else
		ret_data.can_use_monster_list = nil
	end

	return ret_data
end

function MapData:getBarrierModelByStoryAndLevel(story_num, level_num)
	local MonsterBase = require("app.logic.MonsterBase")

	return Config.Map[story_num][level_num].barrier_model
end

return MapData