local view = require("packages.mvc.ViewBase")

local confirm_view = view:instance()

confirm_view.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_img"]				= {["varname"] = "go_img"},
}

function confirm_view:initInfo()
end

function confirm_view:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self.ctrl:closeConfirmView()
    end)
    uitool:makeImgToButton(self.go_img,function(sender)
    	self.ctrl:closeConfirmView()
    	self.ctrl:openEmbattleView()
    end)
end

function confirm_view:updateView()

end


return confirm_view