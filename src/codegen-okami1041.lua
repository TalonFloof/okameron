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
            text("lw t1, -4(sp)\n")
            text("add t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["-"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("sub t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["*"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("mul t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u*"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("mulu t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["/"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("div t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u/"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("divu t0, zero, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["%"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("div zero, t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u%"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("divu zero, t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["/%"]=function()
            text("lw t0, -4(sp)\n")
            text("lw t1, -8(sp)\n")
            text("div t0, t1, t0, t1\n")
            text("sw t0, -4(sp)\n")
            text("sw t1, -8(sp)\n")
        end,
        ["u/%"]=function()
            text("lw t0, -4(sp)\n")
            text("lw t1, -8(sp)\n")
            text("divu t0, t1, t0, t1\n")
            text("sw t0, -4(sp)\n")
            text("sw t1, -8(sp)\n")
        end,
        ["!"]=function()
            text("lw t0, -4(sp)\n")
            text("la t1, 0xffffffff")
            text("xor t0, t0, t1\n")
            text("sw t0, -4(sp)\n")
        end,
        ["&"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("and t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["|"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("or t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["^"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("xor t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["<"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("slt t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        [">"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("slt t0, t1, t0\n")
            text("sw t0, 0(sp)\n")
        end,
        ["="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("sub t0, t0, t1\n")
            text("sltiu t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["!="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("sub t0, t0, t1\n")
            text("sltu t0, zero, t0\n")
            text("sw t0, 0(sp)\n")
        end,
        [">="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("slt t0, t0, t1\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["<="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("slt t0, t1, t0\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u<"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("sltu t0, t0, t1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u>"]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("sltu t0, t1, t0\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u>="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
            text("sltu t0, t0, t1\n")
            text("xori t0, t0, 1\n")
            text("sw t0, 0(sp)\n")
        end,
        ["u<="]=function()
            text("addi sp, sp, 4\n")
            text("lw t0, 0(sp)\n")
            text("lw t1, -4(sp)\n")
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
            text("sw t0, -4(sp)\n")
        end,
        ["dup"]=function()
            text("lw t0, -4(sp)\n")
            text("addi sp, sp, -4\n")
            text("sw t0, -4(sp)\n")
        end,
        ["swap"]=function()
            text("lw t0, -4(sp)\n")
            text("lw t1, -8(sp)\n")
            text("sw t0, -8(sp)\n")
            text("sw t1, -4(sp)\n")
        end,
        ["rot"]=function()
            text("lw t0, -4(sp)\n")
            text("lw t1, -8(sp)\n")
            text("lw t2, -12(sp)\n")
            text("sw t0, -8(sp)\n")
            text("sw t1, -12(sp)\n")
            text("sw t2, -4(sp)\n")
        end,
        ["over"]=function()
            text("lw t0, -8(sp)\n")
            text("addi sp, sp, -4\n")
            text("sw t0, -4(sp)\n")
        end,
        ["@"]=function()
            text("lw t0, -4(sp)\n")
            text("lw t1, 0(t0)\n")
            text("sw t1, -4(sp)\n")
        end,
        ["!"]=function()
            text("lw t0, -8(sp)\n")
            text("lw t1, -4(sp)\n")
            text("addi sp, sp, 8\n")
            text("sw t0, 0(t1)\n")
        end,
        ["b@"]=function()
            text("lw t0, -4(sp)\n")
            text("lbu t1, 0(t0)\n")
            text("sw t1, -4(sp)\n")
        end,
        ["sb@"]=function()
            text("lw t0, -4(sp)\n")
            text("lb t1, 0(t0)\n")
            text("sw t1, -4(sp)\n")
        end,
        ["b!"]=function()
            text("lw t0, -8(sp)\n")
            text("lw t1, -4(sp)\n")
            text("addi sp, sp, 8\n")
            text("sb t0, 0(t1)\n")
        end,
        ["h@"]=function()
            text("lw t0, -4(sp)\n")
            text("lhu t1, 0(t0)\n")
            text("sw t1, -4(sp)\n")
        end,
        ["sh@"]=function()
            text("lw t0, -4(sp)\n")
            text("lh t1, 0(t0)\n")
            text("sw t1, -4(sp)\n")
        end,
        ["h!"]=function()
            text("lw t0, -8(sp)\n")
            text("lw t1, -4(sp)\n")
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
            text("b "..node.data.name.."\n")
        end
    end)

    local function genCode(nodes,baseLoop,baseIf)
        local cursor = 1
        local loopCount = 0
        local ifCount = 0
        while cursor <= #nodes.data.nodes do
            if nodes.data.nodes[cursor].type == "pushNumber" then
                text("la t0, "..nodes.data.nodes[cursor].data.."\n")
                text("sw t0, 0(sp)\n")
                text("addi sp, sp, -4\n")
            elseif nodes.data.nodes[cursor].type == "pushString" then
                rodata("_VOSString"..strCount..": ")
                for i=1,#nodes.data.nodes[cursor].data do
                    rodata(".byte "..nodes.data.nodes[cursor].data:sub(i,i):byte().." ")
                end
                rodata(".byte 0\n")
                text("la t0, _VOSString"..strCount.."\n")
                text("sw t0, 0(sp)\n")
                text("addi sp, sp, -4\n")
                strCount = strCount + 1
            elseif nodes.data.nodes[cursor].type == "loop" then
                nodes.data.nodes[cursor].data.condition
            elseif nodes.data.nodes[cursor].type == "functionCall" then
                if functions[nodes.data.nodes[cursor].data] ~= nil then
                    functions[nodes.data.nodes[cursor].data]()
                end
            end
            cursor = cursor + 1
        end
        return {loopCount,ifCount}
    end

    forEach(astNodes,"function",function(node)
        text(".global "..node.data.name..":\n")
        local localVarCount = 0
        local loopCount = 0
        local ifCount = 0
    end)

    return asmCode..".text\n"..sections[1].."\n.rodata\n"..sections[2].."\n.data\n"..sections[3].."\n.bss\n"..sections[4]
end