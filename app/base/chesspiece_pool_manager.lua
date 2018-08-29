chesspiece_pool_manager = {}

chesspiece_pool_manager.instance = function(self)
	if self._instance == nil then
		self._instance = self:new()
	end
	return self._instance
end

chesspiece_pool_manager.new = function(self)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	self._pool = {}

	return o
end

chesspiece_pool_manager.get = function(self, monster, index)
	for k, v in pairs(self._pool) do
		if not v.is_using then
			self:update_chesspiece(v, monster, index)
			return v
		end
	end

	return self:create_new_chesspiece(monster, index)
end

chesspiece_pool_manager.put = function(self, chesspiece)
	chesspiece.is_using = nil
	if chesspiece:getParent() then
		chesspiece:removeFromParent()
	end
end

chesspiece_pool_manager.create_new_chesspiece = function(self, monster, index)
	local monster_cfg = game_data_ctrl:instance():get_monster_data_by_id(monster.id)
	local chesspiece = cc.Sprite:create(g_config.sprite.chesspiece_mask)
	chesspiece:setScale(0.5)
	local blendfunc = {src = gl.ONE_MINUS_SRC_ALPHA, dst = gl.ONE_MINUS_SRC_ALPHA}
	chesspiece:setBlendFunc(blendfunc)
	
	chesspiece.face_sp = cc.Sprite:create(monster_cfg.char_img_path)
	blendfunc = {src = gl.ONE_MINUS_DST_ALPHA, dst = gl.DST_ALPHA}
	chesspiece.face_sp:setBlendFunc(blendfunc)
	chesspiece.face_sp:setName("face_sp")

	chesspiece.hex_border = cc.Sprite:create(g_config.sprite["hex_border_" .. monster_cfg.rarity])
	chesspiece.hex_border:setScale(2.0)
	chesspiece.hex_border:setName("hex_border")
	chesspiece:addChild(chesspiece.hex_border, uitool.bottom_z_order + 5)

	local pos = uitool:get_node_center_position(chesspiece)
	chesspiece.hex_border:setPosition(pos)
	chesspiece:addChild(chesspiece.face_sp, uitool.bottom_z_order)
	chesspiece.face_sp:setPosition(pos)
	
	chesspiece:setName("chesspiece_" .. index)

	chesspiece.monster = monster

	table.insert(self._pool, chesspiece)

	chesspiece.is_using  = true
	chesspiece:retain()

	return chesspiece
end

chesspiece_pool_manager.update_chesspiece = function(self, chesspiece, monster, index)
	monster = game_data_ctrl:instance():get_monster_data_by_id(monster.id)
	chesspiece.face_sp:setTexture(monster.char_img_path)
	chesspiece.hex_border:setTexture(g_config.sprite["hex_border_" .. monster.rarity])
	chesspiece:setName("chesspiece_" .. index)

	chesspiece:setOpacity(255)
	chesspiece.face_sp:setOpacity(255)
	chesspiece.hex_border:setOpacity(255)

	local blendfunc = {src = gl.ONE_MINUS_SRC_ALPHA, dst = gl.ONE_MINUS_SRC_ALPHA}
	chesspiece:setBlendFunc(blendfunc)
	blendfunc = {src = gl.ONE_MINUS_DST_ALPHA, dst = gl.DST_ALPHA}
	chesspiece.face_sp:setBlendFunc(blendfunc)

	chesspiece.monster = monster
	chesspiece.is_using  = true
end

chesspiece_pool_manager.recycle_all = function(self)
	for k, v in pairs(self._pool) do
		self:put(v)
	end
end

chesspiece_pool_manager.clear_up = function(self)
	for k, v in pairs(self._pool) do
		v:release()
	end

	self._pool = {}
end
