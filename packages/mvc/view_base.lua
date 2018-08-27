local view_base = {}

view_base.instance = function(self)
	return setmetatable({}, { __index = self })
end

view_base.new = function(self, name, root, ctrl)
	self._name = name
	self._root = root
	self._ctrl = ctrl

	--事件分发器
	self._event_dispatcher = cc.Director:getInstance():getEventDispatcher()
	
	self._is_inited = false

	return self
end

view_base.get_ctrl = function(self)
	return self._ctrl
end

view_base.get_root = function(self)
	return self._root
end

view_base.get_name = function(self)
	return self._name
end

view_base.init = function(self)
	if not self._is_inited then
		uitool:create_ui_binding(self, self.RESOURCE_BINDING)

		self:init_info()
		self:init_ui()
		self:init_events()

		self._is_inited = true
	end
end

view_base.init_ui = function(self)
end

view_base.init_info = function(self)
end

view_base.init_events = function(self)
end

view_base.on_open = function(self, ...)
	-- body
end

view_base.on_close = function(self)
	-- body
end

view_base.open_view = function(self, ...)
	if not self._is_inited then
		self:init()
	end
	self:on_open(...)

	if self._view_pos then
		self._root:setPosition(self._view_pos)
	else
		self._root:setPosition(uitool:zero())
	end
end

view_base.close_view = function(self)
	self:on_close()
	self._root:setPosition(uitool:far_away())
end

view_base.is_inited = function(self)
	return self._is_inited
end

return view_base