local setting_panel = {}

setting_panel.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
}

function setting_panel:create( root, ctrl, data )
	self.root = root
	self.ctrl = ctrl
	self.data = data
	self.isInited = false

	return self
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