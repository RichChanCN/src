local view = require("packages.mvc.ViewBase")

local main_view = view:instance()

main_view.RESOURCE_BINDING = {
	["title_left_node"]		= {["varname"] = "title_left_node"},
    ["title_btn"]			= {["varname"] = "title_btn"},
	["adventure_img"]		= {["varname"] = "adventure_img"},
	["train_img"]			= {["varname"] = "train_img"},
    ["bottom_node"]         = {["varname"] = "bottom_node"},
    ["monster_btn"]         = {["varname"] = "monster_btn"},
}

function main_view:initInfo()

end

function main_view:initEvents()
	uitool:makeImgToButton(self.adventure_img,
	function(sender)
        self.ctrl:openAdventureView()
        self:closeView()
    end)

    uitool:makeImgToButton(self.train_img,nil)
	self.title_btn:addClickEventListener(function(sender)
        self.ctrl:openSettingView()
    end)

    self:initRightBottomBtnEvents()
end

function main_view:updateView()

end

----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

function main_view:initRightBottomBtnEvents()
    self.monster_btn:addClickEventListener(function(sender)
        self.ctrl:openMonsterListView()
    end)
end

return main_view