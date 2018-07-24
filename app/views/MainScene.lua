
local MainScene = class("MainScene", cc.load("mvc").ViewBase)


-- ����csb�ļ�
MainScene.RESOURCE_FILENAME = "MainScene.csb"
 
-- ��ȡUI�ؼ�
MainScene.RESOURCE_BINDING = {
	--main_panel
    ["main_panel"]			= {["varname"] = "main_panel"},
	--title_right_node
    ["title_right_node"]	= {["varname"] = "title_right_node"},
	--setting_panel
    ["setting_panel"]		= {["varname"] = "setting_panel"},
	--advence_panel
    ["adventure_panel"]		= {["varname"] = "adventure_panel"},
	--confirm_panel
    ["confirm_panel"]		= {["varname"] = "confirm_panel"},

}

--����ļ�λ��
MainScene.VIEW_PATH = "app.views.mainscene"

function MainScene:onCreate()
	self:panelInit()
end

function MainScene:panelInit()
	self.main_panel:init()
	self.title_right_node:init()
	self.setting_panel:init()
	self.adventure_panel:init()
	self.confirm_panel:init()
end

function MainScene:openAdventureView()
	if self.adventure_panel then
		self.adventure_panel:openView()
	end
end

function MainScene:openConfirmView()
	if self.confirm_panel then
		self.confirm_panel:openView()
	end
end

function MainScene:openSettingView()
	if self.setting_panel then
		self.setting_panel:openView()
	end
end

return MainScene
