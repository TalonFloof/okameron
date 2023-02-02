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
    local loopCount = 1
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
            end
        elseif arg.type == "number" then
            text("    la "..reg..", "..arg.data.."\n")
        elseif arg.type == "symbol" then
            for i,j in ipairs(curArgs) do
                if j == arg.data then
                    text("    add "..reg..", a"..(i-1)..", zero\n")
                end
            end
        end
    end

    functions = {
        ["+"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    add "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["-"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    sub "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["*"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    mul "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["u*"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    mulu "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["/"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    div "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["u/"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    divu "..reg..", zero, "..reg..", "..argR.."\n")
                end
            end
        end,
        ["%"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    div zero, "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["u%"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
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
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    and "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["|"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    or "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["^"] = function(args,reg)
            for i,arg in ipairs(args) do
                local argR = ralloc()
                getVal(arg,argR)
                rfree(argR)
                if i == 1 then
                    text("    add "..reg..", zero, "..argR.."\n")
                else
                    text("    xor "..reg..", "..reg..", "..argR.."\n")
                end
            end
        end,
        ["<"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            rfree(reg)
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
        ["w!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            rfree(addr)
            getVal(args[2],val)
            rfree(val)
            text("    sw "..val..", 0("..addr..")\n")
        end,
        ["w@"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            rfree(addr)
            getVal(args[2],val)
            rfree(val)
            text("    lw "..val..", 0("..addr..")\n")
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
                local i = args[index]
                if functions[i.data.name] ~= nil then
                    functions[i.data.name](i.data.nodes)
                end
            end
            text("    b .VOSLoop"..loopID.."\n")
            text(".VOSLoopAfter"..loopID..":\n")
        end,
        ["return"] = function(args)
            if args[1] ~= nil then
                local reg = ralloc()
                getVal(args[1],reg)
                rfree(reg)
                text("    add a0, zero, "..reg.."\n")
            end
            text("    b .ret\n")
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
        functions[node.data.name] = function(args,r)
            text("    la "..r..", "..node.data.val.."\n")
        end
    end)

    local strCount = 0

    forEach(astNodes,"function",function(node)
        functions[node.data.name] = function(args,r)
            text("    bl "..node.data.name.."\n")
            if r ~= nil then
                text("    add "..r..", a0, zero\n")
            end
        end
    end)

    forEach(astNodes,"function",function(node)
        curArgs = node.data.args
        text(".global "..node.data.name..":\n")
        variables = {}
        for _,i in ipairs(node.data.nodes) do
            if functions[i.data.name] == "auto" then
                for _,varName in ipairs(i.data.nodes) do
                    print(varName)
                end
                saved["_n"] = saved["_n"] + 1
            end
        end
        saved["_n"] = nil
        for _,i in pairs(node.data.nodes) do
            if functions[i.data.name] ~= nil and functions[i.data.name] ~= "auto" then
                functions[i.data.name](i.data.nodes)
            end
        end
        text(".ret:\n")
        text("    blr zero, ra\n")
        allocated = {}
    end)

    return asmCode..".text\n"..sections[1].."\n.rodata\n"..sections[2].."\n.data\n"..sections[3].."\n.bss\n"..sections[4]
end