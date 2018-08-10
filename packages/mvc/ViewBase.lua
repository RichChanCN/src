local ViewBase = {}

function ViewBase:instance()
	return setmetatable({}, { __index = self })
end

function ViewBase:new( name, root, ctrl)
	self.name = name
	self.root = root
	self.ctrl = ctrl
	self.is_inited = false

	return self
end

function ViewBase:init()
	if not self.is_inited then
		uitool:createUIBinding(self, self.RESOURCE_BINDING)

		self:initUI()
		self:initInfo()
		self:initEvents()

		self.is_inited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function ViewBase:initUI()
	print("warning! you should implement initUI() in instance!---"..self.name)
end

function ViewBase:initInfo()
	print("warning! you should implement initInfo() in instance!---"..self.name)
end

function ViewBase:initEvents()
	print("warning! you should implement initEvents() in instance")
end

function ViewBase:openView()
	if not self.is_inited then
		self:init()
	end
	self.root:setPosition(uitool:zero())
end

function ViewBase:closeView()
	self.root:setPosition(uitool:farAway())
end

function ViewBase:isInited()
	return self.is_inited
end

return ViewBase