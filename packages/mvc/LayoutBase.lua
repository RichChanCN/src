local LayoutBase = {}

function LayoutBase:new( name, root, ctrl, data )
	self.name = name
	self.root = root
	self.ctrl = ctrl
	self.data = data
	self.isInited = false

	return self
end

function LayoutBase:init()
	uitool:createUIBinding(self, self.RESOURCE_BINDING)

	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function LayoutBase:initInfo()
	print("warning! you should implement initInfo() in instance!---"..self.name)
end

function LayoutBase:initEvents()
	print("warning! you should implement initEvents() in instance")
end

function LayoutBase:openView()
	if not self.isInited then
		self:init()
	end
	self.root:setPosition(uitool:zero())
end

function LayoutBase:closeView()
	self.root:setPosition(uitool:farAway())
end

return LayoutBase