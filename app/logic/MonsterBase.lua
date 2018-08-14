local MonsterBase = {}

MonsterBase.TeamSide = {
	NONE 	= 0,
	LEFT 	= 1,
	RIGHT 	= 4,
}

MonsterBase.DamageLevel = {
    MISS 		= 0,
    LOW 		= 1,
	COMMON 		= 2,
	HIGH 		= 3,
	HIGHER 		= 4,
	HIGHEST 	= 5,
	SKILL 		= 6,
	HEAL		= 7,
	POISON 		= 8,
}

MonsterBase.Status = {
	DEAD 		= 0,
	ALIVE 		= 1,
	DEFEND 		= 2,
	WAITING 	= 3,
	CANT_ATTACK = 100,
	CANT_ACTIVE = 1000,
	STUN 		= 1001,
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
	self.max_hp 				= data.hp
	self.attack_type			= data.attack_type
	self.move_type 				= data.move_type
	
	self.model_path 			= data.model_path
	self.char_img_path			= data.char_img_path

	self.max_anger				= data.anger
	
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

	self.cur_anger				= 0
	self.cur_hp 				= self.max_hp
	self.steps 					= self.cur_mobility
	self.cur_towards				= self.towards
	
	self.team_side				= team_side
	self.towards				= MonsterBase.Towards[team_side]
	self.has_waited				= false
	self.start_pos 				= arena_pos
	self.cur_pos 				= arena_pos
	self.status 				= MonsterBase.Status.ALIVE
	self.buff_list				= {}
	self.debuff_list			= {}

	self.tag = self.id*100+self.start_pos.x*10+self.start_pos.y
	
	if data.skill then
		local SkillBase = require("app.logic.SkillBase")
		self.skill = SkillBase:instance():new(self,data.skill)
	end

	return self
end

function MonsterBase:getTag()
	return self.tag
end

function MonsterBase:getCurPosNum()
	return gtool:ccpToInt(self.cur_pos)
end

function MonsterBase:getCurDamage()
	self.cur_damage = self.damage

	self:updateCurAttribute()

	return self.cur_damage
end

function MonsterBase:getCurMaxHp()
	self.cur_max_hp = self.max_hp

	self:updateCurAttribute()

	return self.cur_max_hp
end

function MonsterBase:getCurPysicalDefense()
	self.cur_physical_defense = self.physical_defense
	
	self:updateCurAttribute()

	return self.cur_physical_defense
end

function MonsterBase:getCurMagicDefense()
	self.cur_magic_defense = self.magic_defense
	
	self:updateCurAttribute()

	return self.cur_magic_defense
end

function MonsterBase:getCurMobility()
	self.cur_mobility = self.mobility
	
	self:updateCurAttribute()

	return self.cur_mobility
end

function MonsterBase:getCurInitiative()
	self.cur_initiative = self.initiative
	
	self:updateCurAttribute()

	return self.cur_initiative
end

function MonsterBase:getCurDefensePenetration()
	self.cur_defense_penetration = self.defense_penetration
	
	self:updateCurAttribute()

	return self.cur_defense_penetration
end

function MonsterBase:getAliveEnemyMonsters()
	local enemy_list
	if self:isPlayer() then
		enemy_list = Judgment:Instance():getRightAliveMonsters()
	else
		enemy_list = Judgment:Instance():getLeftAliveMonsters()
	end

	return enemy_list
end

function MonsterBase:getAliveFriendMonsters()
	local friend_list
	if not self:isPlayer() then
		friend_list = Judgment:Instance():getRightAliveMonsters()
	else
		friend_list = Judgment:Instance():getLeftAliveMonsters()
	end

	return friend_list
end

function MonsterBase:reset()
	if not self.model and self.animation and self.node then
		return
	end

	self.cur_anger					= 0
	self.cur_hp 					= self.max_hp
	self.cur_pos    				= self.start_pos
	self.cur_towards				= self.towards

	self.cur_max_hp 				= self.max_hp 			
	self.cur_damage 				= self.damage 			
	self.cur_physical_defense 		= self.physical_defense 	
	self.cur_magic_defense 			= self.magic_defense 		
	self.cur_mobility 				= self.mobility 			
	self.cur_initiative 			= self.initiative 		
	self.cur_defense_penetration 	= self.defense_penetration

	self.has_waited					= false

	self.steps 						= self.cur_mobility
	self.buff_list					= {}
	self.debuff_list				= {}

	self:towardTo(self.cur_towards)

	self:changeMonsterStatus(MonsterBase.Status.ALIVE)
end

function MonsterBase:isMonster()
	return true
end

function MonsterBase:isFly()
	return self.move_type == Config.Monster_move_type.FLY
end

function MonsterBase:isDead()
	return self.status == MonsterBase.Status.DEAD
end

function MonsterBase:isDefend()
	return self.status == MonsterBase.Status.DEFNED
end

function MonsterBase:isMelee()
	return self.attack_type < Config.Monster_attack_type.SHOOTER
end

function MonsterBase:isPhysical()
	return self.attack_type%2 == 1
end

function MonsterBase:hasWaited()
	return self.has_waited
end

function MonsterBase:isPlayer()
	return self.team_side == MonsterBase.TeamSide.LEFT
end

function MonsterBase:isEnemy(monster)
	return self.team_side ~= monster.team_side
end

function MonsterBase:isBeBackAttacked(murderer)
	return self.cur_towards == murderer.cur_towards
end

function MonsterBase:isBeSideAttacked(murderer)
	return self.cur_towards+1 == murderer.cur_towards
			or self.cur_towards+1 == murderer.cur_towards + 6
			or self.cur_towards-1 == murderer.cur_towards
			or self.cur_towards-1 == murderer.cur_towards - 6
end

function MonsterBase:canCounterAttack(murderer)
	return self:isMelee()
			and self:canAttack()
			and murderer:isMelee() 
			and self:isNear(gtool:ccpToInt(murderer.cur_pos)) 
			and not(self:isBeSideAttacked(murderer) or self:isBeBackAttacked(murderer))
end

function MonsterBase:canUseSkill()
	return self.skill and not(self.cur_anger < self.skill.cost)
end

function MonsterBase:canActive()
	return (not self:isDead()) and self.status < MonsterBase.Status.CANT_ACTIVE
end

function MonsterBase:canAttack()
	return self.status < MonsterBase.Status.CANT_ATTACK
end

function MonsterBase:onEnterNewRound(round_num)
	self.has_waited = false
end


----------------------------自动触发----------------------------------
----------------------------自动触发----------------------------------
----------------------------自动触发----------------------------------
function MonsterBase:onActive(round_num)
	if not self:hasWaited() then
		self:dealWithAllBuff()
		self.steps = self:getCurMobility()
	end

	if self:canActive() then
		self:Active()
	else
		Judgment:Instance():nextMonsterActivate()
	end
end

function MonsterBase:Active()
	local ac1 = self.node:runAction(cc.Blink:create(0.5, 2))
	self.node:stopAction(ac1)
	local cb = function()
		self.node:setVisible(true)
		if self:isPlayer() and not Judgment:Instance():getAuto() then
			self:changeMonsterStatus(MonsterBase.Status.ALIVE)
			Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
		else
			self:runAI()
		end
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,callback)
	
	self.node:runAction(seq)
