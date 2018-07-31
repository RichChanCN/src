local MonsterBase = {}

MonsterBase.TeamSide = {
	NONE 	= 0,
	LEFT 	= 1,
	RIGHT 	= 2,
}

function MonsterBase:new( data,team_side,pos )
	o = {}
	setmetatable(o, { __index = self })

	team_side = team_side or self.TeamSide.NONE
	pos = pos or cc.p(1,1)

	self.id 					= data.id
	self.name 					= data.name
	self.level 					= data.level
	self.max_hp 				= data.hp
	self.damage 				= data.damage
	self.physical_defense 		= data.physical_defense
	self.magic_defense 			= data.magic_defense
	self.mobility 				= data.mobility
	self.initiative 			= data.initiative
	self.defense_penetration 	= data.defense_penetration
	self.skills_list 			= data.skills_list
	self.team_side				= team_side

	self.buff_list				= {}
	self.debuff_list			= {}
	return o
end

function MonsterBase:reset()
	self.cur_hp = self.max_hp
	self.pos    = cc.p(1,1)

end

function MonsterBase:moveTo(pos)
	
end

function MonsterBase:attack(target)
	
end

function MonsterBase:wait()

end

function MonsterBase:defense()

end

function MonsterBase:dead()

end

function MonsterBase:useSkill(index, target)
	
end
return MonsterBase