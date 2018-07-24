local LayoutBase = {}

function LayoutBase:new(root, ctrl, data )
	local o = {}
	setmetatable(o, self)
  	self.__index = self
	self.root = root
	self.ctrl = ctrl
	self.data = data
	self.isInited = false

	return o
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