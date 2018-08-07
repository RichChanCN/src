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

	self.cur_anger					= 0
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
	self.steps 					= self.cur_mobility
	self.buff_list				= {}
	self.debuff_list			= {}

	self.tag = self.id*100+self.start_pos.x*10+self.start_pos.y
	
	return self
end

function MonsterBase:reset()
	if not self.model and self.animation then
		return
	end

	self.cur_anger					= 0
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
	self.steps 						= self.cur_mobility
	self.buff_list				= {}
	self.debuff_list			= {}

	self:towardTo(self.cur_towads)

	self:toStand()
end
--获取可活动范围内的格子信息
function MonsterBase:getAroundInfo()
	local map_info = Judgment:Instance():getMapInfo()
	local temp_list = {}
	self.around_info = {}
	--如果剩余步数不足，则只检查是否有课攻击对象
	if self.steps < 1 then
		local can_attack_table = {}
		for k,v in pairs(map_info) do
			if type(v) == type({}) and v.team_side ~= self.team_side then
				if not self:isMelee() or self:canAttack(k) then
					table.insert(can_attack_table,k)
				end
			else
				self.around_info[k] = nil
			end
		end

		for k,v in pairs(can_attack_table) do
			self.around_info[v] = Judgment.MapItem.ENEMY
		end

		self.around_info[0] = self.cur_pos
		return self.around_info
	end

	local isLegalPos = function(pos)
		if pos < 10 or pos > 85 or pos%10>7 or pos%10 == 0
			or pos == 11 or pos == 17 or pos == 84 or pos == 81 or pos == 82 then
			return false
		end
		return true
	end
	--寻路辅助函数，记录每个点的上一个路径点
	local pathFindHelp = function(pos, num)
		if not self.around_info[num] and ((not map_info[num]) or self:isFly()) and isLegalPos(num) then
			
			self.around_info[num] = pos
		end
	end
	--广度优先算法
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

	findGezi(gtool:ccpToInt(self.cur_pos))
	for k,v in pairs(self.around_info) do
		table.insert(temp_list,k)
	end

	for i=2,self.steps do
		for _,v in pairs(temp_list) do

			findGezi(v)
			
			temp_list = {}

			for k,v in pairs(self.around_info) do
				table.insert(temp_list,k)
			end
		end
	end

	self.fly_path = {}
	if self:isFly() then
		for k,v in pairs(self.around_info) do
			table.insert(self.fly_path,k,v)
		end
	end

	for k,v in pairs(map_info) do
		if v.team_side == self.team_side then
			self.around_info[k] = Judgment.MapItem.FRIEND
		end
	end
	--可攻击对象更新
	local can_attack_table = {}
	for k,v in pairs(map_info) do
		if type(v) == type({}) and v.team_side ~= self.team_side then
			if not self:isMelee() or self:canAttack(k) then
				table.insert(can_attack_table,k)
			else
				self.around_info[k] = nil
			end
		else --既不是可攻击对象，有存在地图上面，所以就是友军和障碍物，设置为不可到达区域
			self.around_info[k] = nil
		end
	end

	--要在后面设置可攻击对象，否则在可攻击对象一排是会出现攻击范围异常的情况
	for k,v in pairs(can_attack_table) do
		self.around_info[v] = Judgment.MapItem.ENEMY
	end
	--因为around信息的索引是以int来决定的，最小的是11，所以前10位可以灵活使用
	--这里第0位代表自身位置
	self.around_info[0] = self.cur_pos
	return self.around_info
end

--快速判断函数
function MonsterBase:isMonster()
	return true
end

function MonsterBase:isFly()
	return self.move_type == Config.Monster_move_type.FLY
end

function MonsterBase:isDead()
	return self.status == MonsterBase.Status.DEAD
end

function MonsterBase:isMelee()
	return self.attack_type < Config.Monster_attack_type.SHOOTER
end

function MonsterBase:isWaited()
	return self.is_waited
end

--进入一个新的回合会触发的函数
function MonsterBase:onEnterNewRound()
	self.is_waited = false
	self.steps = self.cur_mobility
end

--行动之前触发的函数
function MonsterBase:onActive()
	local ac1 = self.model:runAction(cc.RotateBy:create(1, cc.vec3(0,360,0)))
	local cb = function()
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,callback)
	
	self.model:runAction(seq)
end
--移动函数，第二个参数是移动攻击时候使用
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
--顺着路径到达目的地
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
		
		local action = self.model:runAction(cc.MoveTo:create(0.5,pos))
		self.model:stopAction(action)
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
	self.model:runAction(all_seq)
end
--获取路径
function MonsterBase:getPathToPos(num, path_table)
	path_table = path_table or {}
	table.insert(path_table,num)
	local last_geizi
	if self:isFly() then 
		last_geizi = self.fly_path[num]
	else
		last_geizi = self.around_info[num]
	end

	if gtool:ccpToInt(self.cur_pos) == last_geizi then
		return path_table
	else
		return self:getPathToPos(last_geizi,path_table)
	end
