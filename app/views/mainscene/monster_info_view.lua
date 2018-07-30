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
    self:createModel(data)
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
function monster_info_view:initLeftModelNode()
    self.left_btn 			= self.left_node:getChildByName("left_btn")
    self.right_btn 			= self.left_node:getChildByName("right_btn")
    self.item_bg_img 		= self.left_node:getChildByName("item_bg_img")
    self.type_sp	 		= self.left_node:getChildByName("type_sp")
    self.type_text	 		= self.left_node:getChildByName("type_text")
    self.rarity_text 		= self.left_node:getChildByName("rarity_text")
    self.description_btn	= self.left_node:getChildByName("description_btn")
    self.progress_img 		= self.left_node:getChildByName("progress_img")
    self.progress_text 		= self.left_node:getChildByName("progress_text")
    self.up_sp		 		= self.left_node:getChildByName("up_sp")
    self.model_panel 		= self.left_node:getChildByName("model_panel")
end

function monster_info_view:initRightInfoNode()
    self.upgrade_img				= self.left_node:getChildByName("upgrade_img")
    self.details_btn 				= self.left_node:getChildByName("details_btn")
    self.video_btn	 				= self.left_node:getChildByName("video_btn")
    self.hp_text	 				= self.left_node:getChildByName("hp_text")
    self.demage_text 				= self.left_node:getChildByName("demage_text")
    self.physical_defense_text 		= self.left_node:getChildByName("physical_defense_text")
    self.magic_defense_text 		= self.left_node:getChildByName("magic_defense_text")
    self.initiative_text 			= self.left_node:getChildByName("initiative_text")
    self.mobility_text 				= self.left_node:getChildByName("mobility_text")
    self.defense_penetration_text	= self.left_node:getChildByName("defense_penetration_text")
end

function monster_info_view:createModel(data)
	local callback = function(model)
		--print("load finish")
		self.model_panel:addChild(model)
		model:setScale(200)
		--model:setContentSize(400,300)
		model:setPosition(uitool:getNodeCenterPosition(self.model_panel))
		--model:setGlobalZOrder(uitool:mid_Z_order())
		self.monster_model = model
		self.is_model_loaded = true
        self:initModelCamera()
	end
    cc.Sprite3D:createAsync(Config.model_path.."cube.obj",callback)
    
end

function monster_info_view:initModelCamera()
	local size = self.model_panel:getContentSize()
	self.model_camera = cc.Camera:createPerspective(45,size.width/size.height,1,1000)
	self.model_camera:setPosition3D(cc.vec3(0,0,50))
	self.model_camera:lookAt(cc.vec3(0,0,0),cc.vec3(0,1,0))

	self.model_camera:setName("model_camera")
	self.monster_model:addChild(self.model_camera)
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

return monster_info_view