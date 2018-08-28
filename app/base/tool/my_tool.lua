table.print = function(t)  
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

gtool = {}

gtool._class = {}

gtool.class = function(super)
    local class_type = {}
    class_type.ctor = false
    class_type.super = super
    class_type.new = function(self, ...) 
        local obj = {}
        do
            local create
            create = function(c, ...)
                if c.super then
                    create(c.super, ...)
                end
                if c.ctor then
                    c.ctor(obj, ...)
                end
            end

            create(class_type, ...)
        end
        setmetatable(obj, { __index = gtool._class[class_type]})
        return obj
    end

    local vtbl = {}
    gtool._class[class_type] = vtbl
 
    setmetatable(class_type,{__newindex =
        function(t, k, v)
            vtbl[k] = v
        end
    })
 
    if super then
        setmetatable(vtbl, {__index=
            function(t, k)
                local ret = gtool._class[super][k]
                vtbl[k] = ret
                return ret
            end
        })
    end
 
    return class_type
end

gtool.get_monster_cfg_by_id = function(self, id)
    return g_config.monster[id]
end

gtool.ccp_2_int = function(self, pos)
    if type(pos) == type({}) and pos.x and pos.y then
        return pos.x * 10 + pos.y
    else
        print("gtool:ccp_2_int warning: pos is type: " .. type(pos))
        return pos 
    end
end

gtool.int_2_ccp = function(self, num)
    if type(num) == type(1) then 
        return cc.p(math.modf(num / 10),num % 10) 
    else
        print("gtool:int_2_ccp warning: num is type: " .. type(num))
        return num
    end
end

gtool.normalize_towards = function(self, towards)
    local normal_towards = towards
    if towards % 6 == 0 then
        normal_towards = 6
    elseif towards > 6 then
        normal_towards = towards % 6
    elseif towards < 0 then
        normal_towards = math.abs(-math.floor(towards / 6) * 6 + 6 + towards) % 6
    end

    return normal_towards
end

gtool.is_legal_pos_num = function(self, pos)
    if pos > 11 and pos % 10 < 8 and pos % 10 > 0
        and pos ~= 17 and (pos < 78 or pos == 83 or pos == 85) then
        return true
    end

    return false
end

gtool.around_pos_even = 
{
    [10]    = 1,
    [9]     = 2,
    [-1]    = 3,
    [-10]   = 4,
    [1]     = 5,
    [11]    = 6,
}

gtool.around_pos_odd = 
{
    [10]    = 1,
    [-1]    = 2,
    [-11]   = 3,
    [-10]   = 4,
    [-9]    = 5,
    [1]     = 6,
}

gtool.towards_pos_even = 
{
    [1] = 10,
    [2] = 9,
    [3] = -1,
    [4] = -10,
    [5] = 1,
    [6] = 11, 
}

gtool.towards_pos_odd = 
{
    [1] = 10,
    [2] = -1,
    [3] = -11,
    [4] = -10,
    [5] = -9,
    [6] = 1,
}

gtool.bfs_distance = function(self, center_pos_num, range)
    local pos_list = {[center_pos_num] = 0}
    local temp_list = {[0] = center_pos_num}

    local path_find_help = function(num, step)
        if not pos_list[num] and gtool:is_legal_pos_num(num) then
            pos_list[num] = step
        end
    end
    
    local find_gezi = function(pos, step)
        local temp_table = gtool:get_towards_tbl(pos)

        for k, v in pairs(temp_table) do
            path_find_help(pos + v, step)
        end
    end

    for i = 1, range do
        for k, v in pairs(temp_list) do
            find_gezi(v, i)      
        end
        temp_list = {}

        for k, v in pairs(pos_list) do
            table.insert(temp_list, k)
        end
    end

    return pos_list
end

gtool.bfs_path = function(self, pos_num, steps, path_find_help)
    local area_table = {}
    local temp_list = {}

    gtool:find_gezi(pos_num, path_find_help, area_table)
    for k, v in pairs(area_table) do
        table.insert(temp_list, k)
    end

    for i = 2, steps do
        for _, v in pairs(temp_list) do

            gtool:find_gezi(v, path_find_help, area_table)
            
        end
        temp_list = {}

        for k, v in pairs(area_table) do
            table.insert(temp_list, k)
        end
    end

    return area_table
end

gtool.do_something_later = function(self, callback, time)
    local ac_node = cc.Node:create()
    pve_game_ctrl:instance():get_action_node():addChild(ac_node)
    local default_ac = ac_node:runAction(cc.ScaleTo:create(time, 1))
    local seq = cc.Sequence:create(default_ac, callback)
    ac_node:runAction(seq)
end

gtool.get_toward_to_int_pos = function(self, cur_num, to_num)
    if not to_num then 
        return
    end

    local result_towards

    local toward_to_help = function ()
        local to_pos = gtool:int_2_ccp(to_num)
        local cur_pos = gtool:int_2_ccp(cur_num)
        if to_num > cur_num then
            if to_pos.x - cur_pos.x > math.abs(to_pos.y - cur_pos.y) then
                result_towards = 1
            elseif to_pos.y > cur_pos.y then
                result_towards = 6
            else
                result_towards = 2
            end
        else
            if cur_pos.x - to_pos.x > math.abs(to_pos.y - cur_pos.y) then
                result_towards = 4
            elseif to_pos.y>cur_pos.y then
                result_towards = 5
            else
                result_towards = 3
            end
        end
    end

    local delta = to_num - cur_num
    local tbl = gtool:get_around_tbl(cur_num)

    if tbl[delta] then
        result_towards = tbl[delta]
    else
        toward_to_help()
    end

    return result_towards
end

gtool.find_gezi = function(self, pos, help, path_table)
    local tbl = gtool:get_towards_tbl(pos)
    
    for k, v in pairs(tbl) do
        help(pos, pos + v, path_table)
    end
end

gtool.get_near_pos_plus = function(self, num)
    local tbl = gtool:get_towards_tbl(num)
    
    for k, v in pairs(tbl) do
        if is_legal_pos_num(num + v) then
            return num + v
        end
    end

    return false
end

gtool.get_around_tbl = function(self, num)
    local tbl 
    if gtool:is_even(num) then
        tbl = gtool.around_pos_even
    else
        tbl = gtool.around_pos_odd
    end

    return tbl
end

gtool.get_towards_tbl = function(self, num)
    local tbl 
    if gtool:is_even(num) then
        tbl = gtool.towards_pos_even
    else
        tbl = gtool.towards_pos_odd
    end

    return tbl
end

gtool.is_even = function(self, num)
    return num % 2 == 0
end