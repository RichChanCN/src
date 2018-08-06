
local FightScene = class("FightScene", cc.load("mvc").SceneBase)


-- 加载csb文件
FightScene.RESOURCE_FILENAME = "FightScene.csb"

FightScene.RESOURCE_BINDING = {
	--map_view
    ["map_view"]			= {["varname"] = "map_view"},
	--map_view
    ["battle_info_view"]	= {["varname"] = "battle_info_view"},
 }

--面板文件位置
FightScene.VIEW_PATH = "app.views.fightscene"

FightScene.Wait_Time = 1
FightScene.Action_Time = 0.3

function FightScene:onCreate()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
end

function FightScene:onEnter()
	self:viewInit()
	self:initModel()
	self.map_view.root:setScale(0.75)
end

function FightScene:onEnterTransitionFinish()
	cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
	self.map_view:beginAnimation()
end

function FightScene:startGame()
	Judgment:Instance():setScene(self)
	Judgment:Instance():startGame()
	self.battle_info_view:openView()
end

function FightScene:gameOver()
	self.map_view:endAnimation()
end

function FightScene:initModel()
	local all_monster = Judgment:Instance():getAllMonsters()
	for _,v in pairs(all_monster) do
		self.map_view:createModel(v)
	end
end

function FightScene:viewInit()
	self.map_view:init()
	self.battle_info_view:init()
end

function FightScene:updateMapView()
	self.map_view:updateView()
end

function FightScene:closeBattleInfoView()
	self.battle_info_view:closeView()
end

return FightScene
