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
	self.attack_type			= data.attack_type

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
	self.cur_towads				= self.towards
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
	if not self.model then
		return
	end
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
	self.cur_towads					= self.towards
	self.buff_list				= {}
	self.debuff_list			= {}

	self:towardTo(self.cur_towads)
end

function MonsterBase:getAroundInfo()
	if self.cur_mobility < 1 then
		print("can't move!")
	end

	local map_info = Judgment:Instance():getMapInfo()

	local temp_list = {}
	self.around_info = {}
	local findGezi = function(pos)
		if pos < 10 or pos > 85 or pos%10>7 then
			return
		end
		self:pathFindHelp(pos,pos+10)
		self:pathFindHelp(pos,pos-10)
		self:pathFindHelp(pos,pos+1)
		self:pathFindHelp(pos,pos-1)
		if pos%2 == 0 then
			self:pathFindHelp(pos,pos+11)
			self:pathFindHelp(pos,pos+9)
		else
			self:pathFindHelp(pos,pos-11)
			self:pathFindHelp(pos,pos-9)
		end
	end

	findGezi(gtool:ccpToInt(self.cur_pos))
	for k,v in pairs(self.around_info) do
		table.insert(temp_list,k)
	end

	for i=2,self.cur_mobility do
		for _,v in pairs(temp_list) do
			if not map_info[v] then
				findGezi(v)
			end

			temp_list = {}

			for k,v in pairs(self.around_info) do
				table.insert(temp_list,k)
			end
		end
	end

	for k,v in pairs(map_info) do
		if type(v) == type({}) and v.team_side ~= self.team_side then
			if not self:isMelee() or self:canAttack(k) then
				self.around_info[k] = Judgment.MapItem.ENEMY
			end
		else
			self.around_info[k] = nil
		end
	end
	self.around_info[0] = self.cur_pos
	return self.around_info
end

function MonsterBase:pathFindHelp(pos, num)
	if not self.around_info[num] then
		self.around_info[num] = pos
	end
end

function MonsterBase:isMonster()
	return true
end

function MonsterBase:isDead()
	return self.status == MonsterBase.Status.DEAD
end

function MonsterBase:isMelee()
	return self.attack_type < Config.Monster_attack_type.SHOOTER
end

function MonsterBase:onActive()
	local ac1 = self.model:runAction(cc.RotateBy:create(1, cc.vec3(0,360,0)))
	local cb = function()
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,callback)
	
	self.model:runAction(seq)
end

function MonsterBase:moveTo(pos)
	pos.y = pos.y - 10
	local ac1 = self.model:runAction(cc.MoveTo:create(0.5,pos))
	local cb = function()
		Judgment:Instance():nextMonsterActivate()
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,callback)
	
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	self.model:runAction(seq)
end

function MonsterBase:attack(target)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	self.model:runAction(cc.RotateBy:create(0.5, cc.vec3(0,360,0)))

	target:beAttacked(self)
end

function MonsterBase:beAttacked(murderer)
	self.cur_hp = self.cur_hp - murderer.cur_damage
	print("self.cur_hp "..self.cur_hp)
	if self.cur_hp < 1 then
		self:die()
	else
		local ac1 = self.model:runAction(cc.ScaleTo:create(0.5,30*self.cur_hp/self.max_hp))
		local cb = function()
			Judgment:Instance():nextMonsterActivate()
		end
		local callback = cc.CallFunc:create(cb)
		local seq = cc.Sequence:create(ac1,callback)
		
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
		
		self.model:runAction(seq)
	end
end

function MonsterBase:wait()
	if self.is_waited then
		print("you has been waited!")
	else
		self.is_waited = true
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
		Judgment:Instance():nextMonsterActivate(true)
	end
end

function MonsterBase:defend()
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	Judgment:Instance():nextMonsterActivate()
end

function MonsterBase:die()
	self.status = MonsterBase.Status.DEAD
	local ac1 = self.model:runAction(cc.ScaleTo:create(0.5,30))
	local ac2 = self.model:runAction(cc.FadeOut:create(1))
	local cb = function()
		Judgment:Instance():checkGameOver()
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,ac2,callback)
	
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	self.model:runAction(seq)

end

function MonsterBase:useSkill(index, target)
	
end

function MonsterBase:turnToTarget(target)
	
end

function MonsterBase:towardTo(num)
	self.model:setRotation3D(cc.vec3(0,(num-1)*60,0))
end

function MonsterBase:canAttack(num)
	if num%2 == 0 then
		if self.around_info[num+10]
			or self.around_info[num-10]
			or self.around_info[num+1]
			or self.around_info[num-1]
			or self.around_info[num+11]
			or self.around_info[num+9] then
			
			return true
		end
	else
		if self.around_info[num+10]
			or self.around_info[num-10]
			or self.around_info[num+1]
			or self.around_info[num-1]
			or self.around_info[num-11]
			or self.around_info[num-9] then
			
			return true
		end
	end

	return false
end

function MonsterBase:distanceBetweenPos(num1,num2)
	local min = math.min(num1,num2)
	local max = math.min(num1,num2)
	if max - min == 0 then
		return 0
	end
end

function MonsterBase:updateCurAttribute()
	
end

return MonsterBase