end

function MonsterBase:updateCurAttribute()
	for k,v in pairs(self.buff_list) do
		v.apply(self)
	end

	for k,v in pairs(self.debuff_list) do
		v.apply(self)
	end

end

----------------------------主动触发----------------------------------
----------------------------主动触发----------------------------------
----------------------------主动触发----------------------------------
function MonsterBase:moveTo(arena_pos,attack_target,skill_target_pos)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUNNING)
	local cb = function()
		self.cur_pos = arena_pos
		if attack_target then
			local distance = self:getDistanceToPos(attack_target:getCurPosNum(),true)
			self:attack(attack_target,distance)
		elseif skill_target_pos then
			self:useSkill(skill_target_pos)
		else
			self:changeMonsterStatus(MonsterBase.Status.ALIVE)
			if self:nothingCanDo() then
				Judgment:Instance():nextMonsterActivate()
			else
				Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
			end
		end
	end
	local callback = cc.CallFunc:create(handler(self,cb))
	if gtool:ccpToInt(arena_pos) == self:getCurPosNum() then
		cb()
	else
		self:repeatAnimation("walk")
		self:moveFollowPath(arena_pos,callback)
	end
end

function MonsterBase:attack(target,distance)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUNNING)
	
	if self:isMelee() and not self:isNear(gtool:ccpToInt(target.cur_pos)) then
		self:moveAndAttack(target)
	else
		self:addAnger()
		local cur_num = self:getCurPosNum()
		local to_num = gtool:ccpToInt(target.cur_pos)
		self:towardToIntPos(cur_num,to_num)
		self:doAnimation("attack1")
		target:beAttacked(self,false,distance)
	end
end

function MonsterBase:wait(is_auto)
	if self:hasWaited() then
		if is_auto then
			self:defend()
		else
			print("you has been waited!")
		end
	else
		self:changeMonsterStatus(MonsterBase.Status.WAITING)
		self.has_waited = true
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUNNING)
		Judgment:Instance():nextMonsterActivate(true)
	end
end

function MonsterBase:defend()
	self:changeMonsterStatus(MonsterBase.Status.DEFEND)
	self:addBuff({Config.Buff.defend})
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUNNING)
	Judgment:Instance():nextMonsterActivate()
end

function MonsterBase:useSkill(target_pos_num)
	if (not self.skill:isNeedTarget()) or (self:isMelee() and self:isNear(target_pos_num)) or (not self:isMelee()) then
		self.skill:play()
		self:minusAnger(self.skill.cost)
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUNNING)
		local cb = function()
			self.skill:use(target_pos_num)
		end
		local callback = cc.CallFunc:create(cb)
		self:towardToIntPos(self:getCurPosNum(), target_pos_num)
		self:doAnimation("skill", callback)
	else
		self:moveAndUseSkill(target_pos_num)
	end
