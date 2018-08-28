monster_factory = {}

require("app.base.monster_class")
require("app.base.range_monster_class")
require("app.base.melee_monster_class")
require("app.base.skill_class")

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


monster_factory.create_monster = function(self, data, team_side, arena_pos, level)
	if data.attack_type < g_config.monster_attack_type.SHOOTER then
		return melee_monster_class:new(data, team_side, arena_pos, level)
	else
		return range_monster_class:new(data, team_side, arena_pos, level)
	end
end