
local fight_scene = class("fight_scene", cc.load("mvc").scene_base)


-- 加载csb文件
fight_scene.RESOURCE_FILENAME = "fight_scene.csb"

fight_scene.RESOURCE_BINDING = {
	--map_view
    ["map_view"]			= {["varname"] = "_map_view"},
	--map_view
    ["battle_info_view"]	= {["varname"] = "_battle_info_view"},
 	--result_view
 	["result_view"]			= {["varname"] = "_result_view"},
 }

--面板文件位置
fight_scene.VIEW_PATH = "app.ui.fightscene"
fight_scene.WAIT_TIME = 1
fight_scene.ACTION_TIME = 0.3

fight_scene.on_create = function(self)
	game_data_ctrl:instance():register_scene(self)
end

fight_scene.onEnter = function(self)
	self._map_data = require("app.data.map_data")
    self:view_init()
	self:init_model()
	self._map_view:init_enter_animation()
	self._map_view:get_root():setScale(0.75)
end

fight_scene.view_init = function(self)
	self._map_view:init()
end

fight_scene.init_model = function(self)
	local map = pve_game_ctrl:instance():get_map()
	for k, v in pairs(map) do
		self._map_view:create_other_model(v, gtool:int_2_ccp(k))
	end

	local all_monster = pve_game_ctrl:instance():get_all_monsters()
	for _, v in pairs(all_monster) do
		self._map_view:create_monster_model(v)
	end
end

fight_scene.onExit = function(self)
	pve_game_ctrl:instance():clear_team()
	self._map_view:clear_model_panel()
end

fight_scene.onEnterTransitionFinish = function(self)
	cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
	self._map_view:beginAnimation()
end

fight_scene.start_game = function(self)
	pve_game_ctrl:instance():set_scene(self)
	pve_game_ctrl:instance():start_game()
	self:open_battle_info_view()
end

fight_scene.game_over = function(self, result)
	self:set_result(result)
	self:close_battle_info_view()
	self._map_view:endAnimation()
end

fight_scene.go_to_main_scene = function(self)
	cc.Director:getInstance():popScene()
end

fight_scene.update_map_view = function(self)
	self._map_view:update_view()
end


fight_scene.update_battle_queue = function(self, is_wait)
	self._battle_info_view:update_right_bottom_queue(is_wait)
end

fight_scene.get_particle_node = function(self)
	return self._battle_info_view.particle_node
end

fight_scene.get_battle_info_view = function(self)
	return self._battle_info_view
end

fight_scene.open_battle_info_view = function(self)
	self._battle_info_view:open_view()
end

fight_scene.close_battle_info_view = function(self)
	self._battle_info_view:close_view()
end

fight_scene.set_result = function(self, result)
	self._result_view:set_result(result)
end

fight_scene.open_result_view = function(self)
	self._result_view:open_view()
end

fight_scene.close_result_view = function(self)
	self._result_view:close_view()
end

fight_scene.get_map_view = function(self)
	return self._map_view
end

fight_scene.show_guide = function(self)
	self._map_view:show_guide()
end

fight_scene.show_other_around_info = function(self, monster)
	self._map_view:show_other_around_info(monster)
end

fight_scene.hide_other_around_info = function(self)
	self._map_view:hide_other_around_info()
end

fight_scene.get_map_data = function(self)
	return self._map_data
end

return fight_scene
