local view = require("packages.mvc.ViewBase")

local monster_info_view = view:instance()

monster_info_view.RESOURCE_BINDING = {
	["left_node"]		    = {["varname"] = "left_node"},
    ["info_bg_img"]         = {["varname"] = "info_bg_img"},
    ["title_text"]          = {["varname"] = "title_text"},
    ["back_btn"]            = {["varname"] = "back_btn"},

}

function monster_info_view:init()
    if not self.isInited then
        uitool:createUIBinding(self, self.RESOURCE_BINDING)

        self:initLeftModelNode()
        self:initRightInfoNode()
        self:initInfo()
        self:initEvents()
        
        self.isInited = true
    else
        print(self.name.." is inited! scape the init()")
    end
end

function monster_info_view:initInfo()
    self.left_node_start_pos = cc.p(-545,540)
    self.left_node_final_pos = cc.p(545,540)
    self.right_node_start_pos = cc.p(2350,500)
    self.right_node_final_pos = cc.p(1490,500)

    self.is_model_loaded = false
    self.monster_model = nil
    self.model_camera = nil
end

function monster_info_view:initEvents()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:closeMonsterInfoView()
    end)
    --------------左边节点事件-------------
    self:initModelEvents()
end

function monster_info_view:updateView(data)
	self.title_text:setString("LEVEL "..data.level.." "..data.name)
    self:updateLeftModelNode(data)
    self:updateRightInfoNode(data)
end

function monster_info_view:openView(data)
    if not self.isInited then
        self:init()
    end
    self:updateView(data)
    self.root:setPosition(uitool:zero())
    self.left_node:runAction(cc.MoveTo:create(0.2,self.left_node_final_pos))
    self.info_bg_img:runAction(cc.MoveTo:create(0.2,self.right_node_final_pos))
end

function monster_info_view:closeView()
    self.root:setPosition(uitool:farAway())
    self.left_node:setPosition(self.left_node_start_pos)
    self.info_bg_img:setPosition(self.right_node_start_pos)
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

--------------------左边相关开始----------------------
function monster_info_view:initLeftModelNode()
    self.left_btn 			= self.left_node:getChildByName("left_btn")
    self.right_btn 			= self.left_node:getChildByName("right_btn")
    self.rarity_sp 			= self.left_node:getChildByName("rarity_sp")
    self.type_sp	 		= self.left_node:getChildByName("type_sp")
    self.type_text	 		= self.left_node:getChildByName("type_text")
    self.rarity_text 		= self.left_node:getChildByName("rarity_text")
    self.description_btn	= self.left_node:getChildByName("description_btn")
    self.progress_img 		= self.left_node:getChildByName("progress_img")
    self.progress_text 		= self.left_node:getChildByName("progress_text")
    self.up_sp		 		= self.left_node:getChildByName("up_sp")
    self.model_panel 		= self.left_node:getChildByName("model_panel")

    --self:initModelCamera()
end

function monster_info_view:updateLeftModelNode(data)
    self:createModel(data)

    self.rarity_sp:setTexture(Config.sprite["rarity_sp_"..data.rarity])
    self.type_sp:setTexture(Config.sprite["attack_type_"..data.attack_type])
    self.type_text:setString(Config.text["monster_type_"..data.attack_type])
    self.rarity_text:setString(Config.text["rarity_text_"..data.rarity])
    self.rarity_text:setTextColor(Config.color["rarity_color_"..data.rarity])
end

function monster_info_view:createModel(data)
    if self.monster_model then
        self.model_panel:removeChild(self.monster_model)
    end

	local callback = function(model)
		--print("load finish")
		model:setScale(100)
		model:setPosition(uitool:getNodeCenterPosition(self.model_panel))
		--model:setGlobalZOrder(1)
        --model:setCameraMask(cc.CameraFlag.USER1)
		self.monster_model = model
		self.model_panel:addChild(model)
		self.is_model_loaded = true
	end
    cc.Sprite3D:createAsync(data.model_path,callback)
    
end

function monster_info_view:initModelCamera()
	local size = self.model_panel:getContentSize()
	self.model_camera = cc.Camera:createPerspective(45,size.width/size.height,1,5000)

    self.model_camera:setPosition3D(cc.vec3(400,500,933))
    self.model_camera:lookAt(cc.vec3(400,300,0))
    self.model_camera:setCameraFlag(cc.CameraFlag.USER1)
	self.model_camera:setName("model_camera")
    self.model_camera:setDepth(1)
    self.model_panel:addChild(self.model_camera)
end

function monster_info_view:initModelEvents()
	local function touchBegan( touch, event )
	    local node = event:getCurrentTarget()

	    if uitool:isTouchInNodeRect(node,touch,event) and self.is_model_loaded then
	        return true
	    end

	    return false
	end

	local function touchMoved( touch, event )
	    local node = event:getCurrentTarget()
		local diff = touch:getDelta()
		local pos_3d = self.monster_model:getRotation3D()
		pos_3d.y = pos_3d.y + (diff.x)/5
		self.monster_model:setRotation3D(pos_3d)

		local x = 1
	end

	local function touchEnded( touch, event )
	    local node = event:getCurrentTarget()
	    local cur_pos = node:convertToNodeSpace(touch:getLocation())
	    local start_pos = node:convertToNodeSpace(touch:getStartLocation())
	    
	    if cur_pos.x - start_pos.x < 10 and cur_pos.y - start_pos.y then
	    	print("click model")
	    end
	end

	self.model_panel.listener = cc.EventListenerTouchOneByOne:create()
	self.model_panel.listener:setSwallowTouches(true)
	self.model_panel.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	self.model_panel.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	self.model_panel.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(self.model_panel.listener, self.model_panel)
end
--------------------左边相关结束----------------------

--------------------右边相关开始----------------------
function monster_info_view:initRightInfoNode()
	self.upgrade_img				= self.info_bg_img:getChildByName("upgrade_img")
	self.details_btn 				= self.info_bg_img:getChildByName("details_btn")
	self.video_btn	 				= self.info_bg_img:getChildByName("video_btn")
	self.hp_text	 				= self.info_bg_img:getChildByName("hp_text")
	self.damage_text 				= self.info_bg_img:getChildByName("damage_text")
	self.physical_defense_text 		= self.info_bg_img:getChildByName("physical_defense_text")
	self.magic_defense_text 		= self.info_bg_img:getChildByName("magic_defense_text")
	self.initiative_text 			= self.info_bg_img:getChildByName("initiative_text")
	self.mobility_text 				= self.info_bg_img:getChildByName("mobility_text")
	self.defense_penetration_text	= self.info_bg_img:getChildByName("defense_penetration_text")
end

function monster_info_view:updateRightInfoNode(data)
	self.hp_text:setString(data.hp)
	self.damage_text:setString(data.damage)
	self.physical_defense_text:setString(data.physical_defense)
	self.magic_defense_text:setString(data.magic_defense)
	self.initiative_text:setString(data.initiative)
	self.mobility_text:setString(data.mobility)
	self.defense_penetration_text:setString(data.defense_penetration)
end
--------------------右边相关结束----------------------

return monster_info_view