g_config = g_config or {}

g_config.Particle = 
{
	magic_ball		= g_config:to_particle_path("magicball.plist"),
	frozen 			= g_config:to_particle_path("frozen.plist"),
	poison 			= g_config:to_particle_path("poison.plist"),
	stun 			= g_config:to_particle_path("stun.plist"),
	damage_up 		= g_config:to_particle_path("damageup.plist"),
	skill_can_use 	= g_config:to_particle_path("skillcanuse.plist"),
	skill_will_use 	= g_config:to_particle_path("skillwilluse.plist"),
}