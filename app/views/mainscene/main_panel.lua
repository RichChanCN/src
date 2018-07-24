local LayoutBase = require("packages.mvc.LayoutBase")
local main_panel = {}

function main_panel:new( root, ctrl, data )
	local o = LayoutBase:new(root,ctrl,data)
  	setmetatable(main_panel, getmetatable(o))
  	o.super = setmetatable({}, getmetatable(o))
  	self.__index = self
  	self.RESOURCE_BINDING = {
		["title_left_node"]		= {["varname"] = "title_left_node"},
    	["title_face_sp"]		= {["varname"] = "title_face_sp"},
    	["title_btn"]			= {["varname"] = "title_btn"},
    	["flag_sp"]				= {["varname"] = "flag_sp"},
    	["nick_name_text"]		= {["varname"] = "nick_name_text"},
    	["mail_btn"]			= {["varname"] = "mail_btn"},
    	["exp_now_img"]			= {["varname"] = "exp_now_img"},
    	["level_text"]			= {["varname"] = "level_text"},
		["adventure_frame_img"]	= {["varname"] = "adventure_frame_img"},
	}

	return setmetatable(o, { __index = main_panel })
end

function main_panel:init()
	table.print(getmetatable(self))
	uitool:createUIBinding(self, self.RESOURCE_BINDING)

	self:initInfo()
	self:initEvents()

	self.isInited = true
end

function main_panel:initInfo()

end

function main_panel:initEvents()
	table.print(self)
	self.adventure_frame_img:addClickEventListener(function(sender)
        self.ctrl:openAdventureView()
    end)

	self.title_btn:addClickEventListener(function(sender)
        self.ctrl:openSettingView()
    end)
end

function main_panel:updateView()

end

function main_panel:openView()
	if not self.isInited then
		self:init()
	end
	self.root:setPosition(uitool:zero())
end

function main_panel:closeView()
	self.root:setPosition(uitool:farAway())
end

return main_panel