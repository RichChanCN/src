monster_factory = {}

require("app.logic.monster_class")
require("app.logic.range_monster_class")
require("app.logic.melee_monster_class")

monster_factory.instance = function(self)
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

monster_factory.new = function(self)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	return o
end


monster_factory.create_monster = function(self, data, team_side, arena_pos)
	if data.attack_type < g_config.monster_attack_type.SHOOTER then
		return melee_monster_class:new(data, team_side, arena_pos)
	else
		return range_monster_class:new(data, team_side, arena_pos)
	end
end