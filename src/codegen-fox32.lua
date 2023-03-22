return function(asmCode,astNodes,sd)
    local irgen = dofile(sd.."irgen.lua")
    local irCode = irgen(astNodes,4,24)

    local curFunc = ""
    local final = ""

    local regConv = {
        ["a0"] = "r0",
        ["a1"] = "r1",
        ["a2"] = "r2",
        ["a3"] = "r3",
        ["a4"] = "r4",
        ["a5"] = "r5",
        ["a6"] = "r6",
        ["a7"] = "r7",
        ["s0"] = "r8",
        ["s1"] = "r9",
        ["s2"] = "r10",
        ["s3"] = "r11",
        ["s4"] = "r12",
        ["s5"] = "r13",
        ["s6"] = "r14",
        ["s7"] = "r15",
        ["s8"] = "r16",
        ["s9"] = "r17",
        ["s10"] = "r18",
        ["s11"] = "r19",
        ["s12"] = "r20",
        ["s13"] = "r21",
        ["s14"] = "r22",
        ["s15"] = "r23",
        ["s16"] = "r24",
        ["s17"] = "r25",
        ["s18"] = "r26",
        ["s19"] = "r27",
        ["s20"] = "r28",
        ["s21"] = "r29",
        ["s22"] = "r30",
        ["s23"] = "r31",
        ["sp"] = "rsp",
    }

    local function ins(data)
        final = final .. data
    end

    local ops = {
        ["FunctionLabel"] = function(data)
            curFunc = data
            ins(data..":\n")
        end,
        ["LocalLabel"] = function(data)
            ins(curFunc.."_"..data:sub(2)..":\n")
        end,
        ["SaveRet"] = function(data)
            -- This is pushed to the stack so yeah...
        end,
        ["LoadRet"] = function(data)
            -- Return does this so yeah...
        end,
        ["Return"] = function(data)
            ins("    ret\n")
        end,
        ["StoreStack"] = function(data)
            ins("    add rsp, "..data[2].."\n")
            ins("    mov.32 [rsp], "..regConv[data[1]].."\n")
            ins("    sub rsp, "..data[2].."\n")
        end,
        ["LoadStack"] = function(data)
            ins("    add rsp, "..data[2].."\n")
            ins("    mov.32 "..regConv[data[1]]..", [rsp]\n")
            ins("    sub rsp, "..data[2].."\n")
        end,
        ["LoadImm"] = function(data)
            ins("    movz "..regConv[data[1]]..", "..data[2].."\n")
        end,
        ["LoadAddr"] = function(data)
            ins("    movz "..regConv[data[1]]..", "..data[2].."\n")
        end,
        ["StoreByte"] = function(data)
            ins("    mov.8 ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadByte"] = function(data)
            ins("    movz.8 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["LoadByteSigned"] = function(data)
            ins("    mov.8 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["StoreHalf"] = function(data)
            ins("    mov.16 ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadHalf"] = function(data)
            ins("    movz.16 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["LoadHalfSigned"] = function(data)
            ins("    mov.16 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["StoreWord"] = function(data)
            ins("    mov.32 ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadWord"] = function(data)
            ins("    movz.32 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["LoadWordSigned"] = function(data)
            ins("    movz.32 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["StoreLong"] = function(data)
            ins("    mov.32 ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadLong"] = function(data)
            ins("    movz.32 "..regConv[data[1]]..", ["..regConv[data[2]].."]\n")
        end,
        ["MovReg"] = function(data)
            ins("    movz "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["AddReg"] = function(data)
            ins("    add "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["SubReg"] = function(data)
            ins("    sub "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["Mul"] = function(data)
            ins("    imul "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["MulUnsign"] = function(data)
            ins("    mul "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["Div"] = function(data)
            ins("    idiv "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["DivUnsign"] = function(data)
            ins("    div "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["Rem"] = function(data)
            ins("    irem "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["RemUnsign"] = function(data)
            ins("    rem "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["NotReg"] = function(data)
            ins("    not "..regConv[data].."\n")
        end,
        ["AndReg"] = function(data)
            ins("    and "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["OrReg"] = function(data)
            ins("    or "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["XorReg"] = function(data)
            ins("    xor "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["SllReg"] = function(data)
            ins("    sla "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["SrlReg"] = function(data)
            ins("    srl "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["SraReg"] = function(data)
            ins("    sra "..regConv[data[1]]..", "..regConv[data[2]].."\n")
        end,
        ["SltReg"] = function(data)
            ins("    cmp "..regConv[data[2]]..", "..regConv[data[3]].."\n")
            ins("    iflt movz "..regConv[data[1]]..", 1\n")
            ins("    ifgteq movz "..regConv[data[1]]..", 0\n")
        end,
        ["SltUnReg"] = function(data)
            ins("    cmp "..regConv[data[2]]..", "..regConv[data[3]].."\n")
            ins("    iflt movz "..regConv[data[1]]..", 1\n")
            ins("    ifgteq movz "..regConv[data[1]]..", 0\n")
        end,
        ["EqualReg"] = function(data)
            ins("    cmp "..regConv[data[1]]..", "..regConv[data[2]].."\n")
            ins("    ifz movz "..regConv[data[1]]..", 1\n")
            ins("    ifnz movz "..regConv[data[1]]..", 0\n")
        end,
        ["NotEqualReg"] = function(data)
            ins("    cmp "..regConv[data[1]]..", "..regConv[data[2]].."\n")
            ins("    ifz movz "..regConv[data[1]]..", 0\n")
            ins("    ifnz movz "..regConv[data[1]]..", 1\n")
        end,
        ["AddImm"] = function(data)
            if data[2] < 0 then
                ins("    sub.32 "..regConv[data[1]]..", "..math.abs(data[2]).."\n")
            else
                ins("    add.32 "..regConv[data[1]]..", "..data[2].."\n")
            end
        end,
        ["XorImm"] = function(data)
            ins("    xor "..regConv[data[1]]..", "..data[2].."\n")
        end,
        ["SllImm"] = function(data)
            ins("    sla "..regConv[data[1]]..", "..data[2].."\n")
        end,
        ["Branch"] = function(data)
            if data:sub(1,1) == "." then
                ins("    jmp "..curFunc.."_"..data:sub(2).."\n")
            else
                ins("    jmp "..data.."\n")
            end
        end,
        ["LinkedBranch"] = function(data)
            if data:sub(1,1) == "." then
                ins("    call "..curFunc.."_"..data:sub(2).."\n")
            else
                ins("    call "..data.."\n")
            end
        end,
        ["LinkedBranchReg"] = function(data)
            ins("    call "..regConv[data].."\n")
        end,
        ["BranchIfZero"] = function(data)
            ins("    cmp.32 "..regConv[data[1]]..", 0".."\n")
            if data[2]:sub(1,1) == "." then
                ins("    ifz jmp "..curFunc.."_"..data[2]:sub(2).."\n")
            else
                ins("    ifz jmp "..data[2].."\n")
            end
        end,
        ["BranchNotZero"] = function(data)
            ins("    cmp.32 "..regConv[data[1]]..", 0".."\n")
            if data[2]:sub(1,1) == "." then
                ins("    ifnz jmp "..curFunc.."_"..data[2]:sub(2).."\n")
            else
                ins("    ifnz jmp "..data[2].."\n")
            end
        end,
    }

    for _,i in ipairs(irCode[1]) do
        if ops[i["type"]] then
            ops[i["type"]](i["data"])
        else
            error("Unknown IR Opcode "..i["type"].."!")
        end
    end

    for _,i in ipairs(irCode[2]) do
        ins(i["name"]..": ")
        for _,j in ipairs(i["data"]) do
            ins("data.8 "..j.." ")
        end
        ins("\n")
    end

    for _,i in ipairs(irCode[3]) do
        if type(i["data"]) == "table" then
            ins(i["name"]..":\n")
            for _,sym in ipairs(i["data"]) do
                ins("    data.32 "..sym.."\n")
            end
        else
            ins(i["name"]..": data.32 "..i["data"].."\n")
        end
    end

    for _,i in ipairs(irCode[4]) do
        ins(i["name"]..": data.fill 0, "..i["size"].."\n")
    end

    return asmCode..final
end
