
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
	self:initModel()
	self.map_view.root:setScale(0.75)
	--cc.Camera:getDefaultCamera():setPosition3D(cc.vec3(960,540,1200))
end

function FightScene:onEnterTransitionFinish()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)

    local ac1 = self.map_view.root:runAction(cc.ScaleTo:create(1,0.75))
    local ac2 = self.map_view.root:runAction(cc.ScaleTo:create(0.3,1))
    local callback = cc.CallFunc:create(handler(self,self.startGame))

    local seq1 = cc.Sequence:create(ac1,ac2,callback)
	
	self.map_view.root:runAction(seq1)
end

function FightScene:startGame()
	Judgment:Instance():startGame()
	Judgment:Instance():setScene(self)
end

function FightScene:initModel()
	for _,v in pairs(Judgment:Instance().left_team) do
		self.map_view:createModel(v)
	end
end

function FightScene:viewInit()
	self.map_view:init()
end

function FightScene:updateMapView()
	self.map_view:updateView()
end

return FightScene
