local LayoutBase = {}

function LayoutBase:new( root, ctrl, data )
	self.root = root
	self.ctrl = ctrl
	self.data = data
	self.isInited = false

	return self
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