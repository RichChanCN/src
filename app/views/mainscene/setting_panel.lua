local layout = require("packages.mvc.LayoutBase")

local setting_panel = {}

setmetatable(setting_panel, { __index = layout })

setting_panel.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
}


function setting_panel:initInfo()
end

function setting_panel:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self:closeView()
    end)
end

function setting_panel:updateView()

end


return setting_panel