return function(asmCode,astNodes)
    local sections = {"","","",""}
    local function text(str)
        sections[1] = sections[1] .. str
    end
    local function rodata(str)
        sections[2] = sections[2] .. str
    end
    local function data(str)
        sections[3] = sections[3] .. str
    end
    local function bss(str)
        sections[4] = sections[4] .. str
    end

    local functions = {
        ["+"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("add t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["-"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sub t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["*"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("mul t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u*"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("mulu t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["/"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("div t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u/"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("divu t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["%"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("div zero, t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u%"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("divu zero, t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["/%"]=function()
            text("lw t0, 4(sp)\n")
            text("lw t1, 8(sp)\n")
            text("div t0, t1, t0, t1\n")
            text("sw t0, 4(sp)\n")
            text("sw t1, 8(sp)\n")
        end,
        ["u/%"]=function()
            text("lw t0, 4(sp)\n")
            text("lw t1, 8(sp)\n")
            text("divu t0, t1, t0, t1\n")
            text("sw t0, 4(sp)\n")
            text("sw t1, 8(sp)\n")
        end,
        ["!"]=function()
            text("lw t0, 4(sp)\n")
            text("la t1, 0xffffffff")
            text("xor t0, t0, t1\n")
            text("sw t0, 4(sp)\n")
        end,
        ["&"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("and t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["|"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("or t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["^"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("xor t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["<"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("slt t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        [">"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("slt t0, t1, t0\n")
            text("sw t0, 0(sp)\n")
        end,
        ["="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sub t0, t0, t1\n")
            text("sltiu t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["!="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sub t0, t0, t1\n")
            text("sltu t0, zero, t0\n")
            text("sw t0, 0(sp)\n")
        end,
        [">="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("slt t0, t0, t1\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["<="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("slt t0, t1, t0\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u<"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sltu t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u>"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sltu t0, t1, t0\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u>="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sltu t0, t0, t1\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u<="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, 4(sp)\n")
            text("sltu t0, t1, t0\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["pop"]=function()
            text("addi sp, sp, 4\n")
        end,
        ["nip"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("sw t0, 4(sp)\n")
        end,
        ["dup"]=function()
            text("lw t0, 4(sp)\n")
            text("addi sp, sp, -4\n")
            text("sw t0, 4(sp)\n")
        end,
        ["swap"]=function()
            text("lw t0, 4(sp)\n")
            text("lw t1, 8(sp)\n")
            text("sw t0, 8(sp)\n")
            text("sw t1, 4(sp)\n")
        end,
        ["rot"]=function()
            text("lw t0, 4(sp)\n")
            text("lw t1, 8(sp)\n")
            text("lw t2, 12(sp)\n")
            text("sw t0, 8(sp)\n")
            text("sw t1, 12(sp)\n")
            text("sw t2, 4(sp)\n")
        end,
        ["over"]=function()
            text("lw t0, 8(sp)\n")
            text("addi sp, sp, -4\n")
            text("sw t0, 4(sp)\n")
        end,
        ["@"]=function()
            text("lw t0, 4(sp)\n")
            text("lw t1, 0(t0)\n")
            text("sw t1, 4(sp)\n")
        end,
        ["!"]=function()
            text("lw t0, 8(sp)\n")
            text("lw t1, 4(sp)\n")
            text("addi sp, sp, 8\n")
            text("sw t0, 0(t1)\n")
        end,
        ["b@"]=function()
            text("lw t0, 4(sp)\n")
            text("lbu t1, 0(t0)\n")
            text("sw t1, 4(sp)\n")
        end,
        ["sb@"]=function()
            text("lw t0, 4(sp)\n")
            text("lb t1, 0(t0)\n")
            text("sw t1, 4(sp)\n")
        end,
        ["b!"]=function()
            text("lw t0, 8(sp)\n")
            text("lw t1, 4(sp)\n")
            text("addi sp, sp, 8\n")
            text("sb t0, 0(t1)\n")
        end,
        ["h@"]=function()
            text("lw t0, 4(sp)\n")
            text("lhu t1, 0(t0)\n")
            text("sw t1, 4(sp)\n")
        end,
        ["sh@"]=function()
            text("lw t0, 4(sp)\n")
            text("lh t1, 0(t0)\n")
            text("sw t1, 4(sp)\n")
        end,
        ["h!"]=function()
            text("lw t0, 8(sp)\n")
            text("lw t1, 4(sp)\n")
            text("addi sp, sp, 8\n")
            text("sb t0, 0(t1)\n")
        end
    }

    local function forEach(nodes,nodeType,fn)
        for _,i in ipairs(nodes) do
            if i.type == nodeType then
                fn(i)
            end
        end
    end

    forEach(astNodes,"constant",function(node)
        functions[node.data.name] = function()
            text("la t0, "..node.data.val.."\n")
        end
    end)

    local strCount = 0

    forEach(astNodes,"function",function(node)
        functions[node.data.name] = function()
            text("bl "..node.data.name.."\n")
        end
    end)

    local function genCode(args,vars,nodes,baseLoop,baseIf)
        local cursor = 1
        local loopCount = baseLoop
        local ifCount = baseIf
        while cursor <= #nodes do
            if nodes[cursor].type == "pushNumber" then
                text("la t0, "..nodes[cursor].data.."\n")
                text("sw t0, 0(sp)\n")
                text("addi sp, sp, -4\n")
            elseif nodes[cursor].type == "pushString" then
                rodata("_VOSString"..strCount..": ")
                for i=1,#nodes[cursor].data do
                    rodata(".byte "..nodes[cursor].data:sub(i,i):byte().." ")
                end
                rodata(".byte 0\n")
                text("la t0, _VOSString"..strCount.."\n")
                text("sw t0, 0(sp)\n")
                text("addi sp, sp, -4\n")
                strCount = strCount + 1
            elseif nodes[cursor].type == "if" then
                --[[for _,i in ipairs(nodes[cursor].data.ifs) do
                    genCode(args,vars,nodes[cursor].data.condition,loopCount,ifCount+1)
                    ifCount = ifCount + 1
                end]]
            elseif nodes[cursor].type == "loop" then
                text(".VOSLoop"..loopCount..":\n")
                genCode(args,vars,nodes[cursor].data.condition,loopCount+1,ifCount)
                text("addi sp, sp, 4\n")
                text("lw t0, 0(sp)\n")
                text("beq t0, zero, .VOSLoopAfter"..loopCount.."\n")
                genCode(args,vars,nodes[cursor].data.nodes,loopCount+1,ifCount)
                text("b .VOSLoop"..loopCount.."\n")
                text(".VOSLoopAfter"..loopCount..":\n")
                loopCount = loopCount + 1
            elseif nodes[cursor].type == "functionCall" then
                if functions[nodes[cursor].data] ~= nil then
                    functions[nodes[cursor].data]()
                elseif nodes[cursor].data:sub(1,1) == "@" and #nodes[cursor].data > 1 then
                    if args["in"][nodes[cursor].data:sub(2)] ~= nil then
                        text("addi sp, sp, -4\n")
                        text("sw a"..args["in"][nodes[cursor].data:sub(2)]..", 4(sp)\n")
                    elseif vars[nodes[cursor].data:sub(2)] ~= nil then
                        text("addi sp, sp, -4\n")
                        text("sw s"..vars[nodes[cursor].data:sub(2)]..", 4(sp)\n")
                    end
                else
                    text("/* Unknown Function: \""..nodes[cursor].data.."\" */\n")
                end
            end
            cursor = cursor + 1
        end
        return {loopCount,ifCount}
    end

    forEach(astNodes,"function",function(node)
        local localVars = {["_n"]=0}
        forEach(node.data.nodes,"localVars",function(node)
            for _,i in ipairs(node.data) do
                localVars[i] = localVars["_n"]
                localVars["_n"] = localVars["_n"]+1
            end
        end)

        text(".global "..node.data.name..":\n")
        if node.data.params["in"]["_n"] > 0 then
            text("addi sp, sp, "..((node.data.params["in"]["_n"])*4).."\n")
            for key,i in pairs(node.data.params["in"]) do
                if key ~= "_n" then
                    text("lw a"..i..", -"..(i*4).."(sp)\n")
                end
            end
        end
        if localVars["_n"] > 0 then
            text("addi sp, sp, -"..((localVars["_n"])*4).."\n")
            for key,i in pairs(localVars) do
                if key ~= "_n" then
                    text("sw s"..i..", "..(i*4).."(sp)\n")
                end
            end
        end
        text("addi sp, sp, -4\n")
        text("sw ra, 4(sp)\n")
        genCode(node.data.params,localVars,node.data.nodes,0,0)
        text("addi sp, sp, 4\n")
        text("lw ra, 0(sp)\n")
        if localVars["_n"] > 0 then
            text("addi sp, sp, "..((localVars["_n"])*4).."\n")
            for key,i in pairs(localVars) do
                if key ~= "_n" then
                    text("lw s"..i..", -"..(i*4).."(sp)\n")
                end
            end
        end
        if node.data.params["out"]["_n"] > 0 then
            text("addi sp, sp, "..((node.data.params["out"]["_n"])*4).."\n")
            for key,i in pairs(node.data.params["out"]) do
                if key ~= "_n" then
                    text("sw a"..i..", "..(i*4).."(sp)\n")
                end
            end
        end
        text("blr zero, ra\n")
    end)

    return asmCode..".text\n"..sections[1].."\n.rodata\n"..sections[2].."\n.data\n"..sections[3].."\n.bss\n"..sections[4]
end