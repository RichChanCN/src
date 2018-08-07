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
--????ɻ??Χ??ĸ????
function MonsterBase:getAroundInfo()
	local map_info = Judgment:Instance():getMapInfo()
	local temp_list = {}
	self.around_info = {}
	--???ʣ??????????ֻ?????пι??????
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
	--Ѱ·???????????ÿ?????һ??·????
	local pathFindHelp = function(pos, num)
		if not self.around_info[num] and ((not map_info[num]) or self:isFly()) and isLegalPos(num) then
			
			self.around_info[num] = pos
		end
	end
	--???????
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
	--?ɹ???????
	local can_attack_table = {}
	for k,v in pairs(map_info) do
		if type(v) == type({}) and v.team_side ~= self.team_side then
			if not self:isMelee() or self:canAttack(k) then
				table.insert(can_attack_table,k)
			else
				self.around_info[k] = nil
			end
		else --?Ȳ???ɹ??????д?ڵ???????????Ѿ???ϰ??????Ϊ???ɵ?????
			self.around_info[k] = nil
		end
	end

	--Ҫ?????ÿɹ?????󣬷??ڿɹ??????????????????Χ??????
	for k,v in pairs(can_attack_table) do
		self.around_info[v] = Judgment.MapItem.ENEMY
	end
	--?Ϊaround?Ϣ??????int???????ģ??С???1????ǰ10λ????ʹ?
	--???0λ????????
	self.around_info[0] = self.cur_pos
	return self.around_info
end

--???жϺ??
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

--???һ????Ļغϻᴥ???ĺ??
function MonsterBase:onEnterNewRound()
	self.is_waited = false
	self.steps = self.cur_mobility
end

--???֮ǰ?????ĺ??
function MonsterBase:onActive()
	local ac1 = self.model:runAction(cc.Blink:create(0.5, 2))
	local cb = function()
		self.model:setVisible(true)
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.WAIT_ORDER)
	end
	local callback = cc.CallFunc:create(cb)
	local seq = cc.Sequence:create(ac1,callback)
	
	self.model:runAction(seq)
end
--?????????ڶ??????????????ʱ????
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
--˳?·????????ĵ?
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
--???·??
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
--??????????
function MonsterBase:moveAndAttack(target)
	local num = gtool:ccpToInt(target.cur_pos)
	local pos = gtool:intToCcp(self:getNearPos(num))

	self:moveTo(pos,target)
end
--????
function MonsterBase:attack(target)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	--????ս?Ŀ?겻??Χ??????Ŀ?긽???????	
	if self:isMelee() and not self:isNear(gtool:ccpToInt(target.cur_pos)) then
		self:moveAndAttack(target)
	else--?????ӹ???
		local cur_num = gtool:ccpToInt(self.cur_pos)
		local to_num = gtool:ccpToInt(target.cur_pos)
		self:towardToIntPos(cur_num,to_num)
		self:doAnimation("attack1")
		target:beAttacked(self)
	end
end
--??????ʱ?򴥷?
function MonsterBase:beAttacked(murderer, is_counter_attack)
	self.cur_hp = self.cur_hp - murderer.cur_damage
	if self.cur_hp < 1 then
		self:die()
	else
		
		print("beAttacked",is_counter_attack)
		local cb = function()
			print("callback")
			local cur_num = gtool:ccpToInt(self.cur_pos)
			local to_num = gtool:ccpToInt(murderer.cur_pos)
			self:towardToIntPos(cur_num, to_num)
			if (not is_counter_attack) and self:isMelee() and self:isNear(gtool:ccpToInt(murderer.cur_pos)) then
				print("counterAttack")
				self:counterAttack(murderer)
			else
				print("nextMonsterActivate")
				Judgment:Instance():nextMonsterActivate()
			end
		end
		local callback = cc.CallFunc:create(handler(self,cb))
		self:doAnimation("beattacked", callback)
		
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	end
end

function MonsterBase:counterAttack(target)
	Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
	
	local cur_num = gtool:ccpToInt(self.cur_pos)
	local to_num = gtool:ccpToInt(target.cur_pos)
	self:towardToIntPos(cur_num,to_num)
	self:doAnimation("attack1")
	target:beAttacked(self,true)

end
--?ȴ?
function MonsterBase:wait()
	if self.is_waited then
		print("you has been waited!")
	else
		self.is_waited = true
		Judgment:Instance():changeGameStatus(Judgment.GameStatus.RUN_ACTION)
		Judgment:Instance():nextMonsterActivate(true)
	end
end
--???
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

--ת?
function MonsterBase:towardTo(num)
	self.model:setRotation3D(cc.vec3(0,(1-num)*60,0))
end
--????????ת?һ??λ??????????ת??Ϊint?????Ϣ
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

--????ǰ????ǿ?????غ?
function MonsterBase:nothingCanDo()
	--Ŀǰ????Զ?̣??Ϸû??????ô?϶???ڿɹ??????
	if not self:isMelee() then
		return false
	else
		self:getAroundInfo()
		--?????Χ??ж??Ϣ?ֻ???λ??Ļ??????Խ??
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

--??Թ??????ֵΪnum?????
function MonsterBase:canAttack(num)
	if self:isNear(num) then
		return true
	end

	return self:getNearPos(num)
	--ֻҪ???λ??Χ?һ?????ƶ??ĵ㣬??Ϊ??Թ?????
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

--????ǰλ??????ֵΪnum????????
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

--????λ?֮????룬?ʱû???ɣ?Ŀǰֻ????????˺????ݾ????????
function MonsterBase:distanceBetweenPos(num1,num2)
	local min = math.min(num1,num2)
	local max = math.min(num1,num2)
	if max - min == 0 then
		return 0
	end
end

function MonsterBase:updateCurAttribute()
	
end

--ת????վ??????????
function MonsterBase:toStand()
	self:repeatAnimation("stand")
end

--ת??????һֱ???ĳһ???
function MonsterBase:repeatAnimation(name)
	if Config.Monster_animate[self.id][name] then
    	local animate = Config.Monster_animate[self.id][name](self.animation)
		self.model:stopAllActions()
        self.model:runAction(cc.RepeatForever:create(animate))
    end
end

--?һ?????
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
    	local ac_node = cc.Node:create()
    	Judgment:Instance():getActionNode():addChild(ac_node)
    	local default_ac = ac_node:runAction(cc.ScaleTo:create(1,1))
    	local seq = cc.Sequence:create(default_ac,cb)
    	ac_node:runAction(seq)
    	--self.model:runAction(cb)
    end
end

return MonsterBase