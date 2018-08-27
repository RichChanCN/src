
local app_base = class("app_base")

app_base.ctor = function(self, configs)
    self._configs = {
        scenes_root  = "app.scenes",
        models_root = "app.models",
        default_scene_name = "main_scene",
    }

    for k, v in pairs(configs or {}) do
        self._configs[k] = v
    end

    if type(self._configs.scenes_root) ~= "table" then
        self._configs.scenes_root = {self._configs.scenes_root}
    end
    if type(self._configs.models_root) ~= "table" then
        self._configs.models_root = {self._configs.models_root}
    end

    if DEBUG > 1 then
        dump(self._configs, "app_base configs")
    end

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end

    -- event
    self:on_create()
end

app_base.run = function(self, initSceneName)
    initSceneName = initSceneName or self._configs.default_scene_name
    self:enter_scene(initSceneName)
end

app_base.enter_scene = function(self, sceneName, transition, time, more)
    local view = self:create_scene(sceneName)
    view:show_with_scene(transition, time, more)
    return view
end

app_base.create_scene = function(self, name)
    for _, root in ipairs(self._configs.scenes_root) do
        local packageName = string.format("%s.%s", root, name)
        local status, view = xpcall(function()
                return require(packageName)
            end, function(msg)
        end)
        local t = type(view)
        if status and (t == "table" or t == "userdata") then
            return view:create(self, name)
        end
    end
end

app_base.on_create = function(self)
end

return app_base
