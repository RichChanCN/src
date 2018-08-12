
cc.FileUtils:getInstance():setPopupNotify(false)

require "config.config"
require "cocos.init"
require "tool.mytool"
require "tool.uitool"
require "config.config_path"
require "config.config_particle"
require "config.config_ui"
require "config.config_buff"
require "config.config_skill"
require "config.config_monster"
require "config.config_map"
require "app.logic.Judgment"

local function main()
	collectgarbage("collect")
	collectgarbage("setpause",100)
	collectgarbage("setstepmul",5000)

	cc.FileUtils:getInstance():addSearchPath("src")
	cc.FileUtils:getInstance():addSearchPath("res")

    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
