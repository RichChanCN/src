
local SceneBase = class("SceneBase", cc.Node)

function SceneBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createLayoutBinding(binding)
    end
    
    if self.on_create then self:on_create() end
end

function SceneBase:getApp()
    return self.app_
end

function SceneBase:getName()
    return self.name_
end

function SceneBase:getResourceNode()
    return self.resourceNode_
end

function SceneBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("SceneBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function SceneBase:createLayoutBinding(binding)
    assert(self.resourceNode_, "SceneBase:createResourceBinding() - not load resource node")
	for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName);
        if nodeBinding.varname then
            local path = rawget(self.class, "VIEW_PATH")
            if path then
                self[nodeBinding.varname] = require(path.."."..nodeBinding.varname):new(nodeBinding.varname, node, self)
            else
                self[nodeBinding.varname] = node
            end
        end
    end
    
end

function SceneBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

return SceneBase
