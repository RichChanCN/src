
cc.FileUtils:getInstance():setPopupNotify(false)

require "config.config"
require "cocos.init"
require "tool.lua_xml"
require "tool.my_tool"
require "tool.ui_tool"
require "app.logic.game_data_ctrl"
require "app.logic.chesspiece_pool_manager"
require "config.config_path"
require "config.config_particle"
require "config.config_ui"
require "config.config_buff"
require "config.config_skill"
require "config.config_monster"
require "config.config_map"
require "app.logic.pve_game_ctrl"

local function main()
	collectgarbage("collect")
	collectgarbage("setpause",100)
	collectgarbage("setstepmul",5000)

	cc.FileUtils:getInstance():addSearchPath("src")
	cc.FileUtils:getInstance():addSearchPath("res")

	game_data_ctrl:instance():init()

    require("app.my_app"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
