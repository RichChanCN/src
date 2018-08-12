
local FightScene = class("FightScene", cc.load("mvc").SceneBase)


-- 加载csb文件
FightScene.RESOURCE_FILENAME = "FightScene.csb"

FightScene.RESOURCE_BINDING = {
	--map_view
    ["map_view"]			= {["varname"] = "map_view"},
	--map_view
    ["battle_info_view"]	= {["varname"] = "battle_info_view"},
 	--result_view
 	["result_view"]			= {["varname"] = "result_view"},
 }

--面板文件位置
FightScene.VIEW_PATH = "app.views.fightscene"
FightScene.Wait_Time = 1
FightScene.Action_Time = 0.3

function FightScene:onCreate()
	self.map_data = require("app.data.MapData")
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
end

function FightScene:onEnter()
	self:viewInit()
	self:initModel()
	self.map_view.root:setScale(0.75)
end

function FightScene:onExit()
	Judgment:Instance():clearAllMonsters()
	self.map_view:clearModelPanel()
end

function FightScene:onEnterTransitionFinish()
	cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
	self.map_view:beginAnimation()
end

function FightScene:startGame()
	Judgment:Instance():setScene(self)
	Judgment:Instance():startGame()
	self:openBattleInfoView()
end

function FightScene:gameOver(result)
	self:setResult(result)
	self.map_view:endAnimation()
end

function FightScene:goToMainScene()
	cc.Director:getInstance():popScene()
end

function FightScene:initModel()
	local map = Judgment:Instance():getMap()
	for k,v in pairs(map) do
		self.map_view:createOtherModel(v,gtool:intToCcp(k))
	end

	local all_monster = Judgment:Instance():getAllMonsters()
	for _,v in pairs(all_monster) do
		self.map_view:createMonsterModel(v)
	end
end

function FightScene:viewInit()
	self.map_view:init()
	--self.battle_info_view:init()
end

function FightScene:updateMapView()
	self.map_view:updateView()
end


function FightScene:updateBattleQueue(is_wait)
	self.battle_info_view:updateRightBottomQueue(is_wait)
end

function FightScene:getParticleNode()
	return self.battle_info_view.particle_node
end

function FightScene:openBattleInfoView()
	self.battle_info_view:openView()
end

function FightScene:closeBattleInfoView()
	self.battle_info_view:closeView()
end

function FightScene:setResult(result)
	self.result_view:setResult(result)
end

function FightScene:openResultView()
	self.result_view:openView()
end

function FightScene:closeResultView()
	self.result_view:closeView()
end

function FightScene:showGuide()
	self.map_view:showGuide()
end

function FightScene:showOtherAroundInfo(monster)
	self.map_view:showOtherAroundInfo(monster)
end

function FightScene:hideOtherAroundInfo()
	self.map_view:hideOtherAroundInfo()
end

return FightScene
