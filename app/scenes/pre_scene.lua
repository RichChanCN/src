
local pre_scene = class("pre_scene", cc.load("mvc").SceneBase)


-- 加载csb文件
pre_scene.RESOURCE_FILENAME = "pre_scene.csb"
pre_scene.RESOURCE_BINDING = {
    ["cocos_logo_sp"]			= {["varname"] = "cocos_logo_sp"},
    ["game_logo_sp"]			= {["varname"] = "game_logo_sp"},
 }

pre_scene.on_create = function(self)
	self:begin_animation()
	self:pre_load_main_scene()
end

pre_scene.begin_animation = function(self)
	local ac1 = self.cocos_logo_sp:runAction(cc.FadeIn:create(2))
	local ac2 = self.cocos_logo_sp:runAction(cc.DelayTime:create(1))
	local ac3 = self.cocos_logo_sp:runAction(cc.FadeOut:create(1))
	
	local ac4 = self.game_logo_sp:runAction(cc.FadeOut:create(4))
	local ac5 = self.game_logo_sp:runAction(cc.FadeIn:create(2))
	local ac6 = self.game_logo_sp:runAction(cc.DelayTime:create(1))
	local ac7 = self.game_logo_sp:runAction(cc.FadeOut:create(1))
	
	local callback = cc.CallFunc:create(handler(self,self.go_to_main_scene))

	-- local cb = function()
	-- 	self:go_to_main_scene()
	-- end
	
	-- local callback = cc.CallFunc:create(handler(self,cb))
	
	local seq1 = cc.Sequence:create(ac0,ac1,ac2,ac3)
	self.cocos_logo_sp:runAction(seq1)
	local seq2 = cc.Sequence:create(ac4,ac5,ac6,ac7,callback)
	self.game_logo_sp:runAction(seq2)
end

pre_scene.pre_load_main_scene = function(self)
	local start_time = os.clock();
    self.app_:create_view("main_scene")
	local end_time = os.clock();

	print(string.format("cost time  : %.4f", end_time - start_time))
end

pre_scene.go_to_main_scene = function(self)
	local start_time = os.clock();
	local layer = self.app_:create_view("main_scene")
	local end_time = os.clock();
	print(string.format("cost time  : %.4f", end_time - start_time))
	local scene = cc.Scene:create()
    scene:addChild(layer)
	if scene then
		local ts = cc.TransitionFade:create(0.5, scene)
		cc.Director:getInstance():replaceScene(ts)
	end
end

return pre_scene
