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

function MonsterBase:instance()
	return setmetatable({}, { __index = self })
end

function MonsterBase:new( data,team_side,arena_pos )

	team_side = team_side or self.TeamSide.NONE
	pos = pos or cc.p(1,1)

	self.id 					= data.id
	self.name 					= data.name
	self.level 					= data.level
	self.rarity					= data.rarity
	self.cur_hp 				= data.hp

	self.model_path 			= data.model_path
	
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

	self.tag = self.id*100+self.start_pos.x*10+self.start_pos.y
	
	return self
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

function MonsterBase:getGeziListCanMoveTo()
	if self.cur_mobility < 1 then
		print("can't move!")
	end

	local temp_list = {}
	local return_list = {}
	local findGezi = function(pos)
		if pos.x < 1 or pos.x > 8 or pos.y < 1 or pos.y > 7 then
			return
		end
		return_list[(pos.x+1)*10+pos.y] = true
		return_list[(pos.x-1)*10+pos.y] = true
		return_list[pos.x*10+(pos.y+1)] = true
		return_list[pos.x*10+(pos.y-1)] = true
		return_list[(pos.x+1)*10+(pos.y+1)] = true
		return_list[(pos.x+1)*10+(pos.y-1)] = true
	end

	findGezi(self.cur_pos)
	for k,v in pairs(return_list) do
		table.insert(temp_list,k)
	end

	for i=2,self.cur_mobility do
		for _,v in pairs(temp_list) do
			local x,_ = math.modf(v/10)
			findGezi(cc.p(x,v%10))

			temp_list = {}

			for k,v in pairs(return_list) do
				table.insert(temp_list,k)
			end
		end
	end

	return_list[self.cur_pos.x*10+self.cur_pos.y] = nil

	return return_list
end

function MonsterBase:isDead()
	return self.status == MonsterBase.Status.DEAD
end

function MonsterBase:onActive()
	local ac1 = self.model:runAction(cc.RotateBy:create(1, cc.vec3(0,360,0)))
	local callback = function()
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
	end
	local callback = cc.CallFunc:create(handler(Judgment:Instance(),Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)))
	local seq = cc.Sequence:create(ac1,callback)
	
	self.model:runAction(seq)
end

function MonsterBase:moveTo(pos)
	
end

function MonsterBase:attack(target)
	
end

function MonsterBase:wait()

end

function MonsterBase:defend()

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