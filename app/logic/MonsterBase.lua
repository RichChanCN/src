local MonsterBase = {}

MonsterBase.TeamSide = {
	NONE 	= 0,
	LEFT 	= 1,
	RIGHT 	= 4,
}

MonsterBase.DamageType = {
	COMMON 		= 1,
	CRITICAL 	= 2,
	MAGIC 		= 3,
	MISS 		= 4,
}

MonsterBase.Status = {
	ALIVE 	= 1,
	DEAD 	= 2,
	DEFEND 	= 3,
	WAITING = 4,
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

	self.skills_list 			= data.skills_list

	self.max_anger				= data.anger
	self.max_hp 				= data.hp
	self.damage 				= data.damage
	self.physical_defense 		= data.physical_defense
	self.magic_defense 			= data.magic_defense
	self.mobility 				= data.mobility
	self.initiative 			= data.initiative
	self.defense_penetration 	= data.defense_penetration

	self.cur_anger				= 0
	self.cur_hp 				= self.max_hp
	self.steps 					= self.cur_mobility
	self.cur_towards				= self.towards
	
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

function MonsterBase:getTag()
	return self.tag
end

function MonsterBase:getCurDamage()
	local cur_damage = self.damage

	return cur_damage
end

function MonsterBase:getCurMaxHp()
	local cur_max_hp = self.max_hp

	return cur_max_hp
end

function MonsterBase:getCurPysicalDefense()
	local cur_physical_defense = self.physical_defense

	return cur_physical_defense
end

function MonsterBase:getCurMagicDefense()
	local cur_magic_defense = self.magic_defense

	return cur_magic_defense
end

function MonsterBase:getCurMobility()
	local cur_mobility = self.mobility

	return cur_mobility
end

function MonsterBase:getCurInitiative()
	local cur_initiative = self.initiative

	return cur_initiative
end

function MonsterBase:getCurDefensePenetration()
	local cur_defense_penetration = self.defense_penetration

	return cur_defense_penetration
end

function MonsterBase:reset()
	if not self.model and self.animation and self.node then
		return
	end

	self.cur_anger					= 0
	self.cur_hp 					= self.max_hp
	self.cur_pos    				= self.start_pos
	self.cur_towards				= self.towards

	self.status 					= MonsterBase.Status.ALIVE
	self.is_waited					= false

	self.steps 						= self.mobility
	self.buff_list				= {}
	self.debuff_list			= {}

	self:towardTo(self.cur_towards)

	self:toStand()
end

function MonsterBase:getAroundInfo(is_to_show)
	local steps = self.steps
	if is_to_show then
		if steps < 1 and not self:isWaited() then
			steps = self:getCurMobility()
		end
	end

	local map_info = Judgment:Instance():getMapInfo()
	self.can_reach_area_info = {}

	if steps>0 then
		
		self.can_reach_area_info = self:getCanReachAreaInfo(gtool:ccpToInt(self.cur_pos),map_info,steps)

		self.fly_path = {}
		if self:isFly() then
			for k,v in pairs(self.can_reach_area_info) do
				table.insert(self.fly_path,k,v)
			end
		end

		for k,v in pairs(map_info) do
			if v.team_side == self.team_side then
				self.can_reach_area_info[k] = Judgment.MapItem.FRIEND
			end
		end
	end

	local can_attack_table = {}
	for k,v in pairs(map_info) do
		if type(v) == type({}) and v.team_side ~= self.team_side then
			if not self:isMelee() or self:canAttack(k) then
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

function MonsterBase:isWaited()
	return self.is_waited
end

function MonsterBase:isPlayer()
	return self.team_side == MonsterBase.TeamSide.LEFT
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
			and murderer:isMelee() 
			and self:isNear(gtool:ccpToInt(murderer.cur_pos)) 
			and not(self:isBeSideAttacked(murderer) or self:isBeBackAttacked(murderer))
end


function MonsterBase:onEnterNewRound()
	self.is_waited = false
	self.steps = self:getCurMobility()
end


function MonsterBase:onActive()
	print(self.node:getReferenceCount())
	local ac1 = self.node:runAction(cc.Blink:create(0.5, 2))
	self.node:stopAction(ac1)
	local cb = function()
		self.node:setVisible(true)
		if self:isPlayer() and not Judgment:Instance():getAuto() then
			self:toStand()
			Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
		else
			self:runAI()
		end
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,callback)
	
	self.node:runAction(seq)
end

function MonsterBase:moveTo(arena_pos,target)
	self:repeatAnimation("walk")
	local cb = function()
		self.cur_pos = arena_pos
		if target and target.isMonster then
			self:attack(target)
		else
			self:toStand()
			if self:nothingCanDo() then
				Judgment:Instance():nextMonsterActivate()
			else
				Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
			end
		end
	end
	local callback = cc.CallFunc:create(handler(self,cb))

	self:moveFollowPath(arena_pos,callback)

	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
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
	self:towardToIntPos(gtool:ccpToInt(self.cur_pos),path[#path])
	self.node:runAction(all_seq)
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

	if gtool:ccpToInt(self.cur_pos) == last_geizi then
		return path_table
	else
		return self:getPathToPos(last_geizi,path_table)
	end
end

function MonsterBase:moveAndAttack(target,is_ai)
	local num = gtool:ccpToInt(target.cur_pos)
	local pos = gtool:intToCcp(self:getNearPos(num))

	self:moveTo(pos,target)
end

function MonsterBase:attack(target,distance,is_ai)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	
	if self:isMelee() and not self:isNear(gtool:ccpToInt(target.cur_pos)) then
		self:moveAndAttack(target,is_ai)
	else
		self:addAnger()
		local cur_num = gtool:ccpToInt(self.cur_pos)
		local to_num = gtool:ccpToInt(target.cur_pos)
		self:towardToIntPos(cur_num,to_num)
		self:doAnimation("attack1")
		target:beAttacked(self,false,distance)
	end
end

function MonsterBase:getDamageType(murderer)
	if murderer:isMelee() and (self:isBeBackAttacked(murderer) or self:isBeSideAttacked(murderer)) then
		return MonsterBase.DamageType.CRITICAL
	else
		return MonsterBase.DamageType.COMMON
	end
end

function MonsterBase:beAttacked(murderer, is_counter_attack,distance)
	self:minusHP(self:getFinalAttackDamage(murderer,distance),self:getDamageType(murderer))
	self:addAnger()

	if self.cur_hp < 1 then
		self:die()
	else
		local cb = function()
			local cur_num = gtool:ccpToInt(self.cur_pos)
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
		
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	end
end

function MonsterBase:getFinalAttackDamage(murderer,distance)
	local damage = murderer:getCurDamage()
	
	if self:isBeBackAttacked(murderer) then
		damage = damage * 1.5
	elseif self:isBeSideAttacked(murderer) then
		damage = damage * 1.2
	end

	
	local defense
	if murderer:isPhysical() then
		defense = self:getCurPysicalDefense() - murderer:getCurDefensePenetration()
	else
		defense = self:getCurMagicDefense() - murderer:getCurDefensePenetration()
	end

	
	if not murderer:isMelee() then
		if distance > 5 then
			damage = damage * (1 - (distance - 5)*2/10)
		elseif distance < 3 then
			damage = damage * (1 - (3 - distance)/10)
		else
			damage = damage * 1.2
		end
	end

	damage = damage * (1 - defense/(defense + 10))

	
	damage = damage + (math.random() - 0.5) * 10

	if damage < 1 then
		damage = 1
	end

	return math.floor(damage)
end

function MonsterBase:minusHP(damage,damage_type)
	local hp = self.cur_hp - damage

	local cb = function()
		self.blood_bar.updateHP(hp/self.max_hp,damage,damage_type)
	end
	local callback = cc.CallFunc:create(handler(self,cb))
	self:doSomethingLater(callback,0.5)
	self:setHP(hp)
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

function MonsterBase:setAnger(angle)
	self.cur_anger = angle

	local cb = function()
		self.card.update(self.cur_anger)
		self.blood_bar.updateAnger(self.cur_anger)
	end
	local callback = cc.CallFunc:create(handler(self,cb))

	self:doSomethingLater(callback,0.5)
end


function MonsterBase:counterAttack(target)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	local cur_num = gtool:ccpToInt(self.cur_pos)
	local to_num = gtool:ccpToInt(target.cur_pos)
	self:towardToIntPos(cur_num,to_num)
	self:doAnimation("attack1")
	self:addAnger()
	target:beAttacked(self,true)

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
	self:repeatAnimation("defend")
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	Judgment:Instance():nextMonsterActivate()
end

function MonsterBase:die()
	self.status = MonsterBase.Status.DEAD
	local ac = self.model:runAction(cc.FadeOut:create(1))
	local cb = function()
		self.card.removeSelf()
		self.node:setVisible(false)
		Judgment:Instance():checkGameOver()
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac,callback)
	self:doAnimation("die", seq)
	
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
end

function MonsterBase:useSkill(index, target)
	
end

function MonsterBase:turnToTarget(target)
	
end


function MonsterBase:towardTo(num)
	self.cur_towards = num
	self.model:setRotation3D(cc.vec3(0,(1-num)*60,0))
end

function MonsterBase:towardToIntPos(cur_num,to_num)
	if not to_num then 
		return
	end
	local towardToHelp = function ()
		local to_pos = gtool:intToCcp(to_num)
		local cur_pos = gtool:intToCcp(cur_num)
		if to_num > cur_num then
			if to_pos.x-cur_pos.x>math.abs(to_pos.y-cur_pos.y) then
				self:towardTo(1)
			elseif to_pos.y>cur_pos.y then
				self:towardTo(6)
			else
				self:towardTo(2)
			end
		else
			if cur_pos.x-to_pos.x>math.abs(to_pos.y-cur_pos.y) then
				self:towardTo(4)
			elseif to_pos.y>cur_pos.y then
				self:towardTo(5)
			else
				self:towardTo(3)
			end
		end
	end

	local deta = to_num - cur_num
	if cur_num%2 == 0 then
		if deta == 10 then
			self:towardTo(1)
		elseif deta == 9 then
			self:towardTo(2)
		elseif deta == -1 then
			self:towardTo(3)
		elseif deta == -10 then
			self:towardTo(4)
		elseif deta == 1 then
			self:towardTo(5)
		elseif deta == 11 then
			self:towardTo(6)
		else
			towardToHelp()
		end
	else
		if deta == 10 then
			self:towardTo(1)
		elseif deta == -1 then
			self:towardTo(2)
		elseif deta == -11 then
			self:towardTo(3)
		elseif deta == -10 then
			self:towardTo(4)
		elseif deta == -9 then
			self:towardTo(5)
		elseif deta == 1 then
			self:towardTo(6)
		else
			towardToHelp()
		end
	end
end

function MonsterBase:nothingCanDo()
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

function MonsterBase:canAttack(num)
	if self:isNear(num) then
		return true
	end

	return self:getNearPos(num)
end

function MonsterBase:isNear(num)
	local cur = gtool:ccpToInt(self.cur_pos)
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

--????ֵΪnumλ???????ɵ????????㣬??????????ʹ?
--?????Ӱ?????λ?
function MonsterBase:getNearPos(num)

	local help = function (a)
		return self.can_reach_area_info[a] and self.can_reach_area_info[a] > 10 and 100 > self.can_reach_area_info[a]
	end
	if num%2 == 0 then
		if help(num+10) then
			return num+10
		elseif help(num-10) then
			return num-10
		elseif help(num+1) then
			return num+1
		elseif help(num-1) then
			return num-1
		elseif help(num+11) then
			return num+11
		elseif help(num+9) then
			return num+9
		end
	else
		if help(num+10) then
			return num+10
		elseif help(num-10) then
			return num-10
		elseif help(num+1) then
			return num+1
		elseif help(num-1) then
			return num-1
		elseif help(num-11) then
			return num-11
		elseif help(num-9) then
			return num-9
		end
	end

	return false
end


function MonsterBase:getDistanceToPos(num)
	return self.distance_info[num]
end

function MonsterBase:updateCurAttribute()
	
end

function MonsterBase:toStand()
	self:repeatAnimation("stand")
end

function MonsterBase:repeatAnimation(name)
	if Config.Monster_animate[self.id][name] then
    	local animate = Config.Monster_animate[self.id][name](self.animation)
		self.model:stopAllActions()
        self.model:runAction(cc.RepeatForever:create(animate))
    end
end

function MonsterBase:doAnimation(name,cb)
	if Config.Monster_animate[self.id][name] then
    	local animate = Config.Monster_animate[self.id][name](self.animation)
		local callback = cc.CallFunc:create(handler(self,self.toStand))
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

function MonsterBase:runAI()
	local enemy_list
	if self:isPlayer() then
		enemy_list = Judgment:Instance():getRightAliveMonsters()
	else
		enemy_list = Judgment:Instance():getLeftAliveMonsters()
	end

	local map_info = Judgment:Instance():getMapInfo()
	self.can_reach_area_info = self:getAroundInfo()
	
	local target_enemy = self:getEnemyCanAttack(enemy_list)
	
	if target_enemy then
		local pos_num = gtool:ccpToInt(target_enemy.cur_pos)
		local distance = self:getDistanceToPos(pos_num,true)
		
		self:attack(target_enemy, distance, is_ai)
	else
		self:moveCloseToLowestHpEnemy(enemy_list,map_info)
	end
end

function MonsterBase:getEnemyCanAttack(enemy_list)
	local can_attack_list = {}
	for k,v in pairs(enemy_list) do
		if self:canAttack(gtool:ccpToInt(v.cur_pos)) then
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

	local near_pos = self:getNearPosPlus(pos_num,map_info)
	local all_path = self:getPathInfoToTarget(map_info,near_pos)

	all_path[pos_num] = near_pos

	local path = self:getPathToPosPlus(pos_num, all_path)

	local index
	for i,v in ipairs(path) do
		if self.can_reach_area_info[v] and self.can_reach_area_info[v]<100 and self.can_reach_area_info[v]>10 then
			index = i
			break
		end
	end

	self:moveTo(gtool:intToCcp(path[index]))
end

function MonsterBase:getPathToPosPlus(num, all_path, path_table)
	path_table = path_table or {}
	table.insert(path_table,num)
	local last_geizi
	if self:isFly() then 
		last_geizi = self.distance_info[num]
	else
		last_geizi = all_path[num]
	end

	if gtool:ccpToInt(self.cur_pos) == last_geizi then
		return path_table
	else
		return self:getPathToPosPlus(last_geizi,all_path,path_table)
	end
end

function MonsterBase:getBackFirstNearPos(num,target_toward)
	local help = function (a)
		return self.can_reach_area_info[a] and self.can_reach_area_info[a] > 10
	end

	local temp_table
	if num%2 == 0 then
		temp_table = {
			[1] = num+10,
			[2] = num-1,
			[3] = num-11,
			[4] = num-10,
			[5] = num+9,
			[6] = num+1,
		}
	else
		temp_table = {
			[1] = num+10,
			[2] = num+9,
			[3] = num-1,
			[4] = num-10,
			[5] = num-9,
			[6] = num+11,
		}
	end

	local first = target_toward - 3
	if first < 1 then
		first = first + 6
	end

	if help(temp_table[first]) then
		return temp_table[first]
	end

	for i=1,2 do
		first = target_toward - i
		if first < 1 then
			first = first + 6
		end
		if help(temp_table[first]) then
			return temp_table[first]
		end
		first = target_toward + i
		if first > 6 then
			first = first - 6
		end
		if help(temp_table[first]) then
			return temp_table[first]
		end
	end

	if help(temp_table[target_toward]) then
		return temp_table[target_toward]
	end
end

function MonsterBase:getNearPosPlus(num)
	--??ϵ?Ƿ???
	local help = function(pos)
		if pos < 10 or pos > 85 or pos%10>7 or pos%10 == 0
			or pos == 11 or pos == 17 or pos == 84 or pos == 81 or pos == 82 then
			return false
		end
		return true
	end
	if num%2 == 0 then
		if help(num+10) then
			return num+10
		elseif help(num-10) then
			return num-10
		elseif help(num+1) then
			return num+1
		elseif help(num-1) then
			return num-1
		elseif help(num+11) then
			return num+11
		elseif help(num+9) then
			return num+9
		end
	else
		if help(num+10) then
			return num+10
		elseif help(num-10) then
			return num-10
		elseif help(num+1) then
			return num+1
		elseif help(num-1) then
			return num-1
		elseif help(num-11) then
			return num-11
		elseif help(num-9) then
			return num-9
		end
	end

	return false
end

function MonsterBase:getCanReachAreaInfo(center_pos_num,map_info,steps)
    local area_table = {}
    local temp_list = {}
    
    local isLegalPos = function(pos)
        if pos < 10 or pos > 85 or pos%10>7 or pos%10 == 0
            or pos == 11 or pos == 17 or pos == 84 or pos == 81 or pos == 82 then
            return false
        end
        return true
    end
    
    local pathFindHelp = function(pos, num)
        if not area_table[num] and isLegalPos(num) and ((not map_info[num]) or self:isFly()) then
            
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
            
            temp_list = {}

            for k,v in pairs(area_table) do
                table.insert(temp_list,k)
            end
        end
    end

    return area_table
end

function MonsterBase:getDistanceInfo()
	local distanc_table = {}
    local temp_list = {}
    
    local isLegalPos = function(pos)
        if pos < 10 or pos > 85 or pos%10>7 or pos%10 == 0
            or pos == 11 or pos == 17 or pos == 84 or pos == 81 or pos == 82 then
            return false
        end
        return true
    end
    
    local pathFindHelp = function(num,step)
        if not distanc_table[num] and isLegalPos(num) then
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

    findGezi(gtool:ccpToInt(self.cur_pos),1)
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
            
            temp_list = {}

            for k,v in pairs(distanc_table) do
                table.insert(temp_list,k)
            end
        end
    end

    return distanc_table
end

function MonsterBase:getPathInfoToTarget(map_info,target)
    local area_table = {}
    local temp_list = {}
    
    local isLegalPos = function(pos)
        if pos < 10 or pos > 85 or pos%10>7 or pos%10 == 0
            or pos == 11 or pos == 17 or pos == 84 or pos == 81 or pos == 82 then
            return false
        end
        return true
    end
    
    local pathFindHelp = function(pos, num)
        if num == target then
            area_table[num] = pos
            return true
        end
        if not area_table[num] and isLegalPos(num) and ((not map_info[num]) or self:isFly()) then
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

    findGezi(gtool:ccpToInt(self.cur_pos))
    for k,v in pairs(area_table) do
        table.insert(temp_list,k)
    end

    for i=2,20 do
        for _,v in pairs(temp_list) do

            if findGezi(v) then
                return area_table
            end
            
            temp_list = {}

            for k,v in pairs(area_table) do
                table.insert(temp_list,k)
            end
        end
    end

    return area_table
end

return MonsterBase