g_config = g_config or {}

g_config.Map = 
{	-- 章节编号
	[1] = 
	{
		-- 关卡编号
		[1] = 
		{
			-- 奖励列表
			reward = 
			{
				monster = 
				{
					[1] = 10,
					[4] = 10,
				},
				exp = 20,
				crystal = 10,
				coin = 100,
			},

			-- 可以使用的怪物列表
			can_use_monster_list = 
			{
				1
			},

			-- 上场怪物限制
			monster_num_limit = 1,
			-- 障碍物模型路径
			barrier_model = g_config:to_model_path("tree.c3b"),
			-- 战场信息 0 代表可以放置怪物  2代表障碍物   大于100的代表敌人
			arena_info = 
			{
				[12] = 0,
				[13] = 0,
				[14] = 0,
				[15] = 0,
				[16] = 0,
				
				[21] = 0,
				[22] = 0,
				[23] = 0,
				[24] = 0,
				[25] = 0,
				[26] = 0,
				[27] = 0,
				
				[44] = 301,
			},
		},

		[2] = 
		{
			reward = 
			{
				monster = 
				{
					[2] = 10,
					[3] = 1,
				},
				exp = 40,
				crystal = 20,
				coin = 200,
			},

			can_use_monster_list = nil,

			monster_num_limit = 5,

			barrier_model = g_config:to_model_path("tree.c3b"),

			arena_info = 
			{
				[12] = 0,
				[13] = 0,
				[14] = 0,
				[15] = 0,
				[16] = 0,

				[21] = 0,
				[22] = 0,
				[23] = 0,
				[24] = 0,
				[25] = 0,
				[26] = 0,
				[27] = 0,

				[43] = 2,
				[44] = 2,
				[45] = 2,

				[83] = 301,
				[85] = 301,
			},
		},

		[3] = 
		{
			reward = 
			{
				monster = 
				{
					[3] = 2,
					[4] = 1,
				},
				exp = 60,
				crystal = 10,
				coin = 300,
			},

			can_use_monster_list = nil,

			monster_num_limit = 5,

			barrier_model = g_config:to_model_path("tree.c3b"),

			arena_info = 
			{
				[12] = 0,
				[13] = 0,
				[14] = 0,
				[15] = 0,
				[16] = 0,

				[21] = 0,
				[22] = 0,
				[23] = 0,
				[24] = 0,
				[25] = 0,
				[26] = 0,
				[27] = 0,

				[54] = 2,
				[66] = 2,
				[67] = 2,
				[52] = 2,

				[83] = 302,
				[85] = 302,
			},
		},

		[4] = 
		{
			reward = 
			{
				monster = 
				{
					[4] = 2,
					[5] = 1,
				},
				exp = 50,
				crystal = 10,
				coin = 400,
			},

			can_use_monster_list = nil,

			monster_num_limit = 5,

			barrier_model = g_config:to_model_path("tree.c3b"),

			arena_info = 
			{
				[12] = 0,
				[13] = 0,
				[14] = 0,
				[15] = 0,
				[16] = 0,

				[21] = 0,
				[22] = 0,
				[23] = 0,
				[24] = 0,
				[25] = 0,
				[26] = 0,
				[27] = 0,

				[42] = 2,
				[43] = 2,
				
				[45] = 2,
				[46] = 2,

				[74] = 306,
				[83] = 304,
				[85] = 304,
			},
		},

		[5] = 
		{
			reward = 
			{
				monster = 
				{
					[6] = 1,
					[7] = 1,
				},
				exp = 100,
				crystal = 50,
				coin = 500,
			},

			can_use_monster_list = nil,

			monster_num_limit = 5,

			barrier_model = g_config:to_model_path("tree.c3b"),
			
			arena_info = 
			{
				[12] = 0,
				[13] = 0,
				[14] = 0,
				[15] = 0,
				[16] = 0,

				[21] = 0,
				[22] = 0,
				[23] = 0,
				[24] = 0,
				[25] = 0,
				[26] = 0,
				[27] = 0,

				[73] = 2,
				[64] = 2,
				[75] = 2,

				[72] = 306,
				[74] = 303,
				[76] = 306,
			},
		},
	},
}