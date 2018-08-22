pve_game_ctrl = pve_game_ctrl or {}

pve_game_ctrl.MapItem = {
	EMPTY			= 0,
	BARRIER			= 2,
	ENEMY			= 3,
	LEFT_MONSTER 	= 1,
	RIGHT_MONSTER 	= 4,
	FRIEND			= 5,
}

pve_game_ctrl.GameStatus = {
	ACTIVE 			= 0,
	RUNNING			= 1,
	WAIT_ORDER		= 2,
	OVER 			= 3,
	AUTO 			= 4,
}

pve_game_ctrl.Order = {
	ACTIVATE	= 0,
	MOVE 		= 1,
	ATTACK 		= 2,
	DEFEND		= 3,
	WAIT 		= 4,
	USE_SKILL	= 5,
}

pve_game_ctrl.OPERATE = {
	[0] = function(is_wait, round_num)
		if pve_game_ctrl:Instance().scene.battle_info_view:isInited() then
			pve_game_ctrl:Instance().scene:updateBattleQueue(is_wait)
		end
		pve_game_ctrl:Instance().cur_active_monster:onActive(round_num)
	end,

	[1] = function(arena_pos)
		pve_game_ctrl:Instance().cur_active_monster:moveTo(arena_pos)
	end,

	[2] = function(target,distance)
		pve_game_ctrl:Instance().cur_active_monster:attack(target,distance)
	end,

	[3] = function()
		pve_game_ctrl:Instance().cur_active_monster:defend()
	end,

	[4] = function()
		pve_game_ctrl:Instance().cur_active_monster:wait()
	end,

	[5] = function(target_pos_num)
		pve_game_ctrl:Instance().cur_active_monster:useSkill(target_pos_num)
	end,
}

function pve_game_ctrl:new()
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
 
function pve_game_ctrl:Instance()
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

function pve_game_ctrl:initGame(left_team,right_team,map,chapter_num,level_num)
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

function pve_game_ctrl:startGame()
	self.is_auto = false
	self.cur_round_num = 1
	self.cur_active_monster_index = 1
	self.cur_active_monster = self.cur_round_monster_queue[self.cur_active_monster_index]
	self.cur_game_status = pve_game_ctrl.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(pve_game_ctrl.Order.ACTIVATE)
end

function pve_game_ctrl:runGame(order, param1, param2)
	local action = pve_game_ctrl.OPERATE[order]
	action(param1,param2)
end

function pve_game_ctrl:gameOver(win_side)
	self:setGameStatus(pve_game_ctrl.GameStatus.OVER)
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

function pve_game_ctrl:nextMonsterActivate(is_wait)
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
		self:runGame(pve_game_ctrl.Order.ACTIVATE,is_wait)
	end
end

function pve_game_ctrl:startNextRound()
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
	self.cur_game_status = pve_game_ctrl.GameStatus.ACTIVE
	self:updateMapInfo()
	self:runGame(pve_game_ctrl.Order.ACTIVATE)
end

function pve_game_ctrl:aliveMonsterEnterNewRound()
	local all_alive_monster = self:getAllAliveMonsters()
	for k,v in pairs(all_alive_monster) do
		v:onEnterNewRound(self.cur_round_num)
	end
end

function pve_game_ctrl:updateMapInfo()
	self.map_info = {}

	for k,v in pairs(self.map) do
		table.insert(self.map_info,k,v)
	end
	
	local monsters = self:getAllAliveMonsters()
	for k,v in pairs(monsters) do
		self.map_info[gtool:ccpToInt(v.cur_pos)] = v
	end
end

function pve_game_ctrl:changeGameStatus(status)
	self.cur_game_status = status
	self:updateMapInfo()
	self.scene:updateMapView()
end

function pve_game_ctrl:selectPos(node)
	if self.map_info[gtool:ccpToInt(node.arena_pos)] then
		uitool:createTopTip("you can't do that!")
	else
		self:runGame(pve_game_ctrl.Order.MOVE, node.arena_pos)
	end
end

function pve_game_ctrl:selectTarget(num,distance)
	if self.map_info[num] and self.map_info[num]:isMonster() then
		if not self:getIsUseSkill() then
			self:runGame(pve_game_ctrl.Order.ATTACK, self.map_info[num],distance)
		else
			self:runGame(pve_game_ctrl.Order.USE_SKILL, num)
			self:setIsUseSkill(false)
		end
	end
end

function pve_game_ctrl:requestDefend()
	self:runGame(pve_game_ctrl.Order.DEFEND)
end

function pve_game_ctrl:requestWait()
	self:runGame(pve_game_ctrl.Order.WAIT)

end

function pve_game_ctrl:requestAuto()
	self:setAuto(true)
	if self:getGameStatus() == pve_game_ctrl.GameStatus.WAIT_ORDER then
		self.cur_active_monster:runAI()
	end
	self:setGameStatus(pve_game_ctrl.GameStatus.AUTO)
end

function pve_game_ctrl:stopAuto()
	self:setAuto(false)
end

function pve_game_ctrl:checkGameOver(is_buff)
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

