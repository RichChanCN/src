Judgment = {}

Judgment.GameStatus = {
	RUN 			= 1,
	WAIT_FOR_ORDER 	= 2,
}

function Judgment:new()
	local o = {}
	setmetatable(o,self)
	self.__index = self
	
	self.left_team = {}
	self.right_team = {}
	self.all_monsters = {}

	return o
end

function Judgment:setScene(scene)
	self.scene = scene
end
 
function Judgment:Instance()
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

function Judgment:initGame(left_team,right_team)
	self.left_team = left_team
	self.right_team = right_team

	self.all_monsters = self:getAllMonsters()
	self:sortAllMonstersByInitiative()
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