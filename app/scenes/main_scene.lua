
local main_scene = class("main_scene", cc.load("mvc").scene_base)


main_scene.RESOURCE_FILENAME = "main_scene.csb"
 
main_scene.RESOURCE_BINDING = {
	--main_view
    ["main_view"]			= {["varname"] = "_main_view"},
	--title_right_view
    ["title_right_view"]	= {["varname"] = "_title_right_view"},
	--setting_view
    ["setting_view"]		= {["varname"] = "_setting_view"},
	--advence_panel
    ["adventure_view"]		= {["varname"] = "_adventure_view"},
	--confirm_view
    ["confirm_view"]		= {["varname"] = "_confirm_view"},
	--embattle_view
    ["embattle_view"]		= {["varname"] = "_embattle_view"},
    --monster_list_view
    ["monster_list_view"]	= {["varname"] = "_monster_list_view"},
    --monster_info_view
    ["monster_info_view"]	= {["varname"] = "_monster_info_view"},
}

main_scene.VIEW_PATH = "app.views.mainscene"

main_scene.on_create = function(self)
	game_data_ctrl:instance():register_scene(self)
	self:view_init()
end

main_scene.view_init = function(self)
	self._main_view:init()
	self._title_right_view:init()
	self._setting_view:init()
	self._adventure_view:init()
	self._confirm_view:init()
	self._embattle_view:init()
	self._monster_list_view:init()
	self._monster_info_view:init()
end

main_scene.onEnter = function(self)
	self:open_main_view()
	self:open_title_right_view()
end

main_scene.onExit = function(self)
end

main_scene.go_to_fight_scene = function(self)
	local scene = cc.Scene:create()
	local layer = self:get_app():create_scene("fight_scene")
	scene:addChild(layer)
	if scene then
		local ts = cc.TransitionFade:create(0.5, scene)
		cc.Director:getInstance():pushScene(ts)
	end	
end

main_scene.open_main_view = function(self)
	if self._main_view then
		self._main_view:open_view()
	end
end

main_scene.close_main_view = function(self)
	if self._main_view then
		self._main_view:close_view()
	end
end

main_scene.open_title_right_view = function(self)
	if self._title_right_view then
		self._title_right_view:open_view()
	end
end

main_scene.open_monster_list_view = function(self)
	if self._monster_list_view then
		self._main_view:close_view()
		self._monster_list_view:open_view()
	end
end

main_scene.close_monster_list_view = function(self)
	if self._monster_list_view then
        self._main_view:open_view()
		self._monster_list_view:close_view()
	end
end

main_scene.open_monster_info_view = function(self, monster_list, index)
	if self._monster_info_view then
		self._monster_list_view:close_view()
		self._monster_info_view:open_view(monster_list, index)
	end
end

main_scene.close_monster_info_view = function(self)
	if self._monster_info_view then
        self._monster_list_view:open_view()
		self._monster_info_view:close_view()
	end
end

main_scene.open_adventure_view = function(self)
	if self._adventure_view then
		self._main_view:close_view()
		self._adventure_view:open_view()
	end
end

main_scene.close_adventure_view = function(self)
	if self._adventure_view then
        self._main_view:open_view()
		self._adventure_view:close_view()
	end
end

main_scene.open_embattle_view = function(self)
	if self._embattle_view then
        self._adventure_view:close_view()
		self._embattle_view:open_view()
	end
end

main_scene.open_specific_embattle_view = function(self, chapter_num, level_num)
	if self._embattle_view then
        self._adventure_view:close_view()
		self._embattle_view:open_view(chapter_num, level_num)
	end
end

main_scene.close_embattle_view = function(self)
	if self._embattle_view then
        self._adventure_view:open_view()
		self._embattle_view:close_view()
	end
end

main_scene.open_confirm_view = function(self, chapter_num, level_num)
	if self._confirm_view then
		self._confirm_view:open_view(chapter_num, level_num, reward_data)
	end
end

main_scene.close_confirm_view = function(self)
	if self._confirm_view then
		self._confirm_view:close_view()
	end
end

main_scene.open_setting_view = function(self)
	if self._setting_view then
		self._setting_view:open_view()
	end
end

return main_scene
