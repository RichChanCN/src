
local my_app = class("my_app", cc.load("mvc").app_base)

function my_app:on_create()
    math.randomseed(os.time())
end

return my_app
