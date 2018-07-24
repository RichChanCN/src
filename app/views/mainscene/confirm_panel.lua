local layout = require("packages.mvc.LayoutBase")

local confirm_panel = {}

setmetatable(confirm_panel, { __index = layout })

confirm_panel.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_btn"]				= {["varname"] = "go_btn"},
}

function confirm_panel:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)

	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function confirm_panel:initInfo()
end

function confirm_panel:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self:closeView()
    end)
end

function confirm_panel:updateView()

end


return confirm_panel