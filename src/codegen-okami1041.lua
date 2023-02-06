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

    local functions = {}
    local allocated = {}
    local saved = {}
    local variables = {}
    local strCount = 1
    local loopCount = 1
    local ifCount = 1
    local seenTempWarn = false

    local function ralloc()
        for i=0,7 do
            if not allocated["t"..i] then
                allocated["t"..i] = true
                return "t"..i
            end
        end
        if not seenTempWarn then
            print("\x1b[1;33mWarning: Saved Registers have been allocated, concider simplifying your code.\x1b[0m")
            seenTempWarn = true
        end
        for i=0,9 do
            if not saved["s"..i] then
                saved["s"..i] = true
                return "s"..i
            end
        end
        error("All registers are depleated!")
    end

    local function rfree(reg)
        if reg:sub(1,1) == "s" then
            saved[reg] = nil
        else
            allocated[reg] = nil
        end
    end

    local function getVal(arg,reg)
        if arg.type == "call" then
            if functions[arg.data.name] ~= nil then
                functions[arg.data.name](arg.data.nodes,reg)
            else
                text("    /* Calling External Symbol: "..arg.data.name.." */\n")
                for i,j in ipairs(arg.data.nodes) do
                    getVal(j,"a"..(i-1))
                end
                text("    bl "..arg.data.name.."\n")
                if r ~= nil then
                    text("    add "..reg..", a0, zero\n")
                end
            end
        elseif arg.type == "number" then
            if (arg.data & 0xFFFF0000) == 0 then
                text("    li "..reg..", "..(arg.data).."\n")
            elseif (arg.data & 0xFFFF) == 0 then
                text("    lui "..reg..", "..(arg.data >> 16).."\n")
            else
                text("    la "..reg..", "..arg.data.."\n")
            end
        elseif arg.type == "string" then
            local strID = strCount
            rodata("_VOSString"..strID..": ")
            for i=1,#arg.data do
                rodata(".byte "..string.byte(string.sub(arg.data,i,i)).." ")
            end
            rodata(".byte 0\n")
            text("    la "..reg..", _VOSString"..strID.."\n")
            strCount = strCount + 1
        elseif arg.type == "symbol" then
            if variables[arg.data] then
                text("    lw "..reg..", "..variables[arg.data].."(sp)\n")
            else
                for i,j in ipairs(curArgs) do
                    if j == arg.data then
                        text("    lw "..reg..", "..((i*4)+4).."(sp)\n")
                    end
                end
            end
        end
    end

    functions = {
        ["+"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    add "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["-"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    sub "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["*"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    mul "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["u*"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    mulu "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["/"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    div "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["u/"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    divu "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["%"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    div zero, "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["u%"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    divu zero, "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["!"] = function(args,reg)
            getVal(args[1],reg)
            local temp = ralloc()
            rfree(temp)
            text("    addi "..temp..", zero, -1\n")
            text("    xor "..reg..", "..reg..", "..temp.."\n")
        end,
        ["&"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    and "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["|"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    or "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["^"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("    xor "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["<<"] = function(args,reg)
            getVal(args[1],reg)
            local val = ralloc()
            getVal(args[2],val)
            rfree(val)
            text("    sll "..reg..", "..reg..", "..val.."\n")
        end,
        [">>"] = function(args,reg)
            getVal(args[1],reg)
            local val = ralloc()
            getVal(args[2],val)
            rfree(val)
            text("    srl "..reg..", "..reg..", "..val.."\n")
        end,
        ["s>>"] = function(args,reg)
            getVal(args[1],reg)
            local val = ralloc()
            getVal(args[2],val)
            rfree(val)
            text("    sra "..reg..", "..reg..", "..val.."\n")
        end,
        ["<"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("    slt "..reg..", "..reg..", "..r.."\n")
        end,
        ["u<"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("    sltu "..reg..", "..reg..", "..r.."\n")
        end,
        [">"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("    slt "..reg..", "..r..", "..reg.."\n")
        end,
        ["u>"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("    sltu "..reg..", "..r..", "..reg.."\n")
        end,
        ["=="] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("    sub "..reg..", "..reg..", "..r.."\n")
            text("    sltiu "..reg..", "..reg..", 1\n")
        end,
        ["!="] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("    sub "..reg..", "..reg..", "..r.."\n")
            text("    sltu "..reg..", zero, "..reg.."\n")
        end,
        ["b!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            rfree(addr)
            getVal(args[2],val)
            rfree(val)
            text("    sb "..val..", 0("..addr..")\n")
        end,
        ["b@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("    lbu "..reg..", 0("..addr..")\n")
        end,
        ["sb@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("    lb "..reg..", 0("..addr..")\n")
        end,
        ["h!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            rfree(addr)
            getVal(args[2],val)
            rfree(val)
            text("    sh "..val..", 0("..addr..")\n")
        end,
        ["h@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("    lhu "..reg..", 0("..addr..")\n")
        end,
        ["sh@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("    lh "..reg..", 0("..addr..")\n")
        end,
        ["w!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            rfree(addr)
            getVal(args[2],val)
            rfree(val)
            text("    sw "..val..", 0("..addr..")\n")
        end,
        ["w@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("    lw "..reg..", 0("..addr..")\n")
        end,
        ["while"] = function(args)
            local loopID = loopCount
            loopCount = loopCount + 1
            text(".VOSLoop"..loopID..":\n")
            local condition = ralloc()
            getVal(args[1],condition)
            text("    beq "..condition..", zero, .VOSLoopAfter"..loopID.."\n")
            rfree(condition)
            for index=2,#args do
                getVal(args[index],nil)
            end
            text("    b .VOSLoop"..loopID.."\n")
            text(".VOSLoopAfter"..loopID..":\n")
        end,
        ["do"] = function(args)
            for _,i in ipairs(args) do
                getVal(i,nil)
            end
        end,
        ["if"] = function(args)
            local ifID = ifCount
            ifCount = ifCount + 1
            local ifs = #args // 2
            for i=1,ifs do
                local condition = ralloc()
                getVal(args[i],condition)
                text("    bne "..condition..", zero, .VOSIf"..ifID.."_"..i.."\n")
                rfree(condition)
            end
            if (ifs*2) ~= #args then
                text("    b .VOSIfElse"..ifID.."\n")
            else
                text("    b .VOSIfAfter"..ifID.."\n")
            end
            for i=1,ifs do
                text(".VOSIf"..ifID.."_"..i..":\n")
                getVal(args[i*2],nil)
            end
            if (ifs*2) ~= #args then -- If this is true, than there's an else statement
                text(".VOSIfElse"..ifID..":\n")
                getVal(args[#args],nil)
            end
            text(".VOSIfAfter"..ifID..":\n")
        end,
        ["return"] = function(args)
            if args[1] ~= nil then
                local reg = ralloc()
                getVal(args[1],reg)
                rfree(reg)
                text("    add a0, zero, "..reg.."\n")
            end
            text("    b .ret\n")
        end,
        ["="] = function(args)
            if variables[args[1].data] ~= nil then
                local reg = ralloc()
                getVal(args[2],reg)
                rfree(reg)
                text("    sw "..reg..", "..variables[args[1].data].."(sp)\n")
            end
        end
    }

    local function forEach(nodes,nodeType,fn)
        for _,i in ipairs(nodes) do
            if i.type == nodeType then
                fn(i)
            end
        end
    end

    forEach(astNodes,"globalVar",function(node)
        bss(node.data.name..": .resb "..node.data.size.."\n")
        functions[node.data.name] = function(args,r)
            text("    la "..r..", "..node.data.name.."\n")
        end
    end)

    forEach(astNodes,"struct",function(node)
        for i,j in ipairs(node.data.entries) do
            functions[node.data.name.."."..j.name] = function(args,r)
                text("    li "..r..", "..j.offset.."\n")
            end
        end
    end)

    forEach(astNodes,"constant",function(node)
        functions[node.data.name] = function(args,r)
            text("    la "..r..", "..node.data.val.."\n")
        end
    end)

    forEach(astNodes,"external",function(node)
        functions[node.data.name] = function(args,r)
            text("    la "..r..", "..node.data.name.."\n")
        end
    end)
    
    forEach(astNodes,"constantString",function(node)
        rodata(node.data.name..": ")
        for i=1,#node.data.val do
            rodata(".byte "..string.byte(string.sub(node.data.val,i,i)).." ")
        end
        rodata(".byte 0\n")
        functions[node.data.name] = function(args,r)
            text("    la "..r..", "..node.data.name.."\n")
        end
    end)

    local strCount = 0

    forEach(astNodes,"function",function(node)
        functions[node.data.name] = function(args,r)
            for i,j in ipairs(args) do
                getVal(args[i],"a"..(i-1))
            end
            text("    bl "..node.data.name.."\n")
            if r ~= nil then
                text("    add "..r..", a0, zero\n")
            end
        end
    end)

    forEach(astNodes,"function",function(node)
        curArgs = node.data.args
        text(".global "..node.data.name..":\n")
        variables = {["_n"]=0}
        local argSize = #curArgs*4
        for _,i in ipairs(node.data.nodes) do
            if i.data.name == "int" or i.data.name == "long" then
                for _,varName in ipairs(i.data.nodes) do
                    variables[varName.data] = (variables["_n"]*4)+(argSize+8)
                    variables["_n"] = variables["_n"] + 1
                end
            end
        end
        local varSize = variables["_n"]*4
        text("    addi sp, sp, -"..(varSize+argSize+4).."\n")
        text("    sw ra, 4(sp)\n")
        for i=1,#curArgs do
            text("    sw a"..(i-1)..", "..((i*4)+4).."(sp)\n")
        end
        variables["_n"] = nil
        for _,i in pairs(node.data.nodes) do
            if i.data.name ~= "int" and i.data.name ~= "long" then
                getVal(i,nil)
            end
        end
        text(".ret:\n")
        text("    lw ra, 4(sp)\n")
        text("    addi sp, sp, "..(varSize+argSize+4).."\n")
        text("    blr zero, ra\n")
        allocated = {}
    end)

    return asmCode..".text\n"..sections[1].."\n.rodata\n"..sections[2].."\n.data\n"..sections[3].."\n.bss\n"..sections[4]
end
