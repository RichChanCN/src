local view = require("packages.mvc.ViewBase")

local main_view = view:instance()

main_view.RESOURCE_BINDING = {
	["title_left_node"]		= {["varname"] = "title_left_node"},
    ["center_node"]			= {["varname"] = "center_node"},
	["bottom_node"]		    = {["varname"] = "bottom_node"},

	["train_img"]			= {["varname"] = "train_img"},
    ["bottom_node"]         = {["varname"] = "bottom_node"},
    ["monster_btn"]         = {["varname"] = "monster_btn"},
}

function main_view:initUI()
    self:initTitleLeftNode()
    self:initCenterNode()
    self:initBottomNode()
end

-- function main_view:initInfo()
--     local player_data = self.ctrl:getPlayerData()
--     self.nickname = player_data.nickname
--     self.face_sp = player_data.face_sp
--     self.exp = player_data.exp
--     self.level = player_data.level
-- end

function main_view:initEvents()
	uitool:makeImgToButton(self.adventure_img,function(sender)
        self.ctrl:openAdventureView()
        self:closeView()
    end)

    uitool:makeImgToButton(self.train_img,nil)

    uitool:makeImgToButtonNoScale(self.title_face_sp, function ()
        self.ctrl:openSettingView()
    end)

    self:initRightBottomBtnEvents()
end

function main_view:updateInfo()
    local player_data = self.ctrl:getPlayerData()
    self.nickname = player_data.nickname
    self.face_sp = player_data.face_sp
    self.exp = player_data.exp
    self.level = player_data.level
end

function main_view:updateView()
    self.nickname_text:setString(self.nickname)
    self.title_face_sp:setTexture(Config.monster_img_path..self.face_sp)
    self.nickname_text:setString(self.nickname)
    self.level_text:setString(self.level)
    uitool:setProgressBar(self.exp_now_img, self.exp/(100+(self.level-1)*20))
end

function main_view:onOpen()
    self:updateInfo()
    self:updateView()
end

----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------
function main_view:initTitleLeftNode()
    self.title_face_sp          = self.title_left_node:getChildByName("title_face_sp")
    self.title_face_frame_sp    = self.title_left_node:getChildByName("title_face_frame_sp")
    self.flag_sp                = self.title_left_node:getChildByName("flag_sp")
    self.nickname_text          = self.title_left_node:getChildByName("nickname_text")
    self.mail_btn               = self.title_left_node:getChildByName("mail_btn")
    self.exp_node               = self.title_left_node:getChildByName("exp_node")
    self.exp_now_img            = self.exp_node:getChildByName("exp_now_img")
    self.level_text             = self.exp_node:getChildByName("level_text")
end

function main_view:initCenterNode()
    self.adventure_img = self.center_node:getChildByName("adventure_img")
    self.train_img = self.center_node:getChildByName("train_img")
end

function main_view:initBottomNode()
    self.monster_btn = self.bottom_node:getChildByName("monster_btn")
end

function main_view:initRightBottomBtnEvents()
    self.monster_btn:addClickEventListener(function(sender)
        self.ctrl:openMonsterListView()
    end)
end

return main_view