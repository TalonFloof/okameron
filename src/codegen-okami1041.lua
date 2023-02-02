return function(asmCode)
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