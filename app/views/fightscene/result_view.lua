local view = require("packages.mvc.ViewBase")

local result_view = view:instance()

result_view.RESOURCE_BINDING = {
    ["reslut_bg_img"]		= {["varname"] = "reslut_bg_img"},
    ["reslut_band_img"]		= {["varname"] = "reslut_band_img"},
    ["star_1"]				= {["varname"] = "star_1"},
    ["star_2"]				= {["varname"] = "star_2"},
    ["star_3"]				= {["varname"] = "star_3"},
    ["result_text"]			= {["varname"] = "result_text"},
    ["reward_node"]         = {["varname"] = "reward_node"},
    ["left_btn_img"]		= {["varname"] = "left_btn_img"},
    ["right_btn_img"]		= {["varname"] = "right_btn_img"},
    ["reward_template"]     = {["varname"] = "reward_template"},
}

function result_view:initEvents()
    uitool:makeImgToButton(self.left_btn_img,function(sender)
    	self.ctrl:closeResultView()
    	self.ctrl:goToMainScene()
    end)

    uitool:makeImgToButton(self.right_btn_img,function(sender)
    	self.ctrl:closeResultView()
    	self.ctrl:goToMainScene()
    end)
end

function result_view:updateInfo()
    self.reward_data = GameDataCtrl:Instance():getRewardByChapterAndLevel(self.result.chapter_num, self.result.level_num)
    self.reward_list = {}
end

function result_view:updateView()
    for i=1,3 do
        if not (i > self.result.star_num) then
            self["star_"..i]:loadTexture(Config.sprite.result_star_got)
        else
            self["star_"..i]:loadTexture(Config.sprite.result_star_gray)
        end
    end
    local last_star_num = GameDataCtrl:Instance():getStarNumByChapterAndLevel(self.result.chapter_num,self.result.level_num)
    if last_star_num and last_star_num > 0 then
        self.result_text:setString(Config.text.reward_had_got)
        self.reward_node:setVisible(false)
    else
        self.result_text:setString(Config.text.reward_first_get)
        self.reward_node:setVisible(true)
        self:updateReward()
    end
end

function result_view:updateReward()
    self.reward_node:removeAllChildren()
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

    self:dealWithResultAndReward()
end

function result_view:dealWithResultAndReward()
    GameDataCtrl:Instance():setStarNum(self.result.chapter_num, self.result.level_num, self.result.star_num)
    GameDataCtrl:Instance():addRewardToSaveData(self.reward_data)
    self.result = nil
end

function result_view:setResult(result)
    self.result = result

    table.print(self.result)
end

function result_view:openView()
	if not self.is_inited then
		self:init()
	end
    if self.result and type(self.result) == type({}) then
	   self:updateInfo()
       self:updateView()
    end
	self.root:setPosition(uitool:zero())
end


return result_view