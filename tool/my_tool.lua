table.print = function(t)  
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos,val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val,indent .. string.rep(" ", string.len(pos) + 8))
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

gtool.get_pos_list_in_range = function(self, center_pos_num, range)
    local pos_list = {[center_pos_num] = 1}
    local temp_list = {[center_pos_num] = 1}

    local pathFindHelp = function(num, step)
        if not pos_list[num] and gtool:is_legal_pos_num(num) then
            pos_list[num] = step
        end
    end
    
    local findGezi = function(pos,step)
        pathFindHelp(pos + 10, step)
        pathFindHelp(pos - 10, step)
        pathFindHelp(pos + 1, step)
        pathFindHelp(pos - 1, step)
        if pos % 2 == 0 then
            pathFindHelp(pos + 11, step)
            pathFindHelp(pos + 9, step)
        else
            pathFindHelp(pos - 11, step)
            pathFindHelp(pos - 9, step)
        end
    end

    local i = 2
    while range + 1 > i do
        for k, v in pairs(temp_list) do
            findGezi(k, i)      
        end
        temp_list = {}

        for k,v in pairs(pos_list) do
            table.insert(temp_list, k)
        end

        i = i + 1
    end

    return pos_list
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

    local deta = to_num - cur_num
    if cur_num % 2 == 0 then
        if deta == 10 then
            result_towards = 1
        elseif deta == 9 then
            result_towards = 2
        elseif deta == -1 then
            result_towards = 3
        elseif deta == -10 then
            result_towards = 4
        elseif deta == 1 then
            result_towards = 5
        elseif deta == 11 then
            result_towards = 6
        else
            toward_to_help()
        end
    else
        if deta == 10 then
            result_towards = 1
        elseif deta == -1 then
            result_towards = 2
        elseif deta == -11 then
            result_towards = 3
        elseif deta == -10 then
            result_towards = 4
        elseif deta == -9 then
            result_towards = 5
        elseif deta == 1 then
            result_towards = 6
        else
            toward_to_help()
        end
    end

    return result_towards
end

gtool.find_gezi = function(self, pos, help)
    help(pos,pos + 10)
    help(pos,pos - 10)
    help(pos,pos + 1)
    help(pos,pos - 1)
    if pos % 2 == 0 then
        help(pos,pos + 11)
        help(pos,pos + 9)
    else
        help(pos,pos - 11)
        help(pos,pos - 9)
    end
end

gtool.get_near_pos_plus = function(self, num)
    if num % 2 == 0 then
        if gtool:is_legal_pos_num(num + 10) then
            return num + 10
        elseif gtool:is_legal_pos_num(num - 10) then
            return num - 10
        elseif gtool:is_legal_pos_num(num + 1) then
            return num + 1
        elseif gtool:is_legal_pos_num(num - 1) then
            return num - 1
        elseif gtool:is_legal_pos_num(num + 11) then
            return num + 11
        elseif gtool:is_legal_pos_num(num + 9) then
            return num + 9
        end
    else
        if gtool:is_legal_pos_num(num + 10) then
            return num + 10
        elseif gtool:is_legal_pos_num(num - 10) then
            return num - 10
        elseif gtool:is_legal_pos_num(num + 1) then
            return num + 1
        elseif gtool:is_legal_pos_num(num - 1) then
            return num - 1
        elseif gtool:is_legal_pos_num(num - 11) then
            return num - 11
        elseif gtool:is_legal_pos_num(num - 9) then
            return num - 9
        end
    end

    return false
end