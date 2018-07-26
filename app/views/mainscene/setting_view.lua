local view = require("packages.mvc.ViewBase")

local setting_view = view:instance()

setting_view.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
}


function setting_view:initInfo()
end

function setting_view:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self:closeView()
    end)
end

function setting_view:updateView()

end


return setting_view