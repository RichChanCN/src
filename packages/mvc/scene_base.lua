
local scene_base = class("scene_base", cc.Node)

scene_base.ctor = function(self, app, name)
    self:enableNodeEvents()
    self._app = app
    self._name = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:create_resource_node(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:create_layout_binding(binding)
    end
    
    if self.on_create then self:on_create() end
end

scene_base.get_app = function(self)
    return self._app
end

scene_base.get_name = function(self)
    return self._name
end

scene_base.get_resource_node = function(self)
    return self._resourceNode
end

scene_base.create_resource_node = function(self, resource_filename)
    if self._resourceNode then
        self._resourceNode:removeSelf()
        self._resourceNode = nil
    end
    self._resourceNode = cc.CSLoader:createNode(resource_filename)
    self:addChild(self._resourceNode)
end

scene_base.create_layout_binding = function(self, binding)
    for nodeName, nodeBinding in pairs(binding) do
        local node = self._resourceNode:getChildByName(nodeName);
        if nodeBinding.varname then
            local path = rawget(self.class, "VIEW_PATH")
            if path then
                self[nodeBinding.varname] = require(path.."."..nodeName):new(nodeBinding.varname, node, self)
            else
                self[nodeBinding.varname] = node
            end
        end
    end
    
end

scene_base.show_with_scene = function(self, transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self._name)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

return scene_base
