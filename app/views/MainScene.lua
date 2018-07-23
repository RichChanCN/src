
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
	
	["adventure_frame_img"]	= {["varname"] = "adventure_frame_img"},

	--setting_panel
    ["setting_panel"]		= {["varname"] = "setting_panel"},
	["close_btn"]			= {["varname"] = "close_btn"},

	--advence_panel
    ["advence_panel"]		= {["varname"] = "advence_panel"},
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["chapter_sv"]			= {["varname"] = "chapter_sv"},
	["left_btn"]			= {["varname"] = "left_btn"},
	["right_btn"]			= {["varname"] = "right_btn"},


}


function MainScene:onCreate()
	self:mainInfoInit()
	self:mainLayoutButtonInit()
end

function MainScene:mainInfoInit()
	self.coin_num = self.coin_num_text:getString()
	self.crystal_num = self.crystal_num_text:getString()
	self.cur_chapter_num = 1
	self.left_btn:setVisible(false)
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
	
	self.adventure_frame_img:addClickEventListener(function(sender)
        self.advence_panel:setPosition(0,0)
    end)

	self.back_btn:addClickEventListener(function(sender)
        self.advence_panel:setPosition(10000,10000)
    end)

	self.close_btn:addClickEventListener(function(sender)
        self.setting_panel:setPosition(10000,10000)
    end)

	self.title_btn:addClickEventListener(function(sender)
        self.setting_panel:setPosition(0,0)
    end)

	self.right_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 1 then
			self.chapter_sv:scrollToPercentHorizontal(50,0.5,true)
			self.cur_chapter_num = 2
			self.left_btn:setVisible(true)
		elseif self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToRight(0.5,true)
			self.cur_chapter_num = 3
			self.right_btn:setVisible(false)
		end
    end)

	self.left_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToLeft(0.5,true)
			self.left_btn:setVisible(false)
			self.cur_chapter_num = 1
		elseif self.cur_chapter_num == 3 then
			self.chapter_sv:scrollToPercentHorizontal(50,0.5,true)
			self.right_btn:setVisible(true)
			self.cur_chapter_num = 2
		end
    end)
	
end

return MainScene
