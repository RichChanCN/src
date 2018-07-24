local title_right_node = {}

title_right_node.RESOURCE_BINDING = {
    ["crystal_num_text"]	= {["varname"] = "crystal_num_text"},
    ["add_crystal_btn"]		= {["varname"] = "add_crystal_btn"},
    ["coin_num_text"]		= {["varname"] = "coin_num_text"},
    ["add_coin_btn"]		= {["varname"] = "add_coin_btn"},
}

function title_right_node:create( root, ctrl, data )
	self.root = root
	self.ctrl = ctrl
	self.data = data
	self.isInited = false

	return self
end

function title_right_node:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)

	self:initInfo()
	self:initEvents()
	
	self.isInited = true
end

function title_right_node:initInfo()
	self.coin_num = self.coin_num_text:getString()
	self.crystal_num = self.crystal_num_text:getString()
end

function title_right_node:initEvents()
	self.add_coin_btn:addClickEventListener(function(sender)
        self.coin_num_text:setString(self.coin_num+1)
		self.coin_num = self.coin_num_text:getString()
    end)

	self.add_crystal_btn:addClickEventListener(function(sender)
        self.crystal_num_text:setString(self.crystal_num + 1)
		self.crystal_num = self.crystal_num_text:getString()
    end)
end

function title_right_node:updateView()

end

return title_right_node