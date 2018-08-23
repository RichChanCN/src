
local main_scene = class("main_scene", cc.load("mvc").scene_base)


main_scene.RESOURCE_FILENAME = "main_scene.csb"
 
main_scene.RESOURCE_BINDING = {
	--main_view
    ["main_view"]			= {["varname"] = "main_view"},
	--title_right_view
    ["title_right_view"]	= {["varname"] = "title_right_view"},
	--setting_view
    ["setting_view"]		= {["varname"] = "setting_view"},
	--advence_panel
    ["adventure_view"]		= {["varname"] = "adventure_view"},
	--confirm_view
    ["confirm_view"]		= {["varname"] = "confirm_view"},
	--embattle_view
    ["embattle_view"]		= {["varname"] = "embattle_view"},
    --monster_list_view
    ["monster_list_view"]	= {["varname"] = "monster_list_view"},
    --monster_info_view
    ["monster_info_view"]	= {["varname"] = "monster_info_view"},
}

main_scene.VIEW_PATH = "app.views.mainscene"

main_scene.on_create = function(self)
	game_data_ctrl:instance():register_scene(self)
	self:view_init()
end

main_scene.onEnter = function(self)
	self:open_main_view()
	self:open_title_right_view()
end

main_scene.onExit = function(self)
end

main_scene.view_init = function(self)
	self.main_view:init()
	self.title_right_view:init()
	self.setting_view:init()
	self.adventure_view:init()
	self.confirm_view:init()
	self.embattle_view:init()
	self.monster_list_view:init()
	self.monster_info_view:init()
end

main_scene.go_to_fight_scene = function(self)
	local scene = cc.Scene:create()
	local layer = self.app_:create_scene("fight_scene")
	scene:addChild(layer)
	if scene then
		local ts = cc.TransitionFade:create(0.5, scene)
		cc.Director:getInstance():pushScene(ts)
	end	
end

main_scene.open_main_view = function(self)
	if self.main_view then
		self.main_view:openView()
	end
end

main_scene.close_main_view = function(self)
	if self.main_view then
		self.main_view:closeView()
	end
end

main_scene.open_title_right_view = function(self)
	if self.title_right_view then
		self.title_right_view:openView()
	end
end

main_scene.open_monster_list_view = function(self)
	if self.monster_list_view then
		self.main_view:closeView()
		self.monster_list_view:openView()
	end
end

main_scene.close_monster_list_view = function(self)
	if self.monster_list_view then
        self.main_view:openView()
		self.monster_list_view:closeView()
	end
end

main_scene.open_monster_info_view = function(self, monster_list, index)
	if self.monster_info_view then
		self.monster_list_view:closeView()
		self.monster_info_view:openView(monster_list,index)
	end
end

main_scene.close_monster_info_view = function(self)
	if self.monster_info_view then
        self.monster_list_view:openView()
		self.monster_info_view:closeView()
	end
end

main_scene.open_adventure_view = function(self)
	if self.adventure_view then
		self.main_view:closeView()
		self.adventure_view:openView()
	end
end

main_scene.close_adventure_view = function(self)
	if self.adventure_view then
        self.main_view:openView()
		self.adventure_view:closeView()
	end
end

main_scene.open_embattle_view = function(self)
	if self.embattle_view then
        self.adventure_view:closeView()
		self.embattle_view:openView()
	end
end

main_scene.open_specific_embattle_view = function(self, chapter_num, level_num)
	if self.embattle_view then
        self.adventure_view:closeView()
		self.embattle_view:openView(chapter_num, level_num)
	end
end

main_scene.close_embattle_view = function(self)
	if self.embattle_view then
        self.adventure_view:openView()
		self.embattle_view:closeView()
	end
end

main_scene.open_confirm_view = function(self, chapter_num, level_num)
	if self.confirm_view then
		self.confirm_view:openView(chapter_num,level_num,reward_data)
	end
end

main_scene.close_confirm_view = function(self)
	if self.confirm_view then
		self.confirm_view:closeView()
	end
end

main_scene.open_setting_view = function(self)
	if self.setting_view then
		self.setting_view:openView()
	end
end

return main_scene
