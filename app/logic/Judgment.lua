Judgment = {}

Judgment.MapItem = {
	EMPTY			= 0,
	BARRIER			= 2,
	ENEMY			= 3,
	LEFT_MONSTER 	= 1,
	RIGHT_MONSTER 	= 4,
	FRIEND			= 5,
}

Judgment.GameStatus = {
	ACTIVE 			= 0,
	RUNNING			= 1,
	WAIT_ORDER		= 2,
	OVER 			= 3,
	AUTO 			= 4,
}

Judgment.Order = {
	ACTIVATE	= 0,
	MOVE 		= 1,
	ATTACK 		= 2,
	DEFEND		= 3,
	WAIT 		= 4,
	USE_SKILL	= 5,
}

Judgment.OPERATE = {
	[0] = function(is_wait, round_num)
		if Judgment:Instance().scene.battle_info_view:isInited() then
			Judgment:Instance().scene:updateBattleQueue(is_wait)
		end
		Judgment:Instance().cur_active_monster:onActive(round_num)
	end,

	[1] = function(arena_pos)
		Judgment:Instance().cur_active_monster:moveTo(arena_pos)
	end,

	[2] = function(target,distance)
		Judgment:Instance().cur_active_monster:attack(target,distance)
	end,

	[3] = function()
		Judgment:Instance().cur_active_monster:defend()
	end,

	[4] = function()
		Judgment:Instance().cur_active_monster:wait()
	end,

	[5] = function(target_pos_num)
		Judgment:Instance().cur_active_monster:useSkill(target_pos_num)
	end,
}

function Judgment:new()
	local o = {}
	setmetatable(o,self)
	self.__index = self
	
	self.left_team = {}
	self.right_team = {}
	self.wait_list = {}
	self.all_monsters = {}
	self.map_info = {}
	self.cur_round_monster_queue = {}
	self.next_round_monster_queue = {}
	return o
end
 
function Judgment:Instance()
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

function Judgment:setScene(scene)
	self.action_node = cc.Node:create()
	self.scene = scene
	self.scene:addChild(self.action_node)
end

function Judgment:getScene(scene)
	return self.scene
end

function Judgment:initGame(left_team,right_team,map,chapter_num,level_num)
	self.game_speed = 1
	self.is_use_skill = false
	self.map = map
	self.chapter_num = chapter_num
	self.level_num = level_num

	self.left_team = {}
	for k,v in pairs(left_team) do
		table.insert(self.left_team,v)
	end
	self.right_team = {}
	for k,v in pairs(right_team) do
		table.insert(self.right_team,v)
	end

	self:sortAllMonstersByInitiative()
	self.cur_round_monster_queue = self:getAllMonsters()
end

function Judgment:startGame()
	self.is_auto = false
	self.cur_round_num = 1
	self.cur_active_monster_index = 1
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_active_monster_index]
	self.cur_game_status = Judgment.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:runGame(order, param1, param2)
	local action = Judgment.OPERATE[order]
	action(param1,param2)
end

function Judgment:gameOver(win_side)
	self:setGameStatus(Judgment.GameStatus.OVER)
	local result = self:getGameResult(win_side)
	self.scene:gameOver(result)
	if win_side == 1 then
		local table = self:getLeftAliveMonsters()
		for k,v in pairs(table) do
			v:repeatAnimation("victory")
		end
	else
		local table = self:getRightAliveMonsters()
		for k,v in pairs(table) do
			v:repeatAnimation("victory")
		end
	end
end

function Judgment:getGameResult(win_side)
	local result = {}
	local star_num = 0

	if win_side == 1 then
		star_num = star_num + 1
		if self.cur_round_num < 6 then
			star_num = star_num + 1
		end
		if self:getDeadMonsterNum() < 1 then
			star_num = star_num + 1
		end
	end

	result.star_num = star_num 

	return result
end

function Judgment:getDeadMonsterNum()
	local num = 0

	for k,v in pairs(self.left_team) do
		if v:isDead() then
			num = num + 1
		end
	end

	return num
end

function Judgment:nextMonsterActivate(is_wait)
	self:setIsUseSkill(false)
	if is_wait then
		table.insert(self.cur_round_monster_queue,self.cur_active_monster)
		table.insert(self.next_round_monster_queue,self.cur_active_monster)
	end
	if not self.cur_active_monster:hasWaited() then
		table.insert(self.next_round_monster_queue,self.cur_active_monster)
	end
	self.cur_active_monster = self:getNextMonster()

	if not self.cur_active_monster then
		self:startNextRound()
	elseif self.cur_active_monster:isDead() then
		self:nextMonsterActivate()
	else
		self:runGame(Judgment.Order.ACTIVATE,is_wait)
	end
end

function Judgment:startNextRound()
	print("round "..self.cur_round_num.."finish")
	self.cur_round_num = self.cur_round_num + 1
	self.cur_active_monster_index = 1
	self.cur_round_monster_queue = self.next_round_monster_queue
	self.next_round_monster_queue = {}
	
	self:aliveMonsterEnterNewRound()
	
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_active_monster_index]
	while self.cur_active_monster:isDead() do
		self.cur_active_monster = self:getNextMonster()
	end
	self.cur_game_status = Judgment.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:aliveMonsterEnterNewRound()
	local all_alive_monster = self:getAllAliveMonsters()
	for k,v in pairs(all_alive_monster) do
		v:onEnterNewRound(self.cur_round_num)
	end
end

function Judgment:getNextMonster()
	self.cur_active_monster_index = self.cur_active_monster_index + 1
	return self.cur_round_monster_queue[self.cur_active_monster_index]
end
function Judgment:updateMapInfo()
	self.map_info = {}

	for k,v in pairs(self.map) do
		table.insert(self.map_info,k,v)
	end
	
	local monsters = self:getAllAliveMonsters()
	for k,v in pairs(monsters) do
		self.map_info[gtool:ccpToInt(v.cur_pos)] = v
	end
end

function Judgment:changeGameStatus(status)
	self.cur_game_status = status
	self:updateMapInfo()
	self.scene:updateMapView()
end

function Judgment:selectPos(node)
	if self.map_info[gtool:ccpToInt(node.arena_pos)] then
		print("you can't do that!")
	else
		self:runGame(Judgment.Order.MOVE, node.arena_pos)
	end
end

function Judgment:selectTarget(num,distance)
	if self.map_info[num] and self.map_info[num]:isMonster() then
		if not self:getIsUseSkill() then
			self:runGame(Judgment.Order.ATTACK, self.map_info[num],distance)
		else
			self:runGame(Judgment.Order.USE_SKILL, num)
			self:setIsUseSkill(false)
		end
	end
end

function Judgment:requestDefend()
	self:runGame(Judgment.Order.DEFEND)
end

function Judgment:requestWait()
	self:runGame(Judgment.Order.WAIT)

end

function Judgment:requestAuto()
	self:setAuto(true)
	if self:getGameStatus() == Judgment.GameStatus.WAIT_ORDER then
		self.cur_active_monster:runAI()
	end
	self:setGameStatus(Judgment.GameStatus.AUTO)
end

function Judgment:stopAuto()
	self:setAuto(false)
end

function Judgment:checkGameOver(is_buff)
	local right = self:getRightAliveMonsters()
	local left = self:getLeftAliveMonsters()
	
	if #right < 1 then
		self:gameOver(1)
	elseif #left < 1 then
		self:gameOver(4)
	elseif not is_buff then
		self:nextMonsterActivate()
	end

end

function Judgment:setIsUseSkill(is_use_skill)
	self.is_use_skill = is_use_skill
end

function Judgment:getIsUseSkill()
	return self.is_use_skill
end

function Judgment:setAuto(is_auto)
	self.is_auto = is_auto
end

function Judgment:getAuto()
	return self.is_auto
end

function Judgment:getMap()
	return self.map
end

function Judgment:getMapInfo()
	self:updateMapInfo()
	return self.map_info
end

function Judgment:getActionNode()
	return self.action_node
end

function Judgment:setGameStatus(status)
	self.cur_game_status = status
end

function Judgment:getGameStatus()
	return self.cur_game_status
end

function Judgment:setGameSpeed(speed)
	self.game_speed = speed
end

function Judgment:getGameSpeed()
	return self.game_speed
end

function Judgment:getCurRoundNum()
	return self.cur_round_num
end

function Judgment:getCurActiveMonsterIndex()
	return self.cur_active_monster_index
end

function Judgment:getCurActiveMonster()
	return self.cur_active_monster
end

function Judgment:getCurRoundMonsterQueue()
	return self.cur_round_monster_queue
end

function Judgment:getNextRoundMonsterQueue()
	return self.next_round_monster_queue
end

function Judgment:getCurStoryAndLevelNum()
	return self.chapter_num,self.level_num
end

function Judgment:isWaitOrder()
	return self.cur_game_status == Judgment.GameStatus.WAIT_ORDER
end

function Judgment:isGameOver()
	return self.cur_game_status == Judgment.GameStatus.OVER
end

function Judgment:getAllMonsters()
	local all = {}
	print(#self.left_team)
	for _,v in pairs(self.left_team) do
		table.insert(all,v)
	end

	for _,v in pairs(self.right_team) do
		table.insert(all,v)
	end

	return all
end


function Judgment:getAllAliveMonsters()
	local all = {}
	
	for _,v in pairs(self.left_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	for _,v in pairs(self.right_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	return all
end

function Judgment:getLeftAliveMonsters()
	local all = {}
	
	for _,v in pairs(self.left_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	return all
end

function Judgment:getRightAliveMonsters()
	local all = {}
	
	for _,v in pairs(self.right_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	return all
end

function Judgment:sortAllMonstersByInitiative()
	local sort_by_initiative = function(a,b)
		if a.initiative == b.initiative then
			if a.level == b.level then
				return a.rarity > b.rarity
			else
				return a.level > b.level
			end
		else
			return a.initiative > b.initiative
		end
	end

	table.sort(self.all_monsters,sort_by_initiative)
end

function Judgment:getPositionByInt(num)
	return self.scene.map_view:getPositionByInt(num)
end

function Judgment:clearTeam()
	self.left_team = {}

	self.right_team = {}

end