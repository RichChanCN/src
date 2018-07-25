local layout = require("packages.mvc.LayoutBase")

local confirm_panel = {}

setmetatable(confirm_panel, { __index = layout })

confirm_panel.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_btn"]				= {["varname"] = "go_btn"},
}

function confirm_panel:initInfo()
end

function confirm_panel:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self:closeView()
    end)
    self.go_btn:addClickEventListener(function(sender)
    	self:closeView()
    	self.ctrl:openReadyView()
    end)
end

function confirm_panel:updateView()

end


return confirm_panel