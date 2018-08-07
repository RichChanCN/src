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
	RUN_ACTION		= 1,
	WAIT_ORDER		= 2,
	OVER 			= 3,
}

Judgment.Order = {
	ACTIVATE	= 0,
	MOVE 		= 1,
	ATTACK 		= 2,
	DEFEND		= 3,
	WAIT 		= 4,
}

Judgment.OPERATE = {
	[0] = function(is_wait)
		if Judgment:Instance().scene.battle_info_view:isInited() then
			Judgment:Instance().scene:updateBattleQueue(is_wait)
		end
		Judgment:Instance().cur_active_monster:onActive()
	end,

	[1] = function(arena_pos)
		Judgment:Instance().cur_active_monster:moveTo(arena_pos)
	end,

	[2] = function(target)
		Judgment:Instance().cur_active_monster:attack(target)
	end,

	[3] = function()
		Judgment:Instance().cur_active_monster:defend()
	end,

	[4] = function()
		Judgment:Instance().cur_active_monster:wait()
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

function Judgment:initGame(left_team,right_team)
	self.game_speed = 1

	self.left_team = left_team
	self.right_team = right_team

	self:sortAllMonstersByInitiative()
	self.cur_round_monster_queue = self:getAllMonsters()
end

function Judgment:startGame()
	self.cur_round_num = 1
	self.cur_active_monster_index = 1
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_active_monster_index]
	self.cur_game_status = Judgment.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:runGame(order, param)
	self.action_node:removeAllChildren()
	local action = Judgment.OPERATE[order]
	action(param)
end

function Judgment:gameOver(win_side)
	self.scene:gameOver()
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

function Judgment:nextMonsterActivate(is_wait)
	if not self.cur_active_monster:isDead() then
		if is_wait then
			table.insert(self.cur_round_monster_queue,self.cur_active_monster)
			table.insert(self.next_round_monster_queue,self.cur_active_monster)
		end
	end
	if not self.cur_active_monster:isWaited() then
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
	self.cur_game_status = Judgment.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:aliveMonsterEnterNewRound()
	local all_alive_monster = self:getAllAliveMonsters()
	for k,v in pairs(all_alive_monster) do
		v:onEnterNewRound()
	end
end

function Judgment:getNextMonster()
	self.cur_active_monster_index = self.cur_active_monster_index + 1
	return self.cur_round_monster_queue[self.cur_active_monster_index]
end
function Judgment:updateMapInfo()
	self.map_info = self.map or {}
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

function Judgment:selectTarget(num)
	if self.map_info[num] and self.map_info[num]:isMonster() then
		self:runGame(Judgment.Order.ATTACK, self.map_info[num])
	end
end

function Judgment:requestDefend()
	self:runGame(Judgment.Order.DEFEND)
end

function Judgment:requestWait()
	self:runGame(Judgment.Order.WAIT)

end

function Judgment:requestAuto()
	
end

function Judgment:checkGameOver()
	local right = self:getRightAliveMonsters()
	local left = self:getLeftAliveMonsters()
	
	if #right < 1 then
		self:gameOver(1)
	elseif #left < 1 then
		self:gameOver(4)
	else
		self:nextMonsterActivate()
	end

end

function Judgment:setMap(map)
	self.map = map
end

function Judgment:getMap()
	return self.map
end

function Judgment:getMapInfo()
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

function Judgment:getAllMonsters()
	local all = {}
	
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