function pve_game_ctrl:setIsUseSkill(is_use_skill)
	self.is_use_skill = is_use_skill
end

function pve_game_ctrl:setScene(scene)
	self.action_node = cc.Node:create()
	self.scene = scene
	self.scene:addChild(self.action_node)
end

function pve_game_ctrl:getScene(scene)
	return self.scene
end

function pve_game_ctrl:getGameResult(win_side)
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

	result.chapter_num = self.chapter_num
	result.level_num = self.level_num

	return result
end

function pve_game_ctrl:getDeadMonsterNum()
	local num = 0

	for k,v in pairs(self.left_team) do
		if v:isDead() then
			num = num + 1
		end
	end

	return num
end

function pve_game_ctrl:getNextMonster()
	self.cur_active_monster_index = self.cur_active_monster_index + 1
	return self.cur_round_monster_queue[self.cur_active_monster_index]
end

function pve_game_ctrl:getIsUseSkill()
	return self.is_use_skill
end

function pve_game_ctrl:setAuto(is_auto)
	self.is_auto = is_auto
end

function pve_game_ctrl:getAuto()
	return self.is_auto
end

function pve_game_ctrl:getMap()
	return self.map
end

function pve_game_ctrl:getMapInfo()
	self:updateMapInfo()
	return self.map_info
end

function pve_game_ctrl:getActionNode()
	return self.action_node
end

function pve_game_ctrl:setGameStatus(status)
	self.cur_game_status = status
end

function pve_game_ctrl:getGameStatus()
	return self.cur_game_status
end

function pve_game_ctrl:setGameSpeed(speed)
	self.game_speed = speed
end

function pve_game_ctrl:getGameSpeed()
	return self.game_speed
end

function pve_game_ctrl:getCurRoundNum()
	return self.cur_round_num
end

function pve_game_ctrl:getCurActiveMonsterIndex()
	return self.cur_active_monster_index
end

function pve_game_ctrl:getCurActiveMonster()
	return self.cur_active_monster
end

function pve_game_ctrl:getCurRoundMonsterQueue()
	return self.cur_round_monster_queue
end

function pve_game_ctrl:getNextRoundMonsterQueue()
	return self.next_round_monster_queue
end

function pve_game_ctrl:getCurStoryAndLevelNum()
	return self.chapter_num,self.level_num
end

function pve_game_ctrl:isWaitOrder()
	return self.cur_game_status == pve_game_ctrl.GameStatus.WAIT_ORDER
end

function pve_game_ctrl:isGameOver()
	return self.cur_game_status == pve_game_ctrl.GameStatus.OVER
end

function pve_game_ctrl:getAllMonsters()
	local all = {}
	
	for _,v in pairs(self.left_team) do
		table.insert(all,v)
	end

	for _,v in pairs(self.right_team) do
		table.insert(all,v)
	end

	return all
end


function pve_game_ctrl:getAllAliveMonsters()
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

function pve_game_ctrl:getLeftAliveMonsters()
	local all = {}
	
	for _,v in pairs(self.left_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	return all
end

function pve_game_ctrl:getRightAliveMonsters()
	local all = {}
	
	for _,v in pairs(self.right_team) do
		if not v:isDead() then
			table.insert(all,v)
		end
	end

	return all
end

function pve_game_ctrl:sortAllMonstersByInitiative()
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

function pve_game_ctrl:sortMonstersByInitiative(list)
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

	table.sort(list,sort_by_initiative)
end

function pve_game_ctrl:getAllAliveMonstersInNextRoundQueue()
	local list = {}
	
	for _,v in pairs(self.next_round_monster_queue) do
		if not v:isDead() then
			table.insert(list,v)
		end
	end

	return list
end

function pve_game_ctrl:getAllAliveMonstersInCurRoundQueue()
	local list = {}
	
	for _,v in pairs(self.cur_round_monster_queue) do
		if not v:isDead() then
			table.insert(list,v)
		end
	end

	return list
end

function pve_game_ctrl:getMonsterIndexInNextRoundAliveMonster(monster)
	local next_round_alive_monsters = self:getAllAliveMonstersInNextRoundQueue()
	local index = 1
	--self:sortMonstersByInitiative(next_round_alive_monsters)
	for i,v in ipairs(next_round_alive_monsters) do
		if v:getTag() == monster:getTag() then
			index = i 
			break
		end
	end

	return index
end

function pve_game_ctrl:getMonsterIndexInCurRoundAliveMonster(monster)
	local cur_round_alive_monsters = self:getAllAliveMonstersInCurRoundQueue()
	local index = 1
	--self:sortMonstersByInitiative(cur_round_alive_monsters)
	for i,v in ipairs(cur_round_alive_monsters) do
		if v:getTag() == monster:getTag() then
			index = i 
			break
		end
	end

	return index
end

function pve_game_ctrl:getPositionByInt(num)
	return self.scene.map_view:getPositionByInt(num)
end

function pve_game_ctrl:getMapTopArenaNode()
	return self.scene.map_view.arena_top_node
end

function pve_game_ctrl:clearTeam()
	self.left_team = {}

	self.right_team = {}

end