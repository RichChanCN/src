local view = require("packages.mvc.view_base")

local monster_info_view = view:instance()

monster_info_view.RESOURCE_BINDING = {
	["left_node"]		    = {["varname"] = "left_node"},
    ["info_bg_img"]         = {["varname"] = "info_bg_img"},
    ["title_text"]          = {["varname"] = "title_text"},
    ["back_btn"]            = {["varname"] = "back_btn"},

}

function monster_info_view:initUI()
    self:initLeftModelNode()
    self:initRightInfoNode()
end

function monster_info_view:init_info()
    self.left_node_start_pos = cc.p(-545,540)
    self.left_node_final_pos = cc.p(545,540)
    self.right_node_start_pos = cc.p(2350,500)
    self.right_node_final_pos = cc.p(1490,500)

    self.monster_list = {}
    self.next_animate = 2
    self.is_model_loaded = false
    self.monster_model = nil
    self.model_camera = nil
    self.monster_data = {}
end

function monster_info_view:updateInfo(monster_list,index)
    self.next_animate = 2
    self.is_model_loaded = false
    self.monster_list = monster_list
    self.cur_index = index
    self.monster_data = monster_list[index]
    self.last_index = self.cur_index - 1
    if self.last_index < 1 then
        self.last_index = #self.monster_list
    end

    self.next_index = self.cur_index + 1
    if self.next_index > #self.monster_list then
        self.next_index = 1
    end
end

function monster_info_view:initEvents()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:close_monster_info_view()
    end)

    self.left_btn:addClickEventListener(function(sender)
        self:updateView(self.monster_list,self.next_index)
    end)

    self.right_btn:addClickEventListener(function(sender)
        self:updateView(self.monster_list,self.last_index)
    end)
    uitool:makeImgToButton(self.upgrade_img,function()
        if self.monster_data.card_num and not(self.monster_data.card_num < self.monster_data.level) then
            game_data_ctrl:instance():requestUpgradeMonster(self.monster_data.id)
            self:upgradeUpdate()
        end
    end)
    --------------左边节点事件-------------
    self:initModelEvents()
end

function monster_info_view:updateView(monster_list,index)
	self.title_text:setString("LEVEL "..monster_list[index].level.." "..monster_list[index].name)
    self:updateInfo(monster_list,index)
    self:updateLeftModelNode(monster_list[index])
    self:updateRightInfoNode(monster_list[index])
end

function monster_info_view:onOpen(...)
    local params = {...}
    self:updateView(params[1],params[2])
    self.left_node:runAction(cc.MoveTo:create(0.2,self.left_node_final_pos))
    self.info_bg_img:runAction(cc.MoveTo:create(0.2,self.right_node_final_pos))
end

function monster_info_view:onClose()
    self.left_node:setPosition(self.left_node_start_pos)
    self.info_bg_img:setPosition(self.right_node_start_pos)
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

function monster_info_view:updateMonsterByID(id)
    self.monster_list[self.cur_index] = game_data_ctrl:instance():get_save_monster_data_by_id(id)
end

function monster_info_view:upgradeUpdate()
    local card_num,level = game_data_ctrl:instance():get_monster_card_num_and_level_by_id(self.monster_data.id)
    print(card_num,level)
    self.title_text:setString("LEVEL "..level.." "..self.monster_data.name)
    self.progress_text:setString(card_num .."/"..level)
    uitool:set_progress_bar(self.progress_img, card_num/level)
    self:updateMonsterByID(self.monster_data.id)
end

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

    self.rarity_sp:setTexture(g_config.sprite["rarity_sp_"..data.rarity])
    self.type_sp:setTexture(g_config.sprite["attack_type_"..data.attack_type])
    self.type_text:setString(g_config.text["monster_type_"..data.attack_type])
    self.rarity_text:setString(g_config.text["rarity_text_"..data.rarity])
    self.rarity_text:setTextColor(g_config.color["rarity_color_"..data.rarity])

    if not data.card_num then
        self.progress_text:setString(0 .."/"..data.level)
        uitool:set_progress_bar(self.progress_img, 0)
    else
        self.progress_text:setString(data.card_num.."/"..data.level)
        uitool:set_progress_bar(self.progress_img, data.card_num/data.level)
    end
end

function monster_info_view:createModel(data)
    if self.monster_model then
        self.model_panel:removeChild(self.monster_model)
    end

	local callback = function(model)

		model:setScale(4.5)
        model:setRotation3D(cc.vec3(0,-90,0))
        if data.move_type == g_config.monster_move_type.FLY then
            model:setPosition(uitool:get_node_center_position(self.model_panel))
        else
            model:setPosition(uitool:get_node_bottom_center_position(self.model_panel))
        end
        
        self.animation = cc.Animation3D:create(data.model_path)
        if self.animation then
            local animate = g_config.monster_animate[data.id].alive(self.animation)
            model:runAction(cc.RepeatForever:create(animate))
        end

		self.monster_model = model
        self.cur_monster_id = data.id
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

	    if uitool:is_touch_in_node_rect(node,touch,event) and self.is_model_loaded then
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
	    
	    if cur_pos.x - start_pos.x < 5 and cur_pos.y - start_pos.y < 5 then
	    	self:playAnAnimation()
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

function monster_info_view:playAnAnimation()
    self.monster_model:stopAllActions()
    local animate = g_config.monster_animate[self.cur_monster_id][self.next_animate](self.animation)

    self.monster_model:runAction(cc.RepeatForever:create(animate))

    self.next_animate = self.next_animate % g_config.monster_animate[self.cur_monster_id].show_num + 1
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

    self.no_skill_text              = self.info_bg_img:getChildByName("no_skill_text")
    self.skill_sp                   = self.info_bg_img:getChildByName("skill_sp")
    self.skill_icon_sp              = self.skill_sp:getChildByName("skill_icon_sp")
    self.skill_description_text     = self.info_bg_img:getChildByName("skill_description_text")
end

function monster_info_view:updateRightInfoNode(data)
	self.hp_text:setString(data.hp)
	self.damage_text:setString(data.damage)
	self.physical_defense_text:setString(data.physical_defense)
	self.magic_defense_text:setString(data.magic_defense)
	self.initiative_text:setString(data.initiative)
	self.mobility_text:setString(data.mobility)
	self.defense_penetration_text:setString(data.defense_penetration)

    if data.skill then
        self.no_skill_text:setVisible(false)
        self.skill_sp:setVisible(true)
        self.skill_description_text:setVisible(true)
        self.skill_sp:setTexture(data.skill.img_path)
        self.skill_description_text:setString(data.skill.description)
    else
        self.no_skill_text:setVisible(true)
        self.skill_sp:setVisible(false)
        self.skill_description_text:setVisible(false)
    end
end
--------------------右边相关结束----------------------

return monster_info_view