
local MainScene = class("MainScene", cc.load("mvc").ViewBase)


-- 加载csb文件
MainScene.RESOURCE_FILENAME = "MainScene.csb"
 
-- 获取UI控件
MainScene.RESOURCE_BINDING = {
	--main_panel
    ["main_panel"]			= {["varname"] = "mian_panel"},
    ["title_left_node"]		= {["varname"] = "title_left_node"},
    ["title_face_sp"]		= {["varname"] = "title_face_sp"},
    ["title_btn"]			= {["varname"] = "title_btn"},
    ["flag_sp"]				= {["varname"] = "flag_sp"},
    ["nick_name_text"]		= {["varname"] = "nick_name_text"},
    ["mail_btn"]			= {["varname"] = "mail_btn"},
    ["exp_now_img"]			= {["varname"] = "exp_now_img"},
    ["level_text"]			= {["varname"] = "level_text"},
    ["crystal_num_text"]	= {["varname"] = "crystal_num_text"},
    ["add_crystal_btn"]		= {["varname"] = "add_crystal_btn"},
    ["coin_num_text"]		= {["varname"] = "coin_num_text"},
    ["add_coin_btn"]		= {["varname"] = "add_coin_btn"},
	
	--setting_panel
    ["setting_panel"]		= {["varname"] = "setting_panel"},
	["close_btn"]			= {["varname"] = "close_btn"},

}


function MainScene:onCreate()
	print("MainScene:onCreate()")
	self:mainInfoInit()
	self:mainLayoutButtonInit()
end

function MainScene:mainInfoInit()
	self.coin_num = self.coin_num_text:getString()
	self.crystal_num = self.crystal_num_text:getString()
	
end

function MainScene:mainLayoutButtonInit()
	self.add_coin_btn:addClickEventListener(function(sender)
        self.coin_num_text:setString(self.coin_num+1)
		self.coin_num = self.coin_num_text:getString()
    end)

	self.add_crystal_btn:addClickEventListener(function(sender)
        self.crystal_num_text:setString(self.crystal_num + 1)
		self.crystal_num = self.crystal_num_text:getString()
    end)

	self.close_btn:addClickEventListener(function(sender)
        self.setting_panel:setVisible(false)
    end)

	self.title_btn:addClickEventListener(function(sender)
        self.setting_panel:setVisible(true)
    end)
end

return MainScene
