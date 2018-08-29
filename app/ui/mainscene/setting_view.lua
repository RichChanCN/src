local view = require("packages.mvc.view_base")

local setting_view = view:instance()

setting_view.RESOURCE_BINDING = 
{
    ["close_btn"]			= {["varname"] = "close_btn"},
}


setting_view.init_info = function(self)
end

setting_view.init_events = function(self)
	self.close_btn:addClickEventListener(function(sender)
        self:close_view()
    end)
end

setting_view.update_view = function(self)

end


return setting_view