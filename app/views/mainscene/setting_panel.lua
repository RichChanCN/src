local LayoutBase = require("packages.mvc.LayoutBase")
local setting_panel = {}

setting_panel.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
}

function setting_panel:new( root, ctrl, data )
	local o = LayoutBase:new(root,ctrl,data)
  	setmetatable(o, self)
  	self.__index = self

	return o
end

function setting_panel:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)

	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function setting_panel:initInfo()
end

function setting_panel:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self:closeView()
    end)
end

function setting_panel:updateView()

end

function setting_panel:openView()
	self.root:setPosition(uitool:zero())
end

function setting_panel:closeView()
	self.root:setPosition(uitool:farAway())
end

return setting_panel