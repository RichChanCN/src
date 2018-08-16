local view = require("packages.mvc.ViewBase")

local adventure_view = view:instance()

adventure_view.RESOURCE_BINDING = {
    ["back_btn"]			= {["varname"] = "back_btn"},
    ["chapter_sv"]			= {["varname"] = "chapter_sv"},
	["left_btn"]			= {["varname"] = "left_btn"},
	["right_btn"]			= {["varname"] = "right_btn"},
}

function adventure_view:initUI()
	for i=1,1 do
		self["chapter_"..i.."_node"] = self.chapter_sv:getChildByName("chapter_"..i.."_node")
		for j=1,5 do
			self["site_"..i.."_"..j.."_img"] = self["chapter_"..i.."_node"]:getChildByName("site_"..i.."_"..j.."_img")
		end
	end
end

function adventure_view:initInfo()
	self.cur_chapter_num = 1
end

function adventure_view:initEvents()

	self.back_btn:addClickEventListener(function(sender)
        self.ctrl:closeAdventureView()
    end)
    
	if self.cur_chapter_num == 1 then
		self.left_btn:setVisible(false)
	elseif self.cur_chapter_num == 3 then
		self.right_btn:setVisible(false)
	end

	self.right_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 1 then
			self.chapter_sv:scrollToPercentHorizontal(50,0.5,true)
			self.cur_chapter_num = 2
			self.left_btn:setVisible(true)
		elseif self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToRight(0.5,true)
			self.cur_chapter_num = 3
			self.right_btn:setVisible(false)
		end
    end)

	self.left_btn:addClickEventListener(function(sender)
		if self.cur_chapter_num == 2 then
			self.chapter_sv:scrollToLeft(0.5,true)
			self.left_btn:setVisible(false)
			self.cur_chapter_num = 1
		elseif self.cur_chapter_num == 3 then
			self.chapter_sv:scrollToPercentHorizontal(50,0.5,true)
			self.right_btn:setVisible(true)
			self.cur_chapter_num = 2
		end
    end)

	for i=1,5 do
		self["site_1_"..i.."_img"]:addClickEventListener(function(sender)
			self.ctrl:openConfirmView(1,i)
		end)
	end

end

function adventure_view:updateView()
	for i=1,1 do
		for j=1,5 do
			local star_num = GameDataCtrl:Instance():getStarNumByChapterAndLevel(i, j)
			self["site_"..i.."_"..j.."_img"]:loadTexture(Config.sprite["star_"..star_num.."_site"])
			
			local challenge_img = self["site_"..i.."_"..j.."_img"]:getChildByName("challenged_img")
			if star_num > 2 then
				challenge_img:setVisible(true)
				challenge_img:loadTexture(Config.sprite.challenge_best)
			elseif star_num > 0 then
				challenge_img:setVisible(true)
				challenge_img:loadTexture(Config.sprite.challenge_normal)
			else
				challenge_img:setVisible(false)
			end

			for n=1,3 do
				local star = self["site_"..i.."_"..j.."_img"]:getChildByName("star_"..n)
				if not (n > star_num) then
					star:loadTexture(Config.sprite.site_star_get)
				else
					star:loadTexture(Config.sprite.site_star_empty)
				end
			end
		end
	end
end

function adventure_view:onOpen()
	self:updateView()
end

return adventure_view