end
----------------------------被动触发----------------------------------
----------------------------被动触发----------------------------------
----------------------------被动触发----------------------------------

function MonsterBase:die(is_buff_or_skill)
	self.status = MonsterBase.Status.DEAD
	self.card.removeSelf(self.card)
	local ac = self.model:runAction(cc.FadeOut:create(1))
	local cb = function()
		self.node:setVisible(false)
		if not Judgment:Instance():isGameOver() then
			Judgment:Instance():checkGameOver(is_buff_or_skill)
		end
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac,callback)
	self:doAnimation("die", seq)
end

function MonsterBase:beAttacked(murderer, is_counter_attack,distance)
	local damage,damage_type = self:getFinalAttackDamage(murderer,distance)

	if self:minusHP(damage,damage_type) then
		self:addAnger()
		local cb = function()
			local cur_num = self:getCurPosNum()
			local to_num = gtool:ccpToInt(murderer.cur_pos)
			if (not is_counter_attack) and self:canCounterAttack(murderer) then
				self:towardToIntPos(cur_num, to_num)
				self:counterAttack(murderer)
			else
				self:towardToIntPos(cur_num, to_num)
				Judgment:Instance():nextMonsterActivate()
			end
		end
		local callback = cc.CallFunc:create(handler(self,cb))
		self:doAnimation("beattacked", callback)
	end
end

function MonsterBase:counterAttack(target)
	local cur_num = self:getCurPosNum()
	local to_num = gtool:ccpToInt(target.cur_pos)
	self:towardToIntPos(cur_num,to_num)
	self:doAnimation("attack1")
	self:addAnger()
	target:beAttacked(self,true)
end

function MonsterBase:beAffectedBySkill(skill, is_last)
	if self:isEnemy(skill.caster) then
		if skill.damage > 0 then
			local damage,damage_type = self:getFinalSkillDamage(skill)
			self:minusHP(damage,damage_type,true)
		end
		if #skill.debuff > 0 then
			self:addDeBuff(skill.debuff)
		end
	else
		if skill.healing > 0 then
			local healing,htype = self:getFinalhealing(skill)
			self:addHP(healing,htype)
		end
		if #skill.buff > 0 then
			self:addBuff(skill.buff)
		end
	end

	if is_last then 
		local cb = function()
			Judgment:Instance():nextMonsterActivate()
		end
		local callback = cc.CallFunc:create(cb)
		self:doSomethingLater(callback,0.6)
	end
end

function MonsterBase:towardTo(num)
	self.cur_towards = num
	self.model:setRotation3D(cc.vec3(0,(1-num)*60,0))
end


function MonsterBase:towardToIntPos(cur_num,to_num,only_get)
	if not to_num then 
		return
	end

	local result_towards

	local towardToHelp = function ()
		local to_pos = gtool:intToCcp(to_num)
		local cur_pos = gtool:intToCcp(cur_num)
		if to_num > cur_num then
			if to_pos.x-cur_pos.x>math.abs(to_pos.y-cur_pos.y) then
				result_towards = 1
			elseif to_pos.y>cur_pos.y then
				result_towards = 6
			else
				result_towards = 2
			end
		else
			if cur_pos.x-to_pos.x>math.abs(to_pos.y-cur_pos.y) then
				result_towards = 4
			elseif to_pos.y>cur_pos.y then
				result_towards = 5
			else
				result_towards = 3
			end
		end
	end

	local deta = to_num - cur_num
	if cur_num%2 == 0 then
		if deta == 10 then
			result_towards = 1
		elseif deta == 9 then
			result_towards = 2
		elseif deta == -1 then
			result_towards = 3
		elseif deta == -10 then
			result_towards = 4
		elseif deta == 1 then
			result_towards = 5
		elseif deta == 11 then
			result_towards = 6
		else
			towardToHelp()
		end
	else
		if deta == 10 then
			result_towards = 1
		elseif deta == -1 then
			result_towards = 2
		elseif deta == -11 then
			result_towards = 3
		elseif deta == -10 then
			result_towards = 4
		elseif deta == -9 then
			result_towards = 5
		elseif deta == 1 then
			result_towards = 6
		else
			towardToHelp()
		end
	end

	if only_get then
		return result_towards
	else
		self:towardTo(result_towards)
	end
