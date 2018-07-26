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
        self:closeView()
    end)
    uitool:makeImgToButton(self.go_img,function(sender)
    	self:closeView()
    	self.ctrl:closeAdventureView()
    	self.ctrl:openReadyView()
    end)
end

function confirm_view:updateView()

end


return confirm_view