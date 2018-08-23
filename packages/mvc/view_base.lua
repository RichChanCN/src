local view_base = {}

function view_base:instance()
	return setmetatable({}, { __index = self })
end

function view_base:new( name, root, ctrl)
	self.name = name
	self.root = root
	self.ctrl = ctrl
	self.is_inited = false

	return self
end

function view_base:init()
	if not self.is_inited then
		uitool:create_ui_binding(self, self.RESOURCE_BINDING)

		self:init_info()
		self:initUI()
		self:initEvents()

		self.is_inited = true
	else
		print(self.name.." is inited! scape the init()")
	end
end

function view_base:initUI()
	print("warning! you should implement initUI() in instance!---"..self.name)
end

function view_base:init_info()
	print("warning! you should implement init_info() in instance!---"..self.name)
end

function view_base:initEvents()
	print("warning! you should implement initEvents() in instance")
end

function view_base:onOpen(...)
	-- body
end

function view_base:onClose()
	-- body
end

function view_base:openView(...)
	if not self.is_inited then
		self:init()
	end
	self:onOpen(...)

	if self.view_pos then
		self.root:setPosition(self.view_pos)
	else
		self.root:setPosition(uitool:zero())
	end
end

function view_base:closeView()
	self:onClose()
	self.root:setPosition(uitool:far_away())
end

function view_base:isInited()
	return self.is_inited
end

return view_base