end
----------------------------伤害治疗计算血量怒气----------------------------------
----------------------------伤害治疗计算血量怒气----------------------------------
----------------------------伤害治疗计算血量怒气----------------------------------
function MonsterBase:getFinalAttackDamage(murderer,distance)
	local damage = murderer:getCurDamage()
	local damage_type = MonsterBase.DamageLevel.COMMON

	if self:isBeBackAttacked(murderer) then
		damage = damage * 1.5
		damage_type = MonsterBase.DamageLevel.HIGHER
	elseif self:isBeSideAttacked(murderer) then
		damage = damage * 1.2
		damage_type = MonsterBase.DamageLevel.HIGH
	end

	
	local defense
	if murderer:isPhysical() then
		defense = self:getCurPysicalDefense() - murderer:getCurDefensePenetration()
	else
		defense = self:getCurMagicDefense() - murderer:getCurDefensePenetration()
	end
	damage = damage * (1 - defense/(defense + 10))
	
	if not murderer:isMelee() then
		if distance > 5 then
			damage = damage * (1 - (distance - 5)*2/10)
			damage_type = MonsterBase.DamageLevel.LOW
		elseif distance < 3 then
			damage = damage * (1 - (3 - distance)/10)
			damage_type = MonsterBase.DamageLevel.LOW
		else
			damage = damage * 1.2
			damage_type = MonsterBase.DamageLevel.HIGH
		end
	end

	damage = damage + (math.random() - 0.5) * 10

	if damage < 1 then
		damage = 1
	end

	return math.floor(damage), damage_type
end

function MonsterBase:getFinalhealing(skill)
	local healing = skill.healing

	healing = healing + skill.caster.level*skill.healing_level_plus

	return healing, MonsterBase.DamageLevel.HEAL
end

function MonsterBase:getFinalSkillDamage(skill)
	local damage = skill.damage
	local caster = skill.caster

	damage = damage + caster.level*skill.damage_level_plus

	local defense
	if caster:isPhysical() then
		defense = self:getCurPysicalDefense() - caster:getCurDefensePenetration()
	else
		defense = self:getCurMagicDefense() - caster:getCurDefensePenetration()
	end

	damage = damage * (1 - defense/(defense + 10))

	damage = damage + (math.random() - 0.5) * 20

	if damage < 1 then
		damage = 1
	end

	return math.floor(damage), MonsterBase.DamageLevel.SKILL
end

function MonsterBase:addHP(healing,htype)
	local hp = self.cur_hp + healing

	local max_hp = self:getCurMaxHp()
	if hp>max_hp then
		hp = max_hp
	end

	local cb = function()
		self.blood_bar.updateHP(hp/self.max_hp,healing,htype)
	end
	local callback = cc.CallFunc:create(handler(self,cb))
	self:doSomethingLater(callback,0.3)
	self:setHP(hp)
end

function MonsterBase:minusHP(damage,damage_type,is_buff_or_skill)
	local hp = self.cur_hp - damage

	local cb = function()
		self.blood_bar.updateHP(hp/self.max_hp,damage,damage_type)
		if hp<1 then
			self:die()
		end
	end
	if not is_buff_or_skill then
		local callback = cc.CallFunc:create(handler(self,cb))
		self:doSomethingLater(callback,0.5)
	else
		self.blood_bar.updateHP(hp/self.max_hp,damage,damage_type)
		if hp<1 then
			self:die(is_buff_or_skill)
		end
	end

	self:setHP(hp)

	if hp > 0 then
		return true
	else
		return false
	end
end

function MonsterBase:setHP(hp)
	if hp<0 then
		hp = 0
	end
	local max_hp = self:getCurMaxHp()
	if hp>max_hp then
		hp = max_hp
	end
	self.cur_hp = hp
end

function MonsterBase:addAnger(num)
	if self.cur_anger>self.max_anger-1 then 
		return
	end
	num = num or 1

	self:setAnger(self.cur_anger + num)
end

function MonsterBase:minusAnger(num)
	self:setAnger(self.cur_anger - num)
end

function MonsterBase:setAnger(angle)
	self.cur_anger = angle

	local cb = function()
		self.card.update(self.cur_anger)
		self.blood_bar.updateAnger(self.cur_anger)
	end
	local callback = cc.CallFunc:create(handler(self,cb))

	self:doSomethingLater(callback,0.5)
end
----------------------------buff相关----------------------------------
----------------------------buff相关----------------------------------
----------------------------buff相关----------------------------------
function MonsterBase:addBuff(buff_list)
	for k,v in pairs(buff_list) do
		local buff = v:clone()
		buff.affect_round = 0
		buff.begin(self)
		table.insert(self.buff_list,buff)
	end
end

function MonsterBase:addDeBuff(debuff_list)
	for k,v in pairs(debuff_list) do
		local buff = v:clone()
		buff.affect_round = 0
		buff.begin(self)
		table.insert(self.debuff_list,buff)
	end
end

function MonsterBase:dealWithAllBuff()
	for k,v in pairs(self.buff_list) do
		if v.affect_round<v.round then
			v.affect_round = v.affect_round + 1
			v.once_a_round(self)
		else
			v.finish(self)
			table.remove(self.buff_list,k)
		end
	end

	for k,v in pairs(self.debuff_list) do
		if v.affect_round<v.round then
			v.affect_round = v.affect_round + 1
			v.once_a_round(self)
		else
			v.finish(self)
			table.remove(self.debuff_list,k)
		end
	end
end

----------------------------攻击 技能辅助----------------------------------
----------------------------攻击 技能辅助----------------------------------
----------------------------攻击 技能辅助----------------------------------

function MonsterBase:moveAndAttack(target)
	local num = gtool:ccpToInt(target.cur_pos)
	local pos = gtool:intToCcp(self:getBackFirstNearPosNum(num,target.cur_towards))

	self:moveTo(pos,target)
end

function MonsterBase:moveAndUseSkill(target_pos_num)
	local pos = gtool:intToCcp(self:getNearPosNum(target_pos_num))

	self:moveTo(pos,nil,target_pos_num)
end

function MonsterBase:moveFollowPath(arena_pos,callback_final)
	local num = gtool:ccpToInt(arena_pos)
	local path = self:getPathToPos(num)
	self.steps = self.steps - #path
	
	local ac_table  = {}
	local next_pos

	for i=#path,1,-1 do
		local pos = Judgment:Instance():getPositionByInt(path[i])
		
		if self:isFly() then
			pos.y = pos.y+10
		else
			pos.y = pos.y-10
		end
		
		local action = self.node:runAction(cc.MoveTo:create(0.5,pos))
		self.node:stopAction(action)
		local cb = function()
			self:towardToIntPos(path[i],path[i-1])
		end
		local callback = cc.CallFunc:create(handler(self,cb))
		local seq = cc.Sequence:create(action,callback)
		table.insert(ac_table,seq)
	end
	
	table.insert(ac_table,callback_final)

	local all_seq = cc.Sequence:create(unpack(ac_table))
	self:towardToIntPos(self:getCurPosNum(),path[#path])
	self.node:runAction(all_seq)
end

function MonsterBase:getDistanceToPos(num,update)
	if update then
		self.distance_info = self:getDistanceInfo()
	end
	return self.distance_info[num]
end

function MonsterBase:getDistanceInfo()
	local distanc_table = {}
    local temp_list = {}
    
    local pathFindHelp = function(num,step)
        if not distanc_table[num] and gtool:isLegalPosNum(num) then
            distanc_table[num] = step
        end
    end
    
    local findGezi = function(pos,step)
        pathFindHelp(pos+10,step)
        pathFindHelp(pos-10,step)
        pathFindHelp(pos+1,step)
        pathFindHelp(pos-1,step)
        if pos%2 == 0 then
            pathFindHelp(pos+11,step)
            pathFindHelp(pos+9,step)
        else
            pathFindHelp(pos-11,step)
            pathFindHelp(pos-9,step)
        end
    end

    findGezi(self:getCurPosNum(),1)
    for k,v in pairs(distanc_table) do
        table.insert(temp_list,k)
    end

	local steps = math.abs(self.cur_pos.x - 4) + math.abs(self.cur_pos.y - 4) + 4
	if steps > 8 then 
		steps = 8 
	end

    for i=2,steps do
        for _,v in pairs(temp_list) do
            findGezi(v,i)      
        end
        temp_list = {}

        for k,v in pairs(distanc_table) do
            table.insert(temp_list,k)
        end
    end

    return distanc_table
end
----------------------------移动辅助----------------------------------
----------------------------移动辅助----------------------------------
----------------------------移动辅助----------------------------------

function MonsterBase:getAroundInfo(is_to_show)
	local steps = self.steps
	if is_to_show then
		if steps < 1 and not self:hasWaited() then
			steps = self:getCurMobility()
		end
	end

	local map_info = Judgment:Instance():getMapInfo()
	self.can_reach_area_info = {}

	if steps>0 then
		
		self.can_reach_area_info = self:getCanReachAreaInfo(self:getCurPosNum(),map_info,steps)

		if self:isFly() then
			self.fly_path = self:getFlyPath()
		end

		for k,v in pairs(map_info) do
			if type(v) == type({}) and v.team_side == self.team_side then
				self.can_reach_area_info[k] = Judgment.MapItem.FRIEND
			end
		end
	end

	local can_attack_table = {}
	for k,v in pairs(map_info) do
		if type(v) == type({}) and v.team_side ~= self.team_side then
			if self:canReachAndAttack(k) then
				table.insert(can_attack_table,k)
			else
				self.can_reach_area_info[k] = nil
			end
		else 
			self.can_reach_area_info[k] = nil
		end
	end

	self.distance_info = self:getDistanceInfo()
	
	for k,v in pairs(can_attack_table) do
		self.can_reach_area_info[v] = Judgment.MapItem.ENEMY*100 + self:getDistanceToPos(v)
	end
	
	self.can_reach_area_info[0] = self.cur_pos
	return self.can_reach_area_info
end

function MonsterBase:getCanReachAreaInfo(center_pos_num,map_info,steps)
    local area_table = {}
    local temp_list = {}
    
    local pathFindHelp = function(pos, num)
        if not area_table[num] and gtool:isLegalPosNum(num) and ((not map_info[num]) or self:isFly()) then
            
            area_table[num] = pos
        end
    end
    
    local findGezi = function(pos)
        pathFindHelp(pos,pos+10)
        pathFindHelp(pos,pos-10)
        pathFindHelp(pos,pos+1)
        pathFindHelp(pos,pos-1)
        if pos%2 == 0 then
            pathFindHelp(pos,pos+11)
            pathFindHelp(pos,pos+9)
        else
            pathFindHelp(pos,pos-11)
            pathFindHelp(pos,pos-9)
        end
    end

    findGezi(center_pos_num)
    for k,v in pairs(area_table) do
        table.insert(temp_list,k)
    end

    for i=2,steps do
        for _,v in pairs(temp_list) do

            findGezi(v)
            
        end
        temp_list = {}

        for k,v in pairs(area_table) do
            table.insert(temp_list,k)
        end
    end

    return area_table
end

function MonsterBase:getFlyPath()
    local fly_path = {}
    local temp_list = {}
    
    local pathFindHelp = function(pos, num)
        if not fly_path[num] and gtool:isLegalPosNum(num) then
            fly_path[num] = pos
        end
    end
    
    local findGezi = function(pos)
        pathFindHelp(pos,pos+10)
        pathFindHelp(pos,pos-10)
        pathFindHelp(pos,pos+1)
        pathFindHelp(pos,pos-1)
        if pos%2 == 0 then
            pathFindHelp(pos,pos+11)
            pathFindHelp(pos,pos+9)
        else
            pathFindHelp(pos,pos-11)
            pathFindHelp(pos,pos-9)
        end
    end

    findGezi(self:getCurPosNum())
    for k,v in pairs(fly_path) do
        table.insert(temp_list,k)
    end

	local steps = math.abs(self.cur_pos.x - 4) + math.abs(self.cur_pos.y - 4) + 4
	if steps > 8 then 
		steps = 8 
	end

    for i=2,steps do
        for _,v in pairs(temp_list) do
            findGezi(v)      
        end
        temp_list = {}

        for k,v in pairs(fly_path) do
            table.insert(temp_list,k)
        end
    end

    return fly_path
end

function MonsterBase:getPathInfoToTarget(map_info,target)
    local area_table = {}
    local temp_list = {}
    
    local pathFindHelp = function(pos, num)
        if num == target then
            area_table[num] = pos
            return true
        end
        if not area_table[num] and gtool:isLegalPosNum(num) and ((not map_info[num]) or self:isFly()) then
            area_table[num] = pos
        end

        return false
    end
    
    local findGezi = function(pos)
        if pathFindHelp(pos,pos+10)
            or pathFindHelp(pos,pos-10)
            or pathFindHelp(pos,pos+1)
            or pathFindHelp(pos,pos-1) then
            return true
        end
        if pos%2 == 0 then
            if pathFindHelp(pos,pos+11)
                or pathFindHelp(pos,pos+9) then

                return true
            end
        else
            if pathFindHelp(pos,pos-11)
                or pathFindHelp(pos,pos-9) then

                return true
            end
        end

        return false
    end

    findGezi(self:getCurPosNum())
    for k,v in pairs(area_table) do
        table.insert(temp_list,k)
    end

    local last_list_size = #temp_list

    for i=2,20 do
        for _,v in pairs(temp_list) do
            if findGezi(v) then
                return area_table
            end
        end
        temp_list = {}

       	for k,v in pairs(area_table) do
       	    table.insert(temp_list,k)
       	end
       	if last_list_size == #temp_list then
       		return area_table
       	end
    end

    return area_table
end

function MonsterBase:getPathToPos(num, path_table)
	path_table = path_table or {}
	table.insert(path_table,num)
	local last_geizi
	if self:isFly() then 
		last_geizi = self.fly_path[num]
	else
		last_geizi = self.can_reach_area_info[num]
	end

	if self:getCurPosNum() == last_geizi then
		return path_table
	else
		return self:getPathToPos(last_geizi,path_table)
	end
end

function MonsterBase:getNearPosNum(num)

	if num%2 == 0 then
		if self:canMoveToThePosNum(num+10) then
			return num+10
		elseif self:canMoveToThePosNum(num-10) then
			return num-10
		elseif self:canMoveToThePosNum(num+1) then
			return num+1
		elseif self:canMoveToThePosNum(num-1) then
			return num-1
		elseif self:canMoveToThePosNum(num+11) then
			return num+11
		elseif self:canMoveToThePosNum(num+9) then
			return num+9
		end
	else
		if self:canMoveToThePosNum(num+10) then
			return num+10
		elseif self:canMoveToThePosNum(num-10) then
			return num-10
		elseif self:canMoveToThePosNum(num+1) then
			return num+1
		elseif self:canMoveToThePosNum(num-1) then
			return num-1
		elseif self:canMoveToThePosNum(num-11) then
			return num-11
		elseif self:canMoveToThePosNum(num-9) then
			return num-9
		end
	end

	return false
end

----------------------------辅助判断----------------------------------
----------------------------辅助判断----------------------------------
----------------------------辅助判断----------------------------------
function MonsterBase:nothingCanDo()
	if Judgment:Instance():getAuto() then
		return true
	end
	if not self:isMelee() then
		return false
	else
		self:getAroundInfo()
		
		local count = 0
		for k,v in pairs(self.can_reach_area_info) do
		    count = count + 1
		    if count > 1 then
		    	return false
		    end
		end
		return true
	end
end

function MonsterBase:canReachAndAttack(num)
	if self:canAttack() then
		if self:isNear(num) or not self:isMelee() then
			return true
		end
	
		return self:getNearPosNum(num)
	else
		return false
	end
end

function MonsterBase:isNear(num)
	local cur = self:getCurPosNum()
	if num%2 == 0 then
		if cur == num+10
			or cur == num-10
			or cur == num+1
			or cur == num-1
			or cur == num+11
			or cur == num+9 then
			
			return true
		end
	else
		if cur == num+10
			or cur == num-10
			or cur == num+1
			or cur == num-1
			or cur == num-11
			or cur == num-9 then
			
			return true
		end
	end

	return false
end

function MonsterBase:canMoveToThePosNum(num)
	return self.can_reach_area_info[num] and self.can_reach_area_info[num] > 10 and 100 > self.can_reach_area_info[num]
end
----------------------------状态动作----------------------------------
----------------------------状态动作----------------------------------
----------------------------状态动作----------------------------------
function MonsterBase:changeMonsterStatus(status)
	status = status or self.last_status or MonsterBase.Status.ALIVE
	self.last_status = self.status
	self.status = status
	
	if status == MonsterBase.Status.ALIVE then
		self:repeatAnimation("alive")
	elseif status == MonsterBase.Status.DEFEND then
		self:repeatAnimation("defend")
	elseif status == MonsterBase.Status.WAITING then
		self:doAnimation("wait")
	end
end

function MonsterBase:addMonsterStatus(status)
	self.last_status = self.status
	self.status = self.status + status
end

function MonsterBase:removeMonsterStatus(status)
	self.last_status = self.status
	self.status = self.status - status

	if self.status < MonsterBase.Status.CANT_ATTACK then
		self:repeatAnimation("alive")
	end
end

function MonsterBase:goBackRepeatAnimate()
	if self.status == MonsterBase.Status.ALIVE then
		self:repeatAnimation("alive")
	elseif self.status == MonsterBase.Status.DEFEND then
		self:repeatAnimation("defend")
	else
		self:repeatAnimation("alive")
	end
end

function MonsterBase:repeatAnimation(name)
	if Config.Monster_animate[self.id][name] then
    	local animate = Config.Monster_animate[self.id][name](self.animation)
		self.model:stopAllActions()
        self.model:runAction(cc.RepeatForever:create(animate))

        return true
    end

    return false
end

function MonsterBase:doAnimation(name,cb)
	if Config.Monster_animate[self.id][name] then
    	local animate = Config.Monster_animate[self.id][name](self.animation)
		local callback = cc.CallFunc:create(handler(self,self.goBackRepeatAnimate))
		self.model:stopAllActions()
		local seq
		if self:isDead() then
			seq = cc.Sequence:create(animate,cb)
        else
        	seq = cc.Sequence:create(animate,callback,cb)
        end
        self.model:runAction(seq)
    elseif cb then
    	self:doSomethingLater(cb,1)
    end
end

function MonsterBase:doSomethingLater(callback,time)
	local ac_node = cc.Node:create()
    Judgment:Instance():getActionNode():addChild(ac_node)
    local default_ac = ac_node:runAction(cc.ScaleTo:create(time,1))
    local seq = cc.Sequence:create(default_ac,callback)
    ac_node:runAction(seq)
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
--------------------------AI------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function MonsterBase:runAI()

	local enemy_list = self:getAliveEnemyMonsters()

	self.can_reach_area_info = self:getAroundInfo()
	
	local target_enemy = self:getEnemyCanAttack(enemy_list)
	
	if target_enemy then
		local pos_num = gtool:ccpToInt(target_enemy.cur_pos)
		local distance = self:getDistanceToPos(pos_num)
		if self:isMelee() then
			self:moveAndAttack(target_enemy)
		else
			if distance<6 and distance > 2 then
				self:attack(target_enemy, distance)
			else
				local pos = self:getGoodPosToAttack(target_enemy,distance)
				if pos then
					self:moveTo(pos,target_enemy)
				else
					self:attack(target_enemy, distance)
				end
			end
		end

	else
		local map_info = Judgment:Instance():getMapInfo()
		self:moveCloseToLowestHpEnemy(enemy_list,map_info)
	end
end

function MonsterBase:getEnemyCanAttack(enemy_list)
	local can_attack_list = {}
	for k,v in pairs(enemy_list) do
		if self:canReachAndAttack(gtool:ccpToInt(v.cur_pos)) then
			table.insert(can_attack_list,v)
		end
	end
	
	return self:getLowestHpEnemy(can_attack_list)
end

function MonsterBase:getLowestHpEnemy(enemy_list)
	local sort_by_hp = function(a,b)
		return a.cur_hp < b.cur_hp
	end

	if #enemy_list>2 then
		table.sort(enemy_list,sort_by_hp)
	end
	
	return enemy_list[1]
end

function MonsterBase:moveCloseToLowestHpEnemy(enemy_list,map_info)
	local enemy = self:getLowestHpEnemy(enemy_list)

	local pos_num = gtool:ccpToInt(enemy.cur_pos)

	local all_path = self:getPathInfoToTarget(map_info,pos_num)

	local path
	if all_path[pos_num] then
		path = self:getPathToPosPlus(pos_num, all_path)
	end

	if path then
		local index
		for i,v in ipairs(path) do
			if self.can_reach_area_info[v] and self.can_reach_area_info[v]<100 and self.can_reach_area_info[v]>10 then
				index = i
				break
			end
		end
		
		self:moveTo(gtool:intToCcp(path[index]))
	else
		self:wait(true)
	end
end

function MonsterBase:getGoodPosToAttack(enemy,distance)
	local enemy_direction = self:towardToIntPos(self:getCurPosNum(), enemy:getCurPosNum(), true)
	local pos_num
	if distance < 3 then
		pos_num = self:getPosNumByDirectionAndSteps(self:getCurPosNum(),enemy_direction + 3,2)
	else
		pos_num = self:getPosNumByDirectionAndSteps(self:getCurPosNum(),enemy_direction,distance - 5)
	end

	if self:canMoveToThePosNum(pos_num) then
		return gtool:intToCcp(pos_num)
	else
		return nil
	end
end

function MonsterBase:getPosNumByDirectionAndSteps(pos,towards,steps)
	if steps < 1 then
		return pos
	end
	local temp_table
	if pos%2 == 0 then
		temp_table = {
			[1] = pos+10,
			[2] = pos+9,
			[3] = pos-1,
			[4] = pos-10,
			[5] = pos+1,
			[6] = pos+11,
		}
	else
		temp_table = {
			[1] = pos+10,
			[2] = pos-1,
			[3] = pos-11,
			[4] = pos-10,
			[5] = pos-9,
			[6] = pos+1,
		}
	end

	towards = gtool:normalizeTowards(towards)
	if steps == 1 then
		return temp_table[towards]
	else
		return self:getPosNumByDirectionAndSteps(temp_table[towards],towards,steps-1)
	end
end

function MonsterBase:getPathToPosPlus(num, all_path, path_table)
	path_table = path_table or {}
	table.insert(path_table,num)
	local last_geizi
	if self:isFly() then 
		last_geizi = self.fly_path[num]
	else
		last_geizi = all_path[num]
	end

	if self:getCurPosNum() == last_geizi then
		return path_table
	else
		return self:getPathToPosPlus(last_geizi,all_path,path_table)
	end
end

function MonsterBase:getBackFirstNearPosNum(num,target_toward)
	local help = function (a)
		return self:canMoveToThePosNum(a) or a == self:getCurPosNum()
	end

	local temp_table
	if num%2 == 0 then
		temp_table = {
			[1] = num+10,
			[2] = num+9,
			[3] = num-1,
			[4] = num-10,
			[5] = num+1,
			[6] = num+11,
		}
	else
		temp_table = {
			[1] = num+10,
			[2] = num-1,
			[3] = num-11,
			[4] = num-10,
			[5] = num-9,
			[6] = num+1,
		}
	end

	local first_toward = gtool:normalizeTowards(target_toward - 3)

	if help(temp_table[first_toward]) then
		return temp_table[first_toward]
	end
	
	local next_first

	for i=1,2 do
		next_first = gtool:normalizeTowards(first_toward - i)
		if help(temp_table[next_first]) then
			return temp_table[next_first]
		end
		next_first = gtool:normalizeTowards(first_toward + i)
		
		if help(temp_table[next_first]) then
			return temp_table[next_first]
		end
	end

	if help(temp_table[target_toward]) then
		return temp_table[target_toward]
	end
end

function MonsterBase:getNearPosPlus(num)
	if num%2 == 0 then
		if gtool:isLegalPosNum(num+10) then
			return num+10
		elseif gtool:isLegalPosNum(num-10) then
			return num-10
		elseif gtool:isLegalPosNum(num+1) then
			return num+1
		elseif gtool:isLegalPosNum(num-1) then
			return num-1
		elseif gtool:isLegalPosNum(num+11) then
			return num+11
		elseif gtool:isLegalPosNum(num+9) then
			return num+9
		end
	else
		if gtool:isLegalPosNum(num+10) then
			return num+10
		elseif gtool:isLegalPosNum(num-10) then
			return num-10
		elseif gtool:isLegalPosNum(num+1) then
			return num+1
		elseif gtool:isLegalPosNum(num-1) then
			return num-1
		elseif gtool:isLegalPosNum(num-11) then
			return num-11
		elseif gtool:isLegalPosNum(num-9) then
			return num-9
		end
	end

	return false
end

return MonsterBase