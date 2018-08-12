local SkillBase = {}

function SkillBase:instance()
	return setmetatable({}, { __index = self })
end

function SkillBase:new(skill_data)
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
	self.paticle_path 			= skill_data.paticle_path
	self.paticle_pos			= skill_data.paticle_pos
	self.buff					= skill_data.buff
	self.debuff					= skill_data.debuff

	return self
end

function SkillBase:use(caster,target_pos_num)
	local monster_list = self:getBeAffectedMonsterList(caster,target_pos_num)
	--Judgment:Instance():getScene():getParticleNode():removeChildByName(self.name)
	if #monster_list < 1 then
		print("no monster is affected by "..self.name)
	else
		for i,v in ipairs(monster_list) do
			if not monster_list[i+1] then
				v:beAffectedBySkill(caster,self,true)
			else
				v:beAffectedBySkill(caster,self)
			end
		end
	end

end

function SkillBase:play()
	local particle = cc.ParticleSystemQuad:create(self.paticle_path)
	particle:setName(self.name)
	particle:setGlobalZOrder(uitool:mid_Z_order())
	particle:setPosition(self.paticle_pos)
	Judgment:Instance():getScene():getParticleNode():addChild(particle)
end

function SkillBase:getBeAffectedMonsterList(caster,target_pos_num)
	local monster_list = {}
	if self.range<1 then
		if (self.damage > 0 or self.debuff) and (self.healing > 0 and self.buff) then
			monster_list = Judgment:Instance():getAllAliveMonsters()
		elseif self.damage > 0 or self.debuff then
			monster_list = caster:getAliveEnemyMonsters()
		elseif self.healing > 0 and self.buff then
			monster_list = caster:getAliveFriendMonsters()
		end
	elseif target_pos_num and self.range > 1 then
		local pos_list = gtool:getPosListInRange(target_pos_num, self.range)
		local map_info = Judgment:Instance():getMapInfo()
		for k,v in pairs(pos_list) do
			if map_info[v] and caster:isEnemy(map_info[v]) then
				table.insert(monster_list,map_info[v])
			end
		end
	elseif self.range == 1 then
		local map_info = Judgment:Instance():getMapInfo()
		table.insert(monster_list,map_info[target_pos_num])
	end

	return monster_list
end

return SkillBase