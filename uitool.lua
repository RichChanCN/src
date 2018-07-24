uitool = {}

function uitool:farAway()
    return 10000,10000
end

function uitool:zero()
    return 0,0
end

function uitool:createUIBinding(panel,binding)
    assert(panel.root, "ViewBase:createResourceBinding() - not load resource node")
	for nodeName, nodeBinding in pairs(binding) do
        local node = self:seekChildNode(panel.root, nodeName);
        if nodeBinding.varname then
            panel[nodeBinding.varname] = node
        end
    end
    
end

function uitool:seekChildNode(node, name)
    local child = node:getChildByName(name)
    --print("find" .. name .. "in" .. node:getName())
    if child then
        return child 
    else
        local children = node:getChildren()
        for i=1, #children do
            child = self:seekChildNode(children[i], name)
            if child then
                return child
            end
        end
        return nil
    end
end