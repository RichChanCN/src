
local MainScene = class("MainScene", cc.load("mvc").SceneBase)


-- 加载csb文件
MainScene.RESOURCE_FILENAME = "MainScene.csb"
 
-- 获取UI控件
MainScene.RESOURCE_BINDING = {
	--main_view
    ["main_view"]			= {["varname"] = "main_view"},
	--title_right_view
    ["title_right_view"]	= {["varname"] = "title_right_view"},
	--setting_view
    ["setting_view"]		= {["varname"] = "setting_view"},
	--advence_panel
    ["adventure_view"]		= {["varname"] = "adventure_view"},
	--confirm_view
    ["confirm_view"]		= {["varname"] = "confirm_view"},
	--embattle_view
    ["embattle_view"]			= {["varname"] = "embattle_view"},

}

--面板文件位置
MainScene.VIEW_PATH = "app.views.mainscene"

function MainScene:onCreate()
	self:viewInit()
end

function MainScene:viewInit()
	self.main_view:init()
	self.title_right_view:init()
	self.setting_view:init()
	self.adventure_view:init()
	self.confirm_view:init()
	self.embattle_view:init()
end

function MainScene:openMainView()
	if self.main_view then
		self.main_view:openView()
	end
end

function MainScene:closeMainView()
	if self.main_view then
		self.main_view:closeView()
	end
end

function MainScene:openAdventureView()
	if self.adventure_view then
		self.adventure_view:openView()
	end
end

function MainScene:closeAdventureView()
	if self.adventure_view then
		self.adventure_view:closeView()
	end
end

function MainScene:openConfirmView()
	if self.confirm_view then
		self.confirm_view:openView()
	end
end

function MainScene:openSettingView()
	if self.setting_view then
		self.setting_view:openView()
	end
end

function MainScene:openReadyView()
	if self.embattle_view then
		self.embattle_view:openView()
	end
end
return MainScene
