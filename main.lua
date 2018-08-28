
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

require "app.base.tool.lua_xml"
require "app.base.tool.my_tool"
require "app.base.tool.ui_tool"

require "app.base.config.config_path"
require "app.base.config.config_particle"
require "app.base.config.config_ui"
require "app.base.config.config_buff"
require "app.base.config.config_skill"
require "app.base.config.config_monster"
require "app.base.config.config_map"

require "app.base.monster_factory"
require "app.base.game_data_ctrl"
require "app.base.chesspiece_pool_manager"
require "app.base.pve_game_ctrl"

local function main()
	collectgarbage("collect")
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	cc.FileUtils:getInstance():addSearchPath("src")
	cc.FileUtils:getInstance():addSearchPath("res")

	game_data_ctrl:instance():init()

    require("app.my_app"):create():run()

end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
