
local PreScene = class("PreScene", cc.load("mvc").SceneBase)


-- 加载csb文件
PreScene.RESOURCE_FILENAME = "PreScene.csb"
PreScene.RESOURCE_BINDING = {
    ["cocos_logo_sp"]			= {["varname"] = "cocos_logo_sp"},
    ["game_logo_sp"]			= {["varname"] = "game_logo_sp"},
 }

function PreScene:onCreate()
	local ac1 = self.cocos_logo_sp:runAction(cc.FadeIn:create(2))
	local ac2 = self.cocos_logo_sp:runAction(cc.DelayTime:create(1))
	local ac3 = self.cocos_logo_sp:runAction(cc.FadeOut:create(1))
	
	local ac4 = self.game_logo_sp:runAction(cc.FadeOut:create(4))
	local ac5 = self.game_logo_sp:runAction(cc.FadeIn:create(2))
	local ac6 = self.game_logo_sp:runAction(cc.DelayTime:create(1))
	local ac7 = self.game_logo_sp:runAction(cc.FadeOut:create(1))
	
	local callback = cc.CallFunc:create(handler(self,self.goToMainScene))

	local seq1 = cc.Sequence:create(ac0,ac1,ac2,ac3)
	self.cocos_logo_sp:runAction(seq1)
	local seq2 = cc.Sequence:create(ac4,ac5,ac6,ac7,callback)
	self.game_logo_sp:runAction(seq2)

end

function PreScene:goToMainScene()
	--self:getApp():enterScene("MainScene",nil,10)
	
    local scene = cc.Scene:create()
    local layer = self.app_:createView("MainScene")
    scene:addChild(layer)
	if scene then
		local ts = cc.TransitionFade:create(0.5, scene)
		cc.Director:getInstance():replaceScene(ts)
	end
end

return PreScene
