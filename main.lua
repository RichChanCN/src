
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"
require "mytool"

local function main()
	collectgarbage("collect")
	collectgarbage("setpause",100)
	collectgarbage("setstepmul",5000)

	cc.FileUtils:getInstance():addSearchPath("src")
	cc.FileUtils:getInstance():addSearchPath("res")

    require("app.MyApp"):create():run("MainScene")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
