local ViewBase = {}

function ViewBase:instance()
	return setmetatable({}, { __index = self })
end

function ViewBase:new( name, root, ctrl)
	self.name = name
	self.root = root
	self.ctrl = ctrl
	self.isInited = false

	return self
end

function ViewBase:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)

	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function ViewBase:initInfo()
	print("warning! you should implement initInfo() in instance!---"..self.name)
end

function ViewBase:initEvents()
	print("warning! you should implement initEvents() in instance")
end

function ViewBase:openView()
	if not self.isInited then
		self:init()
	end
	self.root:setPosition(uitool:zero())
end

function ViewBase:closeView()
	self.root:setPosition(uitool:farAway())
end

return ViewBase