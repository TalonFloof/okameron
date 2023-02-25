return function(astNodes,wordSize,regCount)
    local sections = {{},{},{},{}}
    local definedFunc = {}
    local functions = {}
    local saved = {}
    local variables = {}
    local strCount = 1
    local loopCount = 1
    local ifCount = 1
    local currentLoop = -1
    local nestedLevel = 0
    local countSaved = false
    local savedCount = -2

    local function text(type,dat)
        if not countSaved then
            table.insert(sections[1],{["type"]=type,["data"]=dat})
        end
    end
    local function rodata(name,bytes)
        if not countSaved then
            table.insert(sections[2],{["name"]=name,["data"]=bytes})
        end
    end
    local function data(str)
        if not countSaved then
            irgenErr(".data segment not implemented!",nil)
            --sections[3] = sections[3] .. str
        end
    end
    local function bss(name,size)
        if not countSaved then
            table.insert(sections[4],{["name"]=name,["size"]=size})
        end
    end

    local function irgenErr(err,node)
        if node == nil then
            io.stderr:write("\x1b[1;31mANONYMOUS IRGEN ERROR - "..err.."\x1b[0m\n")
        else
            io.stderr:write("\x1b[1;31m"..node.line..":"..node.col.." - "..err.."\x1b[0m\n")
        end
        os.exit(3)
    end

    local function ralloc()
        for i=0,(regCount-1) do
            if not saved["s"..i] then
                if countSaved and (i+1) > savedCount then
                    savedCount = i+1
                end
                saved["s"..i] = true
                return "s"..i
            end
        end
        irgenErr("Registers are depleated!")
    end

    local function rfree(reg)
        saved[reg] = nil
    end

    local func = function() end

    local function getVal(arg,reg)
        if arg.type == "call" then
            if functions[arg.data.name] ~= nil then
                functions[arg.data.name](arg.data.nodes,reg)
            else
                irgenErr("Unknown Function: \""..arg.data.name.."\" (Hint: use externFn if its an assembly function)",arg)
            end
        elseif arg.type == "number" then
            text("LoadImm",{reg,arg.data})
        elseif arg.type == "string" then
            local strID = strCount
            local bytes = {}
            for i=1,#arg.data do
                table.insert(bytes,string.byte(string.sub(arg.data,i,i)))
            end
            table.insert(bytes,0)
            rodata("VOSString"..strID,bytes)
            text("LoadAddr",{reg,"VOSString"..strID})
            if not countSaved then
                strCount = strCount + 1
            end
        elseif arg.type == "symbol" then
            if variables[arg.data] then
                text("LoadStack",{reg,variables[arg.data]+(savedCount*wordSize)})
            else
                for i,j in ipairs(curArgs) do
                    if j == arg.data then
                        text("LoadStack",{reg,((i*wordSize)+wordSize)})
                    end
                end
            end
        end
    end

    --[[local function hasNestedFunc(args)
        for _,node in ipairs(args) do
            if node.type == "call" then
                if definedFunc[node.data.name] then
                    return true
                elseif hasNestedFunc(node.data.nodes) then
                    return true
                end
            end
        end
        return false
    end]]

    func = function(name,args,r)
        nestedLevel = nestedLevel + 1
        if nestedLevel > 1 and #args > 0 then
            -- print("WARNING!!! Call \""..name.."\" has a nested function. This is currently broken, so proceed with caution...")
            for i=1,#args do
                text("StoreStack",{"a"..(i-1),((1-i)*wordSize)})
            end
        end
        for i,j in ipairs(args) do
            getVal(j,"a"..(i-1))
        end
        if nestedLevel > 1 and #args > 0 then
            text("AddImm",{"sp",-(#args*wordSize)})
        end
        text("LinkedBranch",name)
        if r ~= nil then
            text("MovReg",{r,"a0"})
        end
        if nestedLevel > 1 and #args > 0 then
            text("AddImm",{"sp",(#args*wordSize)})
            for i=1,#args do
                text("LoadStack",{"a"..(i-1),((1-i)*wordSize)})
            end
        end
        nestedLevel = nestedLevel - 1
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
                    text("AddReg",{reg,argR})
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
                    text("SubReg",{reg,argR})
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
                    text("Mul",{reg,argR})
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
                    text("MulUnsign",{reg,argR})
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
                    text("Div",{reg,argR})
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
                    text("DivUnsign",{reg,argR})
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
                    text("Rem",{reg,argR})
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
                    text("RemUnsign",{reg,argR})
                end
            end
        end,
        ["!"] = function(args,reg)
            getVal(args[1],reg)
            text("NotReg",reg)
        end,
        ["&"] = function(args,reg)
            for i,arg in ipairs(args) do
                if i == 1 then
                    getVal(arg,reg)
                else
                    local argR = ralloc()
                    getVal(arg,argR)
                    rfree(argR)
                    text("AndReg",{reg,argR})
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
                    text("OrReg",{reg,argR})
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
                    text("XorReg",{reg,argR})
                end
            end
        end,
        ["<<"] = function(args,reg)
            getVal(args[1],reg)
            local val = ralloc()
            getVal(args[2],val)
            rfree(val)
            text("SllReg",{reg,val})
        end,
        [">>"] = function(args,reg)
            getVal(args[1],reg)
            local val = ralloc()
            getVal(args[2],val)
            rfree(val)
            text("SrlReg",{reg,val})
        end,
        ["s>>"] = function(args,reg)
            getVal(args[1],reg)
            local val = ralloc()
            getVal(args[2],val)
            rfree(val)
            text("SraReg",{reg,val})
        end,
        ["<"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("SltReg",{reg,reg,r})
        end,
        ["u<"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("SltUnReg",{reg,reg,r})
        end,
        [">"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("SltReg",{reg,r,reg})
        end,
        ["u>"] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("SltUnReg",{reg,r,reg})
        end,
        ["=="] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("EqualReg",{reg,r})
        end,
        ["!="] = function(args,reg)
            getVal(args[1],reg)
            local r = ralloc()
            getVal(args[2],r)
            rfree(r)
            text("NotEqualReg",{reg,r})
        end,
        ["b!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            getVal(args[2],val)
            rfree(addr)
            rfree(val)
            text("StoreByte",{val,addr})
        end,
        ["b@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("LoadByte",{reg,addr})
        end,
        ["sb@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("LoadByteSigned",{reg,addr})
        end,
        ["h!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            getVal(args[2],val)
            rfree(addr)
            rfree(val)
            text("StoreHalf",{val,addr})
        end,
        ["h@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("LoadHalf",{reg,addr})
        end,
        ["sh@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("LoadHalfSigned",{reg,addr})
        end,
        ["w!"] = function(args)
            local addr = ralloc()
            getVal(args[1],addr)
            local val = ralloc()
            getVal(args[2],val)
            rfree(addr)
            rfree(val)
            text("StoreWord",{val,addr})
        end,
        ["w@"] = function(args,reg)
            local addr = ralloc()
            getVal(args[1],addr)
            rfree(addr)
            text("LoadWord",{reg,addr})
        end,
        ["while"] = function(args)
            local previous = currentLoop
            local loopID = loopCount
            currentLoop = loopID
            if not countSaved then
                loopCount = loopCount + 1
            end
            text("LocalLabel",".VOSLoop"..loopID)
            local condition = ralloc()
            getVal(args[1],condition)
            text("BranchIfZero",{condition,".VOSLoopAfter"..loopID})
            rfree(condition)
            for index=2,#args do
                getVal(args[index],nil)
            end
            text("Branch",".VOSLoop"..loopID)
            text("LocalLabel",".VOSLoopAfter"..loopID)
            currentLoop = previous
        end,
        ["break"] = function(args)
            if currentLoop == -1 then
                irgenErr("Break in non-loop scope",nil)
            else
                text("Branch",".VOSLoopAfter"..currentLoop)
            end
        end,
        ["do"] = function(args)
            for _,i in ipairs(args) do
                getVal(i,nil)
            end
        end,
        ["if"] = function(args)
            local ifID = ifCount
            if not countSaved then
                ifCount = ifCount + 1
            end
            local ifs = #args // 2
            for i=1,ifs do
                local condition = ralloc()
                getVal(args[((i-1)*2)+1],condition)
                text("BranchNotZero",{condition,".VOSIf"..ifID.."_"..i})
                rfree(condition)
            end
            if (ifs*2) ~= #args then
                text("Branch",".VOSIfElse"..ifID)
            else
                text("Branch",".VOSIfAfter"..ifID)
            end
            for i=1,ifs do
                text("LocalLabel",".VOSIf"..ifID.."_"..i)
                getVal(args[i*2],nil)
                if ifs > 1 or ((ifs*2) ~= #args) then
                    text("Branch",".VOSIfAfter"..ifID)
                end
            end
            if (ifs*2) ~= #args then -- If this is true, than there's an else statement
                text("LocalLabel",".VOSIfElse"..ifID)
                getVal(args[#args],nil)
            end
            text("LocalLabel",".VOSIfAfter"..ifID)
        end,
        ["return"] = function(args)
            if args[1] ~= nil then
                local reg = ralloc()
                getVal(args[1],reg)
                rfree(reg)
                text("MovReg",{"a0",reg})
            end
            text("Branch",".ret")
        end,
        ["="] = function(args)
            if variables[args[1].data] ~= nil then
                local reg = ralloc()
                getVal(args[2],reg)
                rfree(reg)
                text("StoreStack",{reg,(variables[args[1].data]+(savedCount*wordSize))})
                return
            else
                for i,j in ipairs(curArgs) do
                    if j == args[1].data then
                        local reg = ralloc()
                        getVal(args[2],reg)
                        rfree(reg)
                        text("StoreStack",{reg,((i*wordSize)+wordSize)})
                        return
                    end
                end
            end
            irgenErr("Unknown Variable: "..args[1].data.."!",args[1])
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
        bss(node.data.name,node.data.size)
        functions[node.data.name] = function(args,r)
            text("LoadAddr",{r,node.data.name})
        end
    end)

    forEach(astNodes,"struct",function(node)
        for i,j in ipairs(node.data.entries) do
            functions[node.data.name.."."..j.name] = function(args,r)
                text("LoadImm",{r,j.offset})
            end
        end
    end)

    forEach(astNodes,"constant",function(node)
        functions[node.data.name] = function(args,r)
            text("LoadAddr",{r,node.data.val})
        end
    end)

    forEach(astNodes,"external",function(node)
        functions[node.data.name] = function(args,r)
            text("LoadAddr",{r,node.data.name})
        end
    end)
    
    forEach(astNodes,"constantString",function(node)
        rodata(node.data.name..": ")
        local bytes = {}
        for i=1,#node.data.val do
            table.insert(bytes,string.byte(string.sub(node.data.val,i,i)))
        end
        table.insert(bytes,0)
        rodata(node.data.name,bytes)
        functions[node.data.name] = function(args,r)
            text("LoadAddr",{r,node.data.name})
        end
    end)

    forEach(astNodes,"externalFn",function(node)
        for _,fn in ipairs(node.data.functions) do
            definedFunc[fn] = true
            functions[fn] = function(args,r) func(fn,args,r) end
        end
    end)

    forEach(astNodes,"function",function(node)
        definedFunc[node.data.name] = true
        functions[node.data.name] = function(args,r) func(node.data.name,args,r) end
    end)

    forEach(astNodes,"function",function(node)
        curArgs = node.data.args
        fnSaved = 0
        text("FunctionLabel",node.data.name)
        variables = {["_n"]=0}
        local argSize = #curArgs*wordSize
        for _,i in ipairs(node.data.nodes) do
            if i.data.name == "int" then
                for _,varName in ipairs(i.data.nodes) do
                    variables[varName.data] = (variables["_n"]*wordSize)+(argSize+(wordSize*2))
                    variables["_n"] = variables["_n"] + 1
                end
            end
        end
        local varSize = variables["_n"]*wordSize
        variables["_n"] = nil
        -- Get Saved Register Count
        countSaved = true
        for _,i in pairs(node.data.nodes) do
            if i.data.name ~= "int" then
                getVal(i,nil)
            end
        end
        countSaved = false
        text("AddImm",{"sp",-(varSize+argSize+(savedCount*wordSize)+wordSize)})
        text("SaveRet",nil) -- Some architectures already have it in the stack so yeah
        for i=1,#curArgs do
            text("StoreStack",{"a"..(i-1),((i*wordSize)+wordSize)})
        end
        for i=1,savedCount do
            text("StoreStack",{"s"..(i-1),((i*wordSize)+wordSize+argSize)})
        end
        for _,i in pairs(node.data.nodes) do
            if i.data.name ~= "int" then
                getVal(i,nil)
            end
        end
        text("LocalLabel",".ret")
        for i=1,savedCount do
            text("LoadStack",{"s"..(i-1),((i*wordSize)+wordSize+argSize)})
        end
        text("LoadRet",nil)
        text("AddImm",{"sp",(varSize+argSize+(savedCount*wordSize)+wordSize)})
        text("Return",nil)
        allocated = {}
    end)

    return sections
end
