local view = require("packages.mvc.ViewBase")

local confirm_view = view:instance()

confirm_view.RESOURCE_BINDING = {
    ["close_btn"]			= {["varname"] = "close_btn"},
    ["go_img"]				= {["varname"] = "go_img"},
    ["stage_text"]			= {["varname"] = "stage_text"},
    ["star_1_sp"]			= {["varname"] = "star_1_sp"},
    ["star_2_sp"]			= {["varname"] = "star_2_sp"},
    ["star_3_sp"]			= {["varname"] = "star_3_sp"},
    ["info_btn"]			= {["varname"] = "info_btn"},
    ["got_img"]				= {["varname"] = "got_img"},
    ["reward_node"]			= {["varname"] = "reward_node"},
    ["reward_template"]		= {["varname"] = "reward_template"},
}

function confirm_view:initInfo()
	self.chapter_num = 1
	self.level_num = 1
	self.reward_list = {}
end

function confirm_view:initEvents()
	self.close_btn:addClickEventListener(function(sender)
        self.ctrl:closeConfirmView()
    end)
    uitool:makeImgToButton(self.go_img,function(sender)
    	self.ctrl:closeConfirmView()
    	self.ctrl:openSpecificEmbattleView(self.chapter_num,self.level_num)
    end)
end

function confirm_view:updateInfo(chapter_num,level_num)
	self.reward_data = self.ctrl:getRewardByChapterAndLevel(chapter_num, level_num)
	self.reward_list = {}

	self.star_num = self.ctrl:getStarNumByChapterAndLevel(chapter_num, level_num)
	self.all_star_condition = "emmmmmmmmm"

	self.chapter_num = chapter_num
	self.level_num = level_num
end

function confirm_view:updateView()
	self.stage_text:setString("Stage "..self.chapter_num.."-"..self.level_num)

	for i=1,3 do
		if not (i > self.star_num) then
			self["star_"..i.."_sp"]:setTexture(Config.sprite.lager_star_got)
			self["star_"..i.."_sp"]:setScale(1)
		else
			self["star_"..i.."_sp"]:setTexture(Config.sprite.lager_star_empty)
			self["star_"..i.."_sp"]:setScale(1.5)
		end
	end
	self:updateReward()
end

function confirm_view:updateReward()
	if self.star_num > 0 then
		self.got_img:setVisible(true)
		self.reward_node:setVisible(false)
	else
		self.reward_node:removeAllChildren()
		self.got_img:setVisible(false)
		self.reward_node:setVisible(true)
		for k1,v1 in pairs(self.reward_data) do
			if k1 == "monster" then
				for k2,v2 in pairs(v1) do
					local card = self.reward_template:clone()
					uitool:initMonsterCardWithIDAndNum(card, k2, v2)
					self.reward_node:addChild(card)
					table.insert(self.reward_list,card)
				end
			elseif (k1 == "coin" or k1 == "crystal") and v1 > 0 then
				local card = self.reward_template:clone()
				uitool:initOtherCardWithTypeAndNum(card, k1, v1)
				self.reward_node:addChild(card)
				table.insert(self.reward_list,card)
			end
		end
		local offset = 0
		local interval =  self.reward_template:getContentSize().width+50
		if (#self.reward_list)%2 == 0 then
			offset = interval/2
		end
		local mid = math.floor((#self.reward_list)/2) + 1
		
		for i,v in ipairs(self.reward_list) do
			v:setPosition((i-mid)*interval+offset,0)
		end
	end

end

function confirm_view:openView(chapter_num,level_num)
	if not self.is_inited then
		self:init()
	end
	self:updateInfo(chapter_num,level_num)
	self:updateView()
	self.root:setPosition(uitool:zero())
end

return confirm_view