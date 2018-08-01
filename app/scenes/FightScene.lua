
local FightScene = class("FightScene", cc.load("mvc").SceneBase)


-- 加载csb文件
FightScene.RESOURCE_FILENAME = "FightScene.csb"

FightScene.RESOURCE_BINDING = {
	--map_view
    ["map_view"]			= {["varname"] = "map_view"},
 }

--面板文件位置
FightScene.VIEW_PATH = "app.views.fightscene"

function FightScene:onCreate()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
end

function FightScene:onEnter()
	self:viewInit()
end

function FightScene:onEnterTransitionFinish()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
end

function FightScene:viewInit()
	self.map_view:init()
end

return FightScene
