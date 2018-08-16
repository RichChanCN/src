local SkillBase = {}

function SkillBase:instance()
	return setmetatable({}, { __index = self })
end

function SkillBase:new(monster,skill_data)
	self.caster 				= monster
	self.name 					= skill_data.name 		
	self.description 			= skill_data.description 
	self.img_path				= skill_data.img_path
	self.range 					= skill_data.range
	self.is_need_target			= skill_data.is_need_target
	self.cost 					= skill_data.cost 
	self.damage 				= skill_data.damage
	self.damage_level_plus 		= skill_data.damage_level_plus
	self.healing				= skill_data.healing
	self.healing_level_plus		= skill_data.healing_level_plus
	self.particle_path 			= skill_data.particle_path
	self.particle_pos			= skill_data.particle_pos
	self.particle_scale			= skill_data.particle_scale
	self.particle_delay_time 	= skill_data.particle_delay_time
	self.buff					= skill_data.buff
	self.debuff					= skill_data.debuff

	return self
end

function SkillBase:isNeedTarget()
	return self.is_need_target
end

function SkillBase:use(target_pos_num)
	self.target_pos_num = target_pos_num
	
	if (not target_pos_num) and (not self.is_need_target) or self.range < 1 then
		self.target_pos_num = self.caster:getCurPosNum()
	elseif (not target_pos_num) and self.is_need_target then 
		uitool:createTopTip(self.name.." need a target pos !")
		return
	end
	local monster_list = self:getBeAffectedMonsterList()
	--Judgment:Instance():getScene():getParticleNode():removeChildByName(self.name)
	if #monster_list < 1 then
		uitool:createTopTip("no monster is affected by "..self.name)
		Judgment:Instance():nextMonsterActivate()
	else
		for i,v in ipairs(monster_list) do
			if not monster_list[i+1] then
				v:beAffectedBySkill(self,true)
			else
				v:beAffectedBySkill(self)
			end
		end
	end

end

function SkillBase:play()
	if not self.particle_path then 
		return
	end

	local cb = function()
		local particle = cc.ParticleSystemQuad:create(self.particle_path)
		particle:setName(self.name)
		if self.particle_scale then
			particle:setScale(self.particle_scale)
		end
		particle:setGlobalZOrder(uitool:mid_Z_order())
		particle:setPosition(self.particle_pos)
		if self.range < 1 then
			Judgment:Instance():getScene():getParticleNode():addChild(particle)
		else
			local map_info = Judgment:Instance():getMapInfo()
			map_info[self.caster:getCurPosNum()].node:addChild(particle)
		end
	end

	if self.particle_delay_time then
		local callback = cc.CallFunc:create(cb)
		gtool:doSomethingLater(callback, self.particle_delay_time)
	else
		cb()
	end
		

end

function SkillBase:getBeAffectedMonsterList()
	local monster_list = {}
	if self.range<1 then
		if (self.damage > 0 or self.debuff) and (self.healing > 0 or self.buff) then
			monster_list = Judgment:Instance():getAllAliveMonsters()
		elseif self.damage > 0 or self.debuff then
			monster_list = self.caster:getAliveEnemyMonsters()
		elseif self.healing > 0 or self.buff then
			monster_list = self.caster:getAliveFriendMonsters()
		end
	elseif (not self:isNeedTarget()) and self.range > 1 then
		local pos_list = gtool:getPosListInRange(self.caster:getCurPosNum(), self.range)
		local map_info = Judgment:Instance():getMapInfo()
		for k,v in pairs(pos_list) do
			if map_info[k] and type(map_info[k]) == type({}) and self.caster:isEnemy(map_info[k]) then
				table.insert(monster_list,map_info[k])
			end
		end
	elseif self.target_pos_num and self.range > 1 then
		local pos_list = gtool:getPosListInRange(self.target_pos_num, self.range)
		local map_info = Judgment:Instance():getMapInfo()
		for k,v in pairs(pos_list) do
			if map_info[k] and type(map_info[k]) == type({}) and self.caster:isEnemy(map_info[k]) then
				table.insert(monster_list,map_info[k])
			end
		end
	elseif self.range == 1 then
		local map_info = Judgment:Instance():getMapInfo()
		table.insert(monster_list,map_info[self.target_pos_num])
	end

	return monster_list
end

return SkillBase