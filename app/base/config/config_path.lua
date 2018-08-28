g_config = g_config or {}

g_config.model_path 		= "Model/"
g_config.particle_path 		= "Particle/"
g_config.sprite_path 		= "Sprite/"
g_config.monster_img_path	= "Monster/"
g_config.xml_path 			= "res/Data/"
g_config.fonts_path 		= "res/Font/"


g_config.to_sprite_path = function(self, file)
	return self.sprite_path .. file
end

g_config.to_monster_img_path = function(self, file)
	return self.monster_img_path .. file
end

g_config.to_font_path = function(self, file)
	return self.fonts_path .. file
end

g_config.to_particle_path = function(self, file)
	return self.particle_path .. file
end

g_config.to_model_path = function(self, file)
	return self.model_path .. file
end

g_config.to_xml_path = function(self, file)
	return self.xml_path .. file
end