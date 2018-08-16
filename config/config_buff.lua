Config = Config or {}

Config.Buff = {
-----------------------------------------------------------------------
-------------------------------buff------------------------------------
-----------------------------------------------------------------------
	--执行防御之后自动加上的状态，持续到下回合开始
	defend = {
		--持续回合数，0代表持续到下次回合开始
		round = 0,
		--buff附加到对象上后会调用的
		begin = function(monster)
			local defend_sp = cc.Sprite:create()
			defend_sp:setTexture(Config.sprite.buff_defend)
			defend_sp:setPosition(0, 20)
			defend_sp:setGlobalZOrder(uitool:top_Z_order())
			defend_sp:setName("defend")
			defend_sp:setContentSize(50,75)
			defend_sp:runAction(cc.ScaleTo:create(1,1.2))
			defend_sp:runAction(cc.FadeOut:create(1))
			monster.node:addChild(defend_sp)
		end,
		--每回合开始会调用一次的
		once_a_round = function(monster)
			
		end,
		--计算对象属性时候会调用
		apply = function(monster)
			monster.cur_physical_defense = monster.cur_physical_defense * 2
			monster.cur_magic_defense = monster.cur_magic_defense * 2
		end,
		--buff从对象上移除后会调用的
		finish = function(monster)
			monster.node:removeChildByName("defend")
		end,

		--clone该buff，使得多个目标不互相影响
		clone = function(self)
			local buff = {}

			buff.round 			= self.round 
			buff.begin 			= self.begin
			buff.once_a_round 	= self.once_a_round
			buff.apply 			= self.apply
			buff.finish 		= self.finish

			return buff
		end,
	},

	--伤害提升
	damage_up = {
		round = 2,
		begin = function(monster)
			local particle = cc.ParticleSystemQuad:create(Config.Particle.damage_up)
			particle:setScale(0.3)
			particle:setName("damageup")
			particle:setGlobalZOrder(uitool:top_Z_order())
			particle:setPosition(0, 20)
			monster.node:addChild(particle)
		end,
		once_a_round = function(monster)
		end,
		apply = function(monster)
			monster.cur_damage = monster.cur_damage * 1.3
		end,
		finish = function(monster)
			monster.node:removeChildByName("damageup")
		end,

		clone = function(self)
			local buff = {}

			buff.round 			= self.round 
			buff.begin 			= self.begin
			buff.once_a_round 	= self.once_a_round
			buff.apply 			= self.apply
			buff.finish 		= self.finish

			return buff
		end,
	},

-----------------------------------------------------------------------
------------------------------debuff-----------------------------------
-----------------------------------------------------------------------
	--移动受限，可移动范围 -1
	move_limit = {
		round = 1,
		begin = function(monster)
			local particle = cc.ParticleSystemQuad:create(Config.Particle.frozen)
			particle:setScale(0.3)
			particle:setName("frozen")
			particle:setGlobalZOrder(uitool:top_Z_order())
			particle:setPosition(0, 20)
			monster.node:addChild(particle)
		end,
		once_a_round = function(monster)
		end,
		apply = function(monster)
			monster.cur_mobility = monster.mobility - 1
		end,
		finish = function(monster)
			monster.node:removeChildByName("frozen")
		end,

		clone = function(self)
			local buff = {}

			buff.round 			= self.round 
			buff.begin 			= self.begin
			buff.once_a_round 	= self.once_a_round
			buff.apply 			= self.apply
			buff.finish 		= self.finish

			return buff
		end,
	},
	--激活受限，眩晕1回合
	stun = {
		round = 1,
		begin = function(monster)
			local particle = cc.ParticleSystemQuad:create(Config.Particle.stun)
			particle:setScale(0.3)
			particle:setName("stun")
			particle:setGlobalZOrder(uitool:top_Z_order())
			particle:setPosition(0, 40)
			monster.node:addChild(particle)
			local MonsterBase = require("app.logic.MonsterBase")
			monster:addMonsterStatus(MonsterBase.Status.STUN)
		end,
		once_a_round = function(monster)
		end,
		apply = function(monster)
		end,
		finish = function(monster)
			local MonsterBase = require("app.logic.MonsterBase")
			monster:removeMonsterStatus(MonsterBase.Status.STUN)
			monster.node:removeChildByName("stun")
		end,

		clone = function(self)
			local buff = {}

			buff.round 			= self.round 
			buff.begin 			= self.begin
			buff.once_a_round 	= self.once_a_round
			buff.apply 			= self.apply
			buff.finish 		= self.finish

			return buff
		end,
	},

	--中毒，降低伤害，每回合开始时扣除一定血量
	poison = {
		round = 2,
		begin = function(monster)
			local particle = cc.ParticleSystemQuad:create(Config.Particle.poison)
			particle:setScale(0.3)
			particle:setName("poison")
			particle:setGlobalZOrder(uitool:top_Z_order())
			particle:setPosition(0, 20)
			monster.node:addChild(particle)
		end,
		once_a_round = function(monster)
			local MonsterBase = require("app.logic.MonsterBase")
			monster:minusHP(40, MonsterBase.DamageLevel.POISON,true)
		end,
		apply = function(monster)
			monster.cur_damage = monster.cur_damage * 0.9
		end,
		finish = function(monster)
			monster.node:removeChildByName("poison")
		end,

		clone = function(self)
			local buff = {}

			buff.round 			= self.round 
			buff.begin 			= self.begin
			buff.once_a_round 	= self.once_a_round
			buff.apply 			= self.apply
			buff.finish 		= self.finish

			return buff
		end,
	},
}