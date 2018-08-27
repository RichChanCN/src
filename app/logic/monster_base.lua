local monster_base = {}

monster_base.team_side = 
{
	NONE 	= 0,
	LEFT 	= 1,
	RIGHT 	= 4,
}

monster_base.damage_level = 
{
    MISS 		= 0,
    LOW 		= 1,
	COMMON 		= 2,
	HIGH 		= 3,
	HIGHER 		= 4,
	HIGHEST 	= 5,
	SKILL 		= 6,
	HEAL		= 7,
	POISON 		= 8,
}

monster_base.status = 
{
	DEAD 		= 0,
	ALIVE 		= 1,
	DEFEND 		= 2,
	WAITING 	= 3,
	CANT_ATTACK = 100,
	CANT_ACTIVE = 1000,
	STUN 		= 1001,
}

monster_base.towards = 
{
	[0]		= 1,
	[1] 	= 1,
	[2] 	= 2,
	[3] 	= 3,
	[4] 	= 4,
	[5] 	= 5,
	[6] 	= 6,
}

return monster_base