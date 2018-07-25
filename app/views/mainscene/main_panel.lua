local layout = require("packages.mvc.LayoutBase")

local main_panel = layout:instance()

main_panel.RESOURCE_BINDING = {
	["title_left_node"]		= {["varname"] = "title_left_node"},
    ["title_face_sp"]		= {["varname"] = "title_face_sp"},
    ["title_btn"]			= {["varname"] = "title_btn"},
    ["flag_sp"]				= {["varname"] = "flag_sp"},
    ["nick_name_text"]		= {["varname"] = "nick_name_text"},
    ["mail_btn"]			= {["varname"] = "mail_btn"},
    ["exp_now_img"]			= {["varname"] = "exp_now_img"},
    ["level_text"]			= {["varname"] = "level_text"},
	["adventure_img"]		= {["varname"] = "adventure_img"},
	["train_img"]			= {["varname"] = "train_img"},
}

function main_panel:initInfo()

end

function main_panel:initEvents()
	uitool:makeImgToButton(self.adventure_img,
	function(sender)
        self.ctrl:openAdventureView()
        self:closeView()
    end)

    uitool:makeImgToButton(self.train_img,nil)

	self.title_btn:addClickEventListener(function(sender)
        self.ctrl:openSettingView()
    end)
end

function main_panel:updateView()

end

return main_panel