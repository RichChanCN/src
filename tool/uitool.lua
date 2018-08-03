uitool = {}

function uitool:farAway()
    return cc.p(10000,10000)
end

function uitool:zero()
    return cc.p(0,0)
end

function uitool:top_Z_order()
    return 2000
end

function uitool:mid_Z_order()
    return 1000
end

function uitool:bottom_Z_order()
    return 0
end

function uitool:getNodeCenterPosition(node)
    local size = node:getContentSize()
    return cc.p(size.width/2,size.height/2)
end

function uitool:createUIBinding(panel,binding)
    assert(panel.root, "uitool:createResourceBinding() - not load resource node")
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

function uitool:isTouchInNodeRect(node,touch,event,scale)
    local scale = scale or 1.0
    local node = event:getCurrentTarget()
    local locationInNode = node:convertToNodeSpace(touch:getLocation())
    local border = node:getContentSize()
    local rect = cc.rect(0,0,border.width*scale,border.height*scale)
    
    return cc.rectContainsPoint(rect, locationInNode)
end


function uitool:isTouchInNodeCircle(node,touch,event,scale)
    local scale = scale or 1.0
    local node = event:getCurrentTarget()
    local locationInNode = node:convertToNodeSpace(touch:getLocation())
    local x,y = node:getPosition()
    local radius = math.min(node:getContentSize().width,node:getContentSize().height)
    

    return math.pow(locationInNode.x-x,2)+math.pow(locationInNode.y-y,2)<math.pow(radius)
end

function uitool:moveToAndFadeOut(node,pos)
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:moveToAndFadeOut(children[i])
        end
    end

    local ac1 = nil 
    if pos then
        ac1 = node:runAction(cc.MoveTo:create(0.1,cc.p(pos.x,pos.y)))
    end   
    local ac2 = node:runAction(cc.FadeOut:create(0.2))

    local seq1 = cc.Sequence:create(ac1,ac2)
    
    node:runAction(seq1)
end

function uitool:repeatFadeInAndOut(node)
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:repeatFadeInAndOut(children[i])
        end
    end

    local ac1 = node:runAction(cc.FadeOut:create(2)) 
    local ac2 = node:runAction(cc.FadeIn:create(1.5))

    local seq1 = cc.Sequence:create(ac1,ac2)
    
    node:runAction(cc.Repeat:create(seq1,9999))
end

function uitool:makeImgToButton(img,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()

        if self:isTouchInNodeRect(node,touch,event) then
            node:setScale(1.06)
            return true
        end

        return false
    end

    local function touchMoved( touch, event )
        local node = event:getCurrentTarget()

        if self:isTouchInNodeRect(node,touch,event) then
            node:setScale(1.06)
        else
            node:setScale(1.0)
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        
        if self:isTouchInNodeRect(node,touch,event) then
            node:setScale(1.0)
            if callback then
                callback()
            end
        end
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end


function uitool:makeImgToButtonHT(img,camera,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()
        local start_location = touch:getLocation()

        if node:hitTest(start_location, camera, nil) then
            return true
        end

        return false
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        local end_location = touch:getLocation()

        if node:hitTest(end_location, camera, nil) then
            if callback then
                callback()
            end
        end
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end