Judgment = {}

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

	[1] = function()
		Judgment:Instance().cur_active_monster:moveTo()
	end,

	[2] = function()
		Judgment:Instance().cur_active_monster:attack()
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
	self:runGame(Judgment.Order.ACTIVATE)
end

function Judgment:runGame(order)
	local action = Judgment.FSM[order]
	action()
end

function Judgment:nextMonsterActivate()
	self.cur_active_monster = self:getNextMonster()

	if not self.cur_active_monster then
		self:startNextRound()
	elseif self.cur_active_monster:isDead() then
		self:nextMonsterActivate()
	else
		self:runGame(Judgment.Order.ACTIVATE)
	end
end

function Judgment:getNextMonster()
	self.cur_monster_index = self.cur_monster_index + 1
	return self.cur_round_monster_queue[self.cur_monster_index]
end

function Judgment:changeGameStatus(status)
	self.cur_game_status = status
	self.scene:updateMapView()
end

function Judgment:setGameStatus(status)
	self.cur_game_status = status
end

function Judgment:getGameStatus()
	return self.cur_game_status
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