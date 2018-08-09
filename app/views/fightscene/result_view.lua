local view = require("packages.mvc.ViewBase")

local result_view = view:instance()

result_view.RESOURCE_BINDING = {
    ["reslut_bg_img"]		= {["varname"] = "reslut_bg_img"},
    ["reslut_band_img"]		= {["varname"] = "reslut_band_img"},
    ["star_1"]				= {["varname"] = "star_1"},
    ["star_2"]				= {["varname"] = "star_2"},
    ["star_3"]				= {["varname"] = "star_3"},
    ["reslut_text"]			= {["varname"] = "reslut_text"},
    ["left_btn_img"]		= {["varname"] = "left_btn_img"},
    ["right_btn_img"]		= {["varname"] = "right_btn_img"},
}

function result_view:initInfo()
end

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

function result_view:updateView()

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
	   self:updateView()
    end
	self.root:setPosition(uitool:zero())
end


return result_view