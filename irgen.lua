-- Sign of an expression is determined using the first value

return function(tree,wordSize)
    local ircode = {{},{},{}}
    local savedReg = {}
    local ifCount = 0
    local whileCount = 0
    local currentLoop = 0
    local strings = {}
    local strCount = 0
    local lastSym = nil
    local lastType = nil
    local indexSize = -1
    local function ralloc()
        local i = 0
        while true do
            if not savedReg[i] then
                savedReg[i] = true
                return {"saved",i}
            end
            i = i + 1
        end
    end
    local function rfree(r)
        savedReg[r[2]] = false
    end
    
    local function text(...)
        table.insert(ircode[1],table.pack(...))
    end

    local function rodata(name,typ,dat)
        table.insert(ircode[2],{name,typ,dat})
    end

    local function bss(name,size)
        table.insert(ircode[3],{name,size})
    end

    local function irgenErr(modname,err)
        io.stderr:write("\x1b[1;31mModule("..modname..") - "..err.."\x1b[0m\n")
        os.exit(4)
    end
    local function getProcVars(proc)
        local t = {}
        for _,i in ipairs(proc[3]) do
            table.insert(t,{"var",table.unpack(i,1,#i)})
        end
        for _,i in ipairs(proc[5]) do
            table.insert(t,i)
        end
        return t
    end
    local function findModule(name)
        for _,i in ipairs(tree) do
            if i[1] == "module" and i[2] == name then
                return i
            end
        end
        irgenErr(name,"<-- Attempted to find this nonexistant module")
    end
    local function findProcedure(mod,name)
        for _,i in ipairs(mod[6]) do
            if i[1] == "procedure" and i[2] == name then
                return i
            end
        end
        for _,i in ipairs(mod[5]) do
            if i[1] == "extern" and i[2] then
                for j=3,#i do
                    if i[j][1] == name then
                        return {"extern",table.unpack(i[j])}
                    end
                end
            end
        end
        return nil
    end
    local function getProcedure(mod,imports,name)
        local tab = {table.unpack(imports)}
        table.insert(tab,mod[2])
        for _,i in ipairs(tab) do
            local val = findProcedure(findModule(i),name)
            if val ~= nil then
                return val
            end
        end
        irgenErr(mod[2],"Undefined Procedure \""..name.."\" (hint: use IMPORT to use procedures from other modules)")
    end
    local function hasProcedure(mod,imports,name)
        local tab = {table.unpack(imports)}
        table.insert(tab,mod[2])
        for _,i in ipairs(tab) do
            local val = findProcedure(findModule(i),name)
            if val ~= nil then
                return true
            end
        end
        return false
    end
    local function getType(mod,imports,typ)
        local tab = {table.unpack(imports)}
        table.insert(tab,mod[2])
        for _,i in ipairs(tab) do
            local m = findModule(i)
            for _,j in ipairs(m[4]) do
                if j[1] == typ then
                    return j[2]
                end
            end
        end
        irgenErr(mod[2],"Undefined Type \""..typ.."\" (hint: use IMPORT to use types from other modules)")
    end
    local function getConst(mod,imports,name)
        local tab = {table.unpack(imports)}
        table.insert(tab,mod[2])
        for _,i in ipairs(tab) do
            local m = findModule(i)
            for _,j in ipairs(m[5]) do
                if j[1] == "const" and j[2] == name then
                    return j[3][2]
                end
            end
        end
        irgenErr(mod[2],"Undefined Constant \""..name.."\" (hint: use IMPORT to use constants from other modules)")
    end
    local function getVarType(mod,imports,loc,var)
        for _,i in ipairs(loc) do
            if i[2] == var then
                local ret = i[3]
                while ret[1] == "customType" do ret = getType(mod,imports,ret[2]) end
                return ret
            end
        end
        local tab = {table.unpack(imports)}
        table.insert(tab,mod[2])
        for _,i in ipairs(tab) do
            local m = findModule(i)
            for _,j in ipairs(m[5]) do
                if j[1] == "var" and j[2] == var then
                    local ret = j[3]
                    while ret[1] == "customType" do ret = getType(mod,imports,ret[2]) end
                    return ret
                elseif j[1] == "extern" and not j[2] then
                    for k=3,#j do
                        if j[k][1] == var then
                            local ret = j[k][2]
                            while ret[1] == "customType" do ret = getType(mod,imports,ret[2]) end
                            return ret
                        end
                    end
                elseif j[1] == "const" and j[2] == var then
                    if j[3][1] == "set" then
                        return {"array",#j[3]-1,{"numType",wordSize}}
                    else
                        return {"constant"}
                    end
                end
            end
        end
        irgenErr(mod[2],"Undefined Variable/Constant \""..var.."\" whilst getting its type (hint: use IMPORT to use variables and constants from other modules)")
    end
    local function getLoadType(typ)
        if typ[1] == "numType" then
            if typ[2] == 1 then return "LoadByte"
            elseif typ[2] == 2 then return "LoadHalf"
            elseif typ[2] == 4 then return "Load"
            else return "LoadLong" end
        elseif typ[1] == "ptrOf" then
            return "Load"
        end
    end
    local function assertGlobalVar(mod,imports,name)
        local tab = {table.unpack(imports)}
        table.insert(tab,mod[2])
        for _,i in ipairs(tab) do
            local m = findModule(i)
            for _,j in ipairs(m[5]) do
                if (j[1] == "var" or j[1] == "const") and j[2] == name then
                    return
                elseif j[1] == "extern" and not j[2] then
                    for k=3,#j do
                        if j[k][1] == name then
                            return
                        end
                    end
                end
            end
        end
        irgenErr(mod[2],"Undefined Variable/Constant \""..name.."\" (hint: use IMPORT to use variables and constants from other modules)")
    end
    local function getSize(mod,imports,typ)
        if typ[1] == "numType" then
            return typ[2]
        elseif typ[1] == "ptrOf" then
            return wordSize
        elseif typ[1] == "array" then
            if type(typ[2]) == "string" then
                return getConst(mod,imports,typ[2])*getSize(mod,imports,typ[3])
            else
                return typ[2]*getSize(mod,imports,typ[3])
            end
        elseif typ[1] == "record" then
            local offset = 0
            for i,j in ipairs(typ) do
                if i ~= 1 then
                    local s = getSize(mod,imports,j[2])
                    if (offset % math.min(s,wordSize)) > 0 then
                        offset = (offset + (math.min(s,wordSize)-(offset % math.min(s,wordSize)))) + s
                    else
                        offset = offset + s
                    end
                end
            end
            return offset
        elseif typ[1] == "set" then
            return (#typ-1)*wordSize
        elseif typ[1] == "customType" then
            return getSize(mod,imports,getType(mod,imports,typ[2]))
        end
        irgenErr(mod[2],"Bad Type Record: "..serialize_list(typ))
    end
    local function getRecOffset(mod,imports,typ,val)
        if typ[1] ~= "record" then
            irgenErr(mod[2],"Given type \""..typ[1].."\" is not a record!")
        end
        local offset = 0
        for i,j in ipairs(typ) do
            if i ~= 1 then
                if j[1] == val[2] then
                    local s = getSize(mod,imports,j[2])
                    if (offset % math.min(s,wordSize)) > 0 then
                        offset = (offset + (math.min(s,wordSize)-(offset % math.min(s,wordSize))))
                    end
                    return offset
                else
                    local s = getSize(mod,imports,j[2])
                    if (offset % math.min(s,wordSize)) > 0 then
                        offset = (offset + (math.min(s,wordSize)-(offset % math.min(s,wordSize)))) + s
                    else
                        offset = offset + s
                    end
                end
            end
        end
        irgenErr(mod[2],"Undefined Value \""..val[2].."\" in record \""..typ[1].."\"")
    end
    local function evaluate(mod,proc,varSpace,val,reg,getAddr)
        if val[1] == ":=" then
            if val[2][1] == "symbol" and varSpace[val[2][2]] ~= nil then
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                local typ = getVarType(mod,mod[3],getProcVars(proc),val[2][2]);
                if typ[1] == "numType" and typ[2] == 1 then text("StoreByte",r,varSpace[val[2][2]],{"frame"})
                elseif typ[1] == "numType" and typ[2] == 2 then text("StoreHalf",r,varSpace[val[2][2]],{"frame"})
                elseif typ[1] == "numType" and typ[2] == 4 then text("Store",r,varSpace[val[2][2]],{"frame"})
                else
                    text("StoreLong",r,varSpace[val[2][2]],{"frame"})
                end
            else
                local r1 = ralloc()
                evaluate(mod,proc,varSpace,val[3],r1)
                local r2 = ralloc()
                evaluate(mod,proc,varSpace,val[2],r2,true)
                rfree(r2)
                rfree(r1)
                if indexSize ~= -1 then
                    if indexSize > wordSize then
                        irgenErr(mod[2],"Cannot assign an element to a value greater than the size of our target's word size!")
                    elseif indexSize == 8 then
                        text("StoreLong",r1,0,r2)
                    elseif indexSize == 4 then
                        text("Store",r1,0,r2)
                    elseif indexSize == 2 then
                        text("StoreHalf",r1,0,r2)
                    elseif indexSize == 1 then
                        text("StoreByte",r1,0,r2)
                    end
                    indexSize = -1
                    return
                end
                if lastType[1] == "numType" and lastType[2] == 1 then text("StoreByte",r1,0,r2)
                elseif lastType[1] == "numType" and lastType[2] == 2 then text("StoreHalf",r1,0,r2)
                elseif lastType[1] == "numType" and lastType[2] == 4 then text("Store",r1,0,r2)
                else
                    text("StoreLong",r1,0,r2)
                end
            end
        elseif val[1] == "call" then
            if val[2] == "PTROF" then
                if val[3][1] == "symbol" and hasProcedure(mod,mod[3],val[3][2]) then
                    text("LoadAddr",reg,val[3][2])
                else
                    evaluate(mod,proc,varSpace,val[3],reg,true)
                end
            elseif val[2] == "LSH" then
                evaluate(mod,proc,varSpace,val[3],reg)
                if val[4][1] == "number" then
                    text("Lsh",reg,val[4])
                else
                    local r = ralloc()
                    evaluate(mod,proc,varSpace,val[4],r)
                    rfree(r)
                    text("Lsh",reg,r)
                end
            elseif val[2] == "RSH" then
                evaluate(mod,proc,varSpace,val[3],reg)
                if val[4][1] == "number" then
                    text("Rsh",reg,val[4])
                else
                    local r = ralloc()
                    evaluate(mod,proc,varSpace,val[4],r)
                    rfree(r)
                    text("Rsh",reg,r)
                end
            elseif val[2] == "ASH" then
                evaluate(mod,proc,varSpace,val[3],reg)
                if val[4][1] == "number" then
                    text("Ash",reg,val[4])
                else
                    local r = ralloc()
                    evaluate(mod,proc,varSpace,val[4],r)
                    rfree(r)
                    text("Ash",reg,r)
                end
            elseif val[2] == "PUTCHAR" then
                local r1 = ralloc()
                local r2 = ralloc()
                evaluate(mod,proc,varSpace,val[3],r2)
                evaluate(mod,proc,varSpace,val[4],r1)
                rfree(r1)
                rfree(r2)
                text("StoreByte",r1,0,r2)
            elseif val[2] == "PUTSHORT" then
                local r1 = ralloc()
                local r2 = ralloc()
                evaluate(mod,proc,varSpace,val[3],r2)
                evaluate(mod,proc,varSpace,val[4],r1)
                rfree(r1)
                rfree(r2)
                text("StoreHalf",r1,0,r2)
            elseif val[2] == "PUTINT" then
                local r1 = ralloc()
                local r2 = ralloc()
                evaluate(mod,proc,varSpace,val[3],r2)
                evaluate(mod,proc,varSpace,val[4],r1)
                rfree(r1)
                rfree(r2)
                text("Store",r1,0,r2)
            elseif val[2] == "PUTLONG" then
                local r1 = ralloc()
                local r2 = ralloc()
                evaluate(mod,proc,varSpace,val[3],r2)
                evaluate(mod,proc,varSpace,val[4],r1)
                rfree(r1)
                rfree(r2)
                text("StoreLong",r1,0,r2)
            elseif val[2] == "GETCHAR" then
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("LoadByte",reg,0,r)
            elseif val[2] == "GETSHORT" then
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("LoadHalf",reg,0,r)
            elseif val[2] == "GETINT" then
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Load",reg,0,r)
            elseif val[2] == "GETLONG" then
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("LoadLong",reg,0,r)
            elseif val[2] == "RETURN" then
                if val[3] then
                    evaluate(mod,proc,varSpace,val[3],{"arg",0},false)
                end
                text("Branch",".Lret")
            elseif val[2] == "CONTINUE" then
                text("Branch",".Lwhile"..currentLoop)
            elseif val[2] == "BREAK" then
                text("Branch",".Lwhile"..currentLoop.."_after")
            elseif val[2] == "CALL" then
                local args = #val-3
                text("BeginCall",reg,args)
                for i=4,#val do
                    evaluate(mod,proc,varSpace,val[i],{"arg",i-4})
                end
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                if reg then
                    text("EndCall",r,args,reg)
                else
                    text("EndCall",r,args)
                end
            else
                getProcedure(mod,mod[3],val[2])
                text("BeginCall",reg,#val-2)
                local args = #val-2
                for i=1,args do
                    evaluate(mod,proc,varSpace,val[2+i],{"arg",i-1})
                end
                if reg then
                    text("EndCall",val[2],args,reg)
                else
                    text("EndCall",val[2],args)
                end
            end
        elseif val[1] == "if" then
            local id = ifCount
            ifCount = ifCount + 1
            for i=2,#val do
                if val[i][1] ~= "else" then
                    local r = ralloc()
                    evaluate(mod,proc,varSpace,val[i][2],r)
                    text("BranchIfNotZero",r,".Lif"..id.."_"..(i-2))
                    rfree(r)
                end
            end
            if val[#val][1] == "else" then
                text("Branch",".Lif"..id.."_"..(#val-2))
            else
                text("Branch",".Lif"..id.."_after")
            end
            for i=2,#val do
                text("LocalLabel",".Lif"..id.."_"..(i-2))
                for _,arg in ipairs(val[i][3]) do
                    evaluate(mod,proc,varSpace,arg)
                end
                text("Branch",".Lif"..id.."_after")
            end
            text("LocalLabel",".Lif"..id.."_after")
        elseif val[1] == "while" then
            local previous = currentLoop
            local id = whileCount
            currentLoop = id
            whileCount = whileCount + 1
            text("LocalLabel",".Lwhile"..id)
            local r = ralloc()
            evaluate(mod,proc,varSpace,val[2],r)
            rfree(r)
            text("BranchIfZero",r,".Lwhile"..id.."_after")
            for _,arg in ipairs(val[3]) do
                evaluate(mod,proc,varSpace,arg)
            end
            text("Branch",".Lwhile"..id)
            text("LocalLabel",".Lwhile"..id.."_after")
            currentLoop = previous
        elseif val[1] == "+" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Add",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Add",reg,r)
            end
        elseif val[1] == "-" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Sub",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Sub",reg,r)
            end
        elseif val[1] == "*" or val[1] == "*|" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Mul",reg,val[3],val[1] ~= "*|")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Mul",reg,r,val[1] ~= "*|")
            end
        elseif val[1] == "/" or val[1] == "DIV" or val[1] == "/|" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Div",reg,val[3],val[1] ~= "/|")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Div",reg,r,val[1] ~= "/|")
            end
        elseif val[1] == "MOD" or val[1] == "UMOD" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Mod",reg,val[3],val[1] ~= "UMOD")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Mod",reg,r,val[1] ~= "UMOD")
            end
        elseif val[1] == "XOR" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Xor",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Xor",reg,r)
            end
        elseif val[1] == "OR" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Or",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Or",reg,r)
            end
        elseif val[1] == "&" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("And",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("And",reg,r)
            end
        elseif val[1] == "_" then
            evaluate(mod,proc,varSpace,val[2],reg)
            text("Negate",reg)
        elseif val[1] == "=" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Eq",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Eq",reg,r)
            end
        elseif val[1] == "#" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Neq",reg,val[3])
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Neq",reg,r)
            end
        elseif val[1] == ">" or val[1] == ">|" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Gt",reg,val[3],val[1] ~= ">|")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Gt",reg,r,val[1] ~= ">|")
            end
        elseif val[1] == "<" or val[1] == "<|" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Lt",reg,val[3],val[1] ~= "<|")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Lt",reg,r,val[1] ~= "<|")
            end
        elseif val[1] == ">=" or val[1] == ">|=" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Ge",reg,val[3],val[1] ~= ">|=")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Ge",reg,r,val[1] ~= ">|=")
            end
        elseif val[1] == "<=" or val[1] == "<|=" then
            evaluate(mod,proc,varSpace,val[2],reg)
            if val[3][1] == "number" then
                text("Le",reg,val[3],val[1] ~= "<|=")
            else
                local r = ralloc()
                evaluate(mod,proc,varSpace,val[3],r)
                rfree(r)
                text("Le",reg,r,val[1] ~= "<|=")
            end
        elseif val[1] == "~" then
            evaluate(mod,proc,varSpace,val[2],reg)
            text("Not",reg)
        elseif val[1] == "NOT" then
            evaluate(mod,proc,varSpace,val[2],reg)
            text("Xor",reg,{"number",1})
        elseif val[1] == "." then
            evaluate(mod,proc,varSpace,val[2],reg,true)
            local t = val[2][1] == "symbol" and getVarType(mod,mod[3],getProcVars(proc),lastSym[2]) or lastType
            text("Add",reg,{"number",getRecOffset(mod,mod[3],t,val[3])})
            for _,i in ipairs(t) do
                if type(i) == "table" and i[1] == val[3][2] then
                    lastType = i[2]
                end
            end
            if not getAddr then
                text("Load",reg,0,reg)
            end
        elseif val[1] == "[" then
            evaluate(mod,proc,varSpace,val[2],reg,true)
            if lastType[1] ~= "array" and lastType[1] ~= "ptrOf" then
                irgenErr(mod[2],"Attempted to index a value that wasn't an array, a pointer, or a set!")
            end
            local nodeSize = 0
            local nodeType = nil
            if lastType[1] == "ptrOf" then
                text("Load",reg,0,reg)
                nodeSize = getSize(mod,mod[3],lastType[2])
                nodeType = lastType[2]
            else
                nodeSize = getSize(mod,mod[3],lastType[3])
                nodeType = lastType[3]
            end
            local r = ralloc()
            evaluate(mod,proc,varSpace,val[3],r,false)
            if nodeSize > 1 then text("Mul",r,{"number",nodeSize}) end
            rfree(r)
            text("Add",reg,r)
            if not getAddr then
                text(getLoadType(nodeType),reg,0,reg)
            else
                indexSize = nodeSize
            end
        elseif val[1] == "~" then
            evaluate(mod,proc,varSpace,val[2],reg)
            lastType = lastType[2]
            while lastType[1] == "customType" do lastType = getType(mod,mod[3],lastType[2]) end
            if lastType[1] == "numType" and lastType[2] == 1 then
                if wordSize == 4 then
                    text("Lsh",reg,24)
                    text("Ash",reg,24)
                else
                    text("Lsh",reg,56)
                    text("Ash",reg,56)
                end
            elseif lastType[1] == "numType" and lastType[2] == 2 then
                if wordSize == 4 then
                    text("Lsh",reg,16)
                    text("Ash",reg,16)
                else
                    text("Lsh",reg,48)
                    text("Ash",reg,48)                
                end
            elseif lastType[1] == "numType" and lastType[2] == 4 then
                if wordSize == 8 then
                    text("Lsh",reg,32)
                    text("Ash",reg,32)
                end
            elseif lastType[1] == "numType" and lastType[2] == 8 then
                
            else
               irgenErr(mod[2],"Non-integer variables cannot be cast to a signed integer") 
            end
        elseif val[1] == "^" then
            evaluate(mod,proc,varSpace,val[2],reg,false)
            lastType = lastType[2]
            while lastType[1] == "customType" do lastType = getType(mod,mod[3],lastType[2]) end
            if getAddr then return end
            if lastType[1] == "numType" and lastType[2] == 1 then text("LoadByte",reg,0,reg)
            elseif lastType[1] == "numType" and lastType[2] == 2 then text("LoadHalf",reg,0,reg)
            elseif lastType[1] == "numType" and lastType[2] == 4 then text("Load",reg,0,reg)
            else text("LoadLong",reg,0,reg) end
        elseif val[1] == "number" then
            text("LoadImmediate",reg,val[2])
        elseif val[1] == "string" then
            if not strings[val[2]] then
                rodata("__okameronString"..strCount,"string",load("return "..val[2])())
                strings[val[2]] = strCount
                strCount = strCount + 1
            end
            text("LoadAddr",reg,"__okameronString"..strings[val[2]])
        elseif val[1] == "symbol" then
            lastSym = val
            if varSpace[val[2]] ~= nil then
                if getAddr then
                    text("Move",{"frame"},reg)
                    text("Add",reg,{"number",varSpace[val[2]]})
                    lastType = getVarType(mod,mod[3],getProcVars(proc),lastSym[2])
                else
                    lastType = getVarType(mod,mod[3],getProcVars(proc),lastSym[2])
                    text(getLoadType(lastType),reg,varSpace[val[2]],{"frame"})
                end
            else
                assertGlobalVar(mod,mod[3],val[2])
                if getVarType(mod,mod[3],getProcVars(proc),val[2])[1] == "constant" then
                    text("LoadImmediate",reg,getConst(mod,mod[3],val[2]))
                    lastType = {"numType",wordSize}
                else
                    text("LoadAddr",reg,val[2])
                    lastType = getVarType(mod,mod[3],getProcVars(proc),lastSym[2])
                    if not getAddr then
                        text(getLoadType(lastType),reg,0,reg)
                    end
                end
            end
        end
    end

    for _,mod in ipairs(tree) do
        for _,proc in ipairs(mod[6]) do
            text("DefSymbol",proc[2])
            text("PushRet") -- Includes Saved Registers
            local varSpace = {}
            local stackUsage = wordSize
            local argUsage = 0
            for _,a in ipairs(proc[3]) do
                varSpace[a[1]] = stackUsage
                local size = getSize(mod,mod[3],a[2])
                if size < wordSize then
                    size = wordSize;
                end
                stackUsage = stackUsage + size
                argUsage = argUsage + wordSize
            end
            for _,a in ipairs(proc[5]) do
                varSpace[a[2]] = stackUsage
                local size = getSize(mod,mod[3],a[3])
                if (size % wordSize) ~= 0 then
                    size = ((size // wordSize) + 1) * wordSize;
                end
                stackUsage = stackUsage + size;
            end
            text("PushVariables",stackUsage-wordSize,argUsage//wordSize)
            for _,a in ipairs(proc[6]) do
                evaluate(mod,proc,varSpace,a)
            end
            text("PopVariables")
            text("PopRet")
            text("Return")
        end
    end
    for _,mod in ipairs(tree) do
        for _,var in ipairs(mod[5]) do
            if var[1] == "var" then
                bss(var[2],getSize(mod,mod[3],var[3]))
            elseif var[1] == "const" then
                if var[3][1] == "set" then
                    for i=2,#var[3] do
                        if var[3][i][1] == "string" then
                            if not strings[var[3][i][2]] then
                                rodata("__okameronString"..strCount,"string",load("return "..var[3][i][2])())
                                strings[var[3][i][2]] = strCount
                                strCount = strCount + 1
                            end
                            var[3][i] = {"symbol","__okameronString"..strings[var[3][i][2]]}
                        end
                    end
                    table.remove(var[3],1)
                    rodata(var[2],"set",var[3])
                end
            end
        end
    end
    return ircode
end