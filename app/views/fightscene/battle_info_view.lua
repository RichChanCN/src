local view = require("packages.mvc.ViewBase")

local battle_info_view = view:instance()

battle_info_view.RESOURCE_BINDING = {
	["left_bottom_img"]         = {["varname"] = "left_bottom_img"},
    ["right_bottom_node"]       = {["varname"] = "right_bottom_node"},

}

function battle_info_view:init()
    if not self.isInited then
        uitool:createUIBinding(self, self.RESOURCE_BINDING)

        self:initRightBottom()
        self:initLeftBottom()
        self:initInfo()
        self:initEvents()

        self.isInited = true
    else
        print(self.name.." is inited! scape the init()")
    end
end

function battle_info_view:initInfo()
    self.left_bottom_img_start_pos = cc.p(0,-530)
    self.left_bottom_img_end_pos   = cc.p(0,0)
    self.right_bottom_node_start_pos = cc.p(1750,-400)
    self.right_bottom_node_end_pos   = cc.p(1750,150)
end

function battle_info_view:initEvents()
    self:initRightBottomEvents()
end

function battle_info_view:updateView()

end

function battle_info_view:openView()
    if not self.isInited then
        self:init()
    end
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3,self.left_bottom_img_end_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3,self.right_bottom_node_end_pos))
end

function battle_info_view:closeView()
    self.left_bottom_img:runAction(cc.MoveTo:create(0.3,self.left_bottom_img_start_pos))
    self.right_bottom_node:runAction(cc.MoveTo:create(0.3,self.right_bottom_node_start_pos))
end
----------------------------------------------------------------
-------------------------------私有方法--------------------------
----------------------------------------------------------------

function battle_info_view:initRightBottom()
    self.defend_img     = self.right_bottom_node:getChildByName("defend_img")
    self.wait_img       = self.right_bottom_node:getChildByName("wait_img")
    self.auto_img       = self.right_bottom_node:getChildByName("auto_img")
    self.speed_img      = self.right_bottom_node:getChildByName("speed_img")
    self.setting_img    = self.right_bottom_node:getChildByName("setting_img")
end

function battle_info_view:initRightBottomEvents()
    uitool:makeImgToButton(self.defend_img, function()
        if Judgment:Instance():getGameStatus() == Judgment.GameStatus.WAIT_ORDER then
            Judgment:Instance():requestDefend()
        end
    end)

    uitool:makeImgToButton(self.wait_img, function()
        if Judgment:Instance():getGameStatus() == Judgment.GameStatus.WAIT_ORDER then
            Judgment:Instance():requestWait()
        end
    end)

    uitool:makeImgToButton(self.auto_img, function()
        if Judgment:Instance():getGameStatus() == Judgment.GameStatus.WAIT_ORDER then
            Judgment:Instance():requestAuto()
        end
    end)
end

function battle_info_view:initLeftBottom()

end

return battle_info_view