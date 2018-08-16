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

function uitool:screen_center_pos()
    return cc.p(960,540)
end

function uitool:getNodeCenterPosition(node)
    local size = node:getContentSize()
    return cc.p(size.width/2,size.height/2)
end

function uitool:getNodeBottomCenterPosition(node)
    local size = node:getContentSize()
    return cc.p(size.width/2,0)
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

    local ac1 = node:runAction(cc.FadeTo:create(1,155)) 
    local ac2 = node:runAction(cc.FadeTo:create(1,255))

    local seq = cc.Sequence:create(ac1,ac2)
    
    node:runAction(cc.RepeatForever:create(seq))
end

function uitool:repeatScale(node)
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:repeatScale(children[i])
        end
    end

    local ac1 = node:runAction(cc.ScaleTo:create(0.5,1.1)) 
    local ac2 = node:runAction(cc.ScaleTo:create(0.5,1))

    local seq = cc.Sequence:create(ac1,ac2)
    
    node:runAction(cc.RepeatForever:create(seq))
end

function uitool:setProgressBar(img,percent)
    if not img.raw_size then
        img.raw_size = img:getContentSize()
    end
    if percent < 0 then 
        percent = 0
    end
    if percent > 1 then 
        percent = 1
    end
    img:setContentSize(img.raw_size.width*percent,img.raw_size.height)
end

function uitool:setNodeToGlobalTop(node,z)
    z = z or self:top_Z_order()
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:setNodeToGlobalTop(children[i])
        end
    end

    node:setGlobalZOrder(z)
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
            if callback then
                callback()
            end
        end
        node:setScale(1.0)
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    --img.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

function uitool:makeImgToButtonNoScale(img,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()

        if self:isTouchInNodeRect(node,touch,event) then
            return true
        end

        return false
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        
        if self:isTouchInNodeRect(node,touch,event) then
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

function uitool:initMonsterCardWithIDAndNum(card,id,num,click_event)
    local monster = Config.Monster[id]
    card:loadTexture(monster.char_img_path)
    card.border_img = card:getChildByName("border_img")
    card.border_img:loadTexture(Config.sprite["card_border_"..monster.rarity])
    card.type_img = card:getChildByName("type_img")
    card.type_img:loadTexture(Config.sprite["attack_type_"..monster.attack_type])
    card.num_text = card:getChildByName("num_text")
    card.num_text:setString("X"..num)
    card.num_text:setTextColor(Config.color["rarity_color_"..monster.rarity])
    if click_event then 
        cur_monster.head_img:addClickEventListener(click_event)
    end

end

function uitool:initOtherCardWithTypeAndNum(card,ctype,num,click_event)
    card.border_img = card:getChildByName("border_img")
    card.border_img:loadTexture(Config.sprite.card_border_0)
    local x,y = card.border_img:getPosition()
    card.border_img:setPosition(x+3,y)
    card.type_img = card:getChildByName("type_img")
    card.type_img:setVisible(false)
    card.num_text = card:getChildByName("num_text")
    card.num_text:setString("+"..num)
    if ctype == "coin" then
        card:loadTexture(Config.sprite.card_coin)
        card.num_text:setTextColor(Config.color.coin)
    elseif ctype == "crystal" then
        card:loadTexture(Config.sprite.card_crystal)
        card.num_text:setTextColor(Config.color.crystal)
    end
    
    if click_event then 
        cur_monster.head_img:addClickEventListener(click_event)
    end

end

function uitool:createTopTip(string,color)
    color = color or "white"
    color = Config.color[color]
    local scene = cc.Director:getInstance():getRunningScene()
    if not scene.top_tip then
        local tip_bg = cc.Sprite:create()
        tip_bg:setTexture(Config.sprite.tip_bg)
        local label = cc.Label:createWithTTF(string,Config.font.default,36)
        label:setPosition(self:getNodeCenterPosition(tip_bg))
        tip_bg.label = label
        tip_bg:addChild(label)
        tip_bg:setScale(2)
        scene.top_tip = tip_bg
        scene:addChild(tip_bg, self:top_Z_order())
    else
        scene.top_tip:stopAllActions()
        scene.top_tip.label:setString(string)
        scene.top_tip:setVisible(true)
    end

    scene.top_tip.label:setTextColor(color)

    scene.top_tip:setPosition(self:getNodeCenterPosition(scene))

    local cb = function()
        scene.top_tip:setVisible(false)
    end

    local callback = cc.CallFunc:create(cb)

    local ac = scene.top_tip:runAction(cc.FadeIn:create(1))
    scene.top_tip:stopAction(ac)

    local seq = cc.Sequence:create(ac,callback)

    scene.top_tip:runAction(seq)
end