end
--移动并且攻击
function MonsterBase:moveAndAttack(target)
	local num = gtool:ccpToInt(target.cur_pos)
	print(self:getNearPos(num))
	local pos = gtool:intToCcp(self:getNearPos(num))

	self:moveTo(pos,target)
end
--攻击
function MonsterBase:attack(target)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	--若是近战切目标不在周围则移动到目标附近再攻击	
	if self:isMelee() and not self:isNear(gtool:ccpToInt(target.cur_pos)) then
		self:moveAndAttack(target)
	else--否则直接攻击
		local cur_num = gtool:ccpToInt(self.cur_pos)
		local to_num = gtool:ccpToInt(target.cur_pos)
		self:towardToIntPos(cur_num,to_num)
		self:doAnimation("attack1")
		target:beAttacked(self)
	end
end
--被攻击时候触发
function MonsterBase:beAttacked(murderer)
	self.cur_hp = self.cur_hp - murderer.cur_damage
	print("self.cur_hp "..self.cur_hp)
	if self.cur_hp < 1 then
		self:die()
	else
		local cb = function()
			Judgment:Instance():nextMonsterActivate()
		end
		local callback = cc.CallFunc:create(cb)
		self:doAnimation("beattacked", callback)
		
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	end
end
--等待
function MonsterBase:wait()
	if self.is_waited then
		print("you has been waited!")
	else
		self.is_waited = true
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
		Judgment:Instance():nextMonsterActivate(true)
	end
end
--防御
function MonsterBase:defend()
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	Judgment:Instance():nextMonsterActivate()
end

function MonsterBase:die()
	self.status = MonsterBase.Status.DEAD
	local ac2 = self.model:runAction(cc.FadeOut:create(1))
	local cb = function()
		Judgment:Instance():checkGameOver()
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac2,callback)
	self:doAnimation("die", seq)
	
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
end

function MonsterBase:useSkill(index, target)
	
end

function MonsterBase:turnToTarget(target)
	
end

--转向
function MonsterBase:towardTo(num)
	self.model:setRotation3D(cc.vec3(0,(1-num)*60,0))
end
--根据自身位置转向一个位置，参数是已经转换为int的位置信息
function MonsterBase:towardToIntPos(cur_num,to_num)
	if not to_num then 
		return
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
		end
	end
end

--判断目前是否可以强制结束回合
function MonsterBase:nothingCanDo()
	--目前如果是远程，游戏没结束，那么肯定存在可攻击对象
	if not self:isMelee() then
		return false
	else
		self:getAroundInfo()
		--否则如果周围可行动信息中只有自身位置的话，则可以结束
		local count = 0
		for k,v in pairs(self.around_info) do
		    count = count + 1
		    if count > 1 then
		    	return false
		    end
		end
		return true
	end
end

--可以攻击到数值为num的位置吗
function MonsterBase:canAttack(num)
	if self:isNear(num) then
		return true
	end

	return self:getNearPos(num)
	--只要这个位置周围有一个可以移动的点，则认为可以攻击到
	-- if num%2 == 0 then
	-- 	return self.around_info[num+10]
	-- 		or self.around_info[num-10]
	-- 		or self.around_info[num+1]
	-- 		or self.around_info[num-1]
	-- 		or self.around_info[num+11]
	-- 		or self.around_info[num+9]
	-- else
	-- 	return self.around_info[num+10]
	-- 		or self.around_info[num-10]
	-- 		or self.around_info[num+1]
	-- 		or self.around_info[num-1]
	-- 		or self.around_info[num-11]
	-- 		or self.around_info[num-9]
	-- end
end

--判断目前位置是否在数值为num的位置附近
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

--获取数值为num位置点的并且可到达的附近点，移动并攻击中使用
--判断顺序影响攻击位置
function MonsterBase:getNearPos(num)
	local help = function (a)
		return self.around_info[a] and self.around_info[a] > 10
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

--两个位置之间的距离，暂时没有完成，目前只想到了在射手伤害根据距离减少方面有用
function MonsterBase:distanceBetweenPos(num1,num2)
	local min = math.min(num1,num2)
	local max = math.min(num1,num2)
	if max - min == 0 then
		return 0
	end
end

function MonsterBase:updateCurAttribute()
	
end

--转换到站立动作并重复
function MonsterBase:toStand()
	self:repeatAnimation("stand")
end

--转换到并一直重复某一动作
function MonsterBase:repeatAnimation(name)
	if Config.Monster_animate[self.id][name] then
    	local animate = Config.Monster_animate[self.id][name](self.animation)
		self.model:stopAllActions()
        self.model:runAction(cc.RepeatForever:create(animate))
    end
end

--做一个动作
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
    	self.model:runAction(cb)
    end
end

return MonsterBase