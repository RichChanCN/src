local layout = require("packages.mvc.LayoutBase")

local confirm_panel = layout:instance()

confirm_panel.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_img"]				= {["varname"] = "go_img"},
}

function confirm_panel:initInfo()
end

function confirm_panel:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self:closeView()
    end)
    uitool:makeImgToButton(self.go_img,function(sender)
    	self:closeView()
    	self.ctrl:closeAdventureView()
    	self.ctrl:openReadyView()
    end)
end

function confirm_panel:updateView()

end


return confirm_panel