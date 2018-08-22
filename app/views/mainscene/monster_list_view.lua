local view = require("packages.mvc.ViewBase")

local monster_list_view = view:instance()

monster_list_view.RESOURCE_BINDING = {
    ["back_btn"]				= {["varname"] = "back_btn"},
    ["monster_lv"]				= {["varname"] = "monster_lv"},
    ["template_panel"]			= {["varname"] = "template_panel"},
}

function monster_list_view:initInfo()
	self.card_list = {}
	
	--事件分发器
	self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
end

function monster_list_view:initEvents()
	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:closeMonsterListView()
    end)
end

function monster_list_view:updateInfo()
    self.collected_monster_list = GameDataCtrl:Instance():getCollectedMonsterList()
	self.uncollected_monster_list = GameDataCtrl:Instance():getNotCollectedMonsterList()
end

function monster_list_view:updateView()
	self:initMonsterLV()
end

function monster_list_view:onOpen()
	self:updateInfo()
	self:updateView()
end

function monster_list_view:onClose()
	local collected_title = self.monster_lv:getItem(0):clone()
	self.monster_lv:removeAllItems()

	self.monster_lv:pushBackCustomItem(collected_title)
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

function monster_list_view:initMonsterLV()
	self:initCollectedMonsterLV()
	self:initNotCollectedMonsterLV()
end

function monster_list_view:initCollectedMonsterLV()
	local collected_title = self.monster_lv:getItem(0)
	local title_tip = collected_title:getChildByName("tip_text")

	title_tip:setString(Config.text.collected_tip)

	local monsters_num = #self.collected_monster_list
	local mod_num = monsters_num%5
	local rows_num = monsters_num/5

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local test_item = self.template_panel:clone()
		self:initLVItem(self.collected_monster_list,test_item, i-1) --这里-1是为了里面好计算正真的索引值
		self.monster_lv:pushBackCustomItem(test_item)
	end
end

function monster_list_view:initNotCollectedMonsterLV()
	local not_collected_title = self.monster_lv:getItem(0):clone()
	local titile_text = not_collected_title:getChildByName("title_text")
	local tip_text = not_collected_title:getChildByName("tip_text")
	
	titile_text:setString("Not Collected")
	tip_text:setString(Config.text.uncollected_tip)

	self.monster_lv:pushBackCustomItem(not_collected_title)

	local monsters_num = #self.uncollected_monster_list
	local mod_num = monsters_num%5
	local rows_num = monsters_num/5

	if mod_num ~= 0 then
		rows_num = rows_num + 1
	end

	for i = 1, rows_num do
		local test_item = self.template_panel:clone()
		self:initLVItem(self.uncollected_monster_list,test_item, i-1) --这里-1是为了里面好计算正真的索引值
		self.monster_lv:pushBackCustomItem(test_item)
	end
end

function monster_list_view:initLVItem(monster_list ,item, index)
	for i=1,5 do
		local cur_index = i+5*index
		local cur_monster = {}
		if monster_list[cur_index] then
			cur_monster.head_img = item:getChildByName("monster_"..i.."_img")
			cur_monster.head_img:loadTexture(monster_list[cur_index].char_img_path)
			cur_monster.border_img = cur_monster.head_img:getChildByName("border_img")
			cur_monster.border_img:loadTexture(Config.sprite["card_border_"..monster_list[cur_index].rarity])
			cur_monster.type_img = cur_monster.head_img:getChildByName("type_img")
			cur_monster.type_img:loadTexture(Config.sprite["attack_type_"..monster_list[cur_index].attack_type])
			cur_monster.head_img:addClickEventListener(function(sender)
				self.ctrl:openMonsterInfoView(monster_list,cur_index)
			end)
			table.insert(self.card_list,cur_monster.head_img)
		else
			cur_monster.head_img = item:getChildByName("monster_"..i.."_img")
			cur_monster.head_img:setVisible(false)
		end
	end
end

function monster_list_view:resumeMonsterListListener()
	for _,v in pairs(self.card_list) do
		self.eventDispatcher:resumeEventListenersForTarget(v)
	end
end

function monster_list_view:pauseMonsterListListener()
	for _,v in pairs(self.card_list) do
		self.eventDispatcher:pauseEventListenersForTarget(v)
	end
end

return monster_list_view