local MonsterBase = {}

MonsterBase.TeamSide = {
	NONE 	= 0,
	LEFT 	= 1,
	RIGHT 	= 4,
}

MonsterBase.Status = {
	ALIVE 	= 1,
	DEAD 	= 2,

}

MonsterBase.Towards = {
	[0]		= 1,
	[1] 	= 1,
	[2] 	= 2,
	[3] 	= 3,
	[4] 	= 4,
	[5] 	= 5,
	[6] 	= 6,
}

function MonsterBase:new( data,team_side,arena_pos )
	o = {}
	setmetatable(o, self)
	self.__index = self

	team_side = team_side or self.TeamSide.NONE
	pos = pos or cc.p(1,1)

	self.id 					= data.id
	self.name 					= data.name
	self.level 					= data.level
	self.rarity					= data.rarity
	self.cur_hp 				= data.hp
	
	self.skills_list 			= data.skills_list

	self.max_hp 				= data.hp
	self.damage 				= data.damage
	self.physical_defense 		= data.physical_defense
	self.magic_defense 			= data.magic_defense
	self.mobility 				= data.mobility
	self.initiative 			= data.initiative
	self.defense_penetration 	= data.defense_penetration

	self.cur_max_hp 				= self.max_hp 			
	self.cur_damage 				= self.damage 			
	self.cur_physical_defense 		= self.physical_defense 	
	self.cur_magic_defense 			= self.magic_defense 		
	self.cur_mobility 				= self.mobility 			
	self.cur_initiative 			= self.initiative 		
	self.cur_defense_penetration 	= self.defense_penetration
	
	
	self.team_side				= team_side
	self.towards				= MonsterBase.Towards[team_side]
	self.is_waited				= false
	self.start_pos 				= arena_pos
	self.cur_pos 				= arena_pos
	self.status 				= MonsterBase.Status.ALIVE
	self.buff_list				= {}
	self.debuff_list			= {}
	return o
end

function MonsterBase:reset()
	self.cur_hp 					= self.max_hp
	self.cur_pos    				= self.start_pos
	self.status 					= MonsterBase.Status.ALIVE
	self.is_waited					= false

	self.cur_max_hp 				= self.max_hp 			
	self.cur_damage 				= self.damage 			
	self.cur_physical_defense 		= self.physical_defense 	
	self.cur_magic_defense 			= self.magic_defense 		
	self.cur_mobility 				= self.mobility 			
	self.cur_initiative 			= self.initiative 		
	self.cur_defense_penetration 	= self.defense_penetration

	self.buff_list				= {}
	self.debuff_list			= {}
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

function MonsterBase:turnToTarget(target)
	
end

function MonsterBase:updateCurAttribute()
	
end

return MonsterBase