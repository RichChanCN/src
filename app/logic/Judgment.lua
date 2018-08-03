Judgment = {}

Judgment.MapItem = {
	EMPTY			= 0,
	BARRIER			= 2,
	ENEMY			= 3,
	LEFT_MONSTER 	= 1,
	RIGHT_MONSTER 	= 4,
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

Judgment.FSM = {
	[0] = function()
		Judgment:Instance().cur_active_monster:onActive()
	end,

	[1] = function(pos)
		Judgment:Instance().cur_active_monster:moveTo(pos)
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
	self.scene = scene
end

function Judgment:initGame(left_team,right_team)
	self.game_speed = 1

	self.left_team = left_team
	self.right_team = right_team

	self.all_monsters = self:getAllMonsters()
	self:sortAllMonstersByInitiative()
end

function Judgment:startGame()
	self.cur_round_num = 1
	self.cur_monster_index = 1
	self.cur_round_monster_queue = self.all_monsters
	self.all_monsters = nil
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_monster_index]
	self.cur_game_status = Judgment.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:runGame(order, param)
	local action = Judgment.FSM[order]
	action(param)
end

function Judgment:gameOver()
	self.scene:gameOver()
end

function Judgment:nextMonsterActivate(is_wait)
	if not self.cur_active_monster:isDead() then
		if not is_wait then
			table.insert(self.next_round_monster_queue,self.cur_active_monster)
		else
			table.insert(self.cur_round_monster_queue,self.cur_active_monster)
		end
	end

	self.cur_active_monster = self:getNextMonster()

	if not self.cur_active_monster then
		self:startNextRound()
	elseif self.cur_active_monster:isDead() then
		self:nextMonsterActivate()
	else
		self:runGame(Judgment.Order.ACTIVATE)
	end
end

function Judgment:startNextRound()
	print("round "..self.cur_round_num.."finish")
	self.cur_round_num = self.cur_round_num + 1
	self.cur_monster_index = 1
	self.cur_round_monster_queue = self.next_round_monster_queue
	self.next_round_monster_queue = {}
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_monster_index]
	self.cur_game_status = Judgment.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:getNextMonster()
	self.cur_monster_index = self.cur_monster_index + 1
	return self.cur_round_monster_queue[self.cur_monster_index]
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

function Judgment:updateMapInfo()
	self.map_info = self.map or {}
	local monsters = self:getAllMonstersNotDead()
	for k,v in pairs(monsters) do
		self.map_info[gtool:ccpToInt(v.cur_pos)] = v
	end
end

function Judgment:changeGameStatus(status)
	self.cur_game_status = status
	self.scene:updateMapView()
	self:updateMapInfo()
end

function Judgment:selectPos(pos,node)
	if self.map_info[gtool:ccpToInt(node.arena_pos)] then
		print("you can't do that!")
	else
		self.cur_active_monster.cur_pos = node.arena_pos
		self:runGame(Judgment.Order.MOVE, pos)
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

function Judgment:setGameStatus(status)
	self.cur_game_status = status
end

function Judgment:getGameStatus()
	return self.cur_game_status
end

function Judgment:checkGameOver()
	local right = self:getRightMonstersNotDead()
	local left = self:getLeftMonstersNotDead()
	
	if #right < 1 then
		print("left win")
		self:gameOver()
	elseif #left < 1 then
		print("right win")
		self:gameOver()
	else
		self:nextMonsterActivate()
	end

end

function Judgment:getCurActiveMonster()
	return self.cur_active_monster
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


function Judgment:getAllMonstersNotDead()
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

function Judgment:getLeftMonstersNotDead()
	local all = {}
	
	for _,v in pairs(self.left_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	return all
end

function Judgment:getRightMonstersNotDead()
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