
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:on_create()
    math.randomseed(os.time())
end

return MyApp
