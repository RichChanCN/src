GameDataCtrl = GameDataCtrl or {}

function GameDataCtrl:new()
	local o = {}
	setmetatable(o,self)
	self.__index = self
	
	self.save_data = {}
	self.map_data = {}
	self.monster_data = {}

	return o
end
 
function GameDataCtrl:Instance()
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

function GameDataCtrl:init()
 	self.save_data = require("app.data.SaveData")
 	self.save_data:init()
 	self.map_data = require("app.data.MapData")
 	self.monster_data = require("app.data.MonsterData")
 end

function GameDataCtrl:registerScene(scene)
	self[scene.name_] = scene
end

function GameDataCtrl:getMapData()
	return self.map_data
end

function GameDataCtrl:getMapDataByStoryAndLevel(chapter_num,level_num)
	return self.map_data:getMapDataByStoryAndLevel(chapter_num,level_num)
end

function GameDataCtrl:getRewardByChapterAndLevel(chapter_num,level_num)
	return self.map_data:getRewardByChapterAndLevel(chapter_num,level_num)
end

function GameDataCtrl:getSaveData()
	return self.save_data
end

function GameDataCtrl:saveData()
	return self.save_data:save()
end

function GameDataCtrl:setStarNum(chapter_num,level_num,num)
	self.save_data:setStarNum(chapter_num,level_num,num)
end

function GameDataCtrl:addRewardToSaveData(reward)
	for k1,v1 in pairs(reward) do
	    if k1 == "monster" then
	        for k2,v2 in pairs(v1) do
	            self.save_data:addMonsterCardNum(k2,v2)
	        end
	    elseif k1 == "coin" and v1 > 0 then
	        self.save_data:addCoinNum(v1)
	    elseif k1 == "crystal" and v1 > 0 then
	        self.save_data:addCrystalNum(v1)
	    elseif k1 == "exp" and v1 > 0 then
	        self.save_data:addExp(v1)
	    end
	end

	self.save_data:save()
end

function GameDataCtrl:getStarNumByChapterAndLevel(chapter_num,level_num)
	return self.save_data:getStarNumByChapterAndLevel(chapter_num,level_num)
end

function GameDataCtrl:getPlayerData()
	return self.save_data:getPlayerData()
end

function GameDataCtrl:getMonsterData()
	return self.monster_data
end

function GameDataCtrl:getCollectedMonsterList()
	return Config.Monster
end
