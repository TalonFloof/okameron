return function(asmCode,astNodes,sd)
    local irgen = dofile(sd.."irgen.lua")
    local irCode = irgen(astNodes,4,14)

    local final = "\n.section text\n"

    local function ins(data)
        final = final .. data
    end

    local regConv = {
        ["a0"] = "a0",
        ["a1"] = "a1",
        ["a2"] = "a2",
        ["a3"] = "a3",
        ["a4"] = "s0",
        ["a5"] = "s1",
        ["a6"] = "s2",
        ["a7"] = "s3",
        ["s0"] = "s4",
        ["s1"] = "s5",
        ["s2"] = "s6",
        ["s3"] = "s7",
        ["s4"] = "s8",
        ["s5"] = "s9",
        ["s6"] = "s10",
        ["s7"] = "s11",
        ["s8"] = "s12",
        ["s9"] = "s13",
        ["s10"] = "s14",
        ["s11"] = "s15",
        ["s12"] = "s16",
        ["s13"] = "s17",
        ["sp"] = "sp",
    }

    local ops = {
        ["FunctionLabel"] = function(data)
            ins(data..":\n.global "..data.."\n")
        end,
        ["LocalLabel"] = function(data)
            ins(data..":\n")
        end,
        ["SaveRet"] = function(data)
            ins("    mov long [sp + 4], lr\n")
        end,
        ["LoadRet"] = function(data)
            ins("    mov lr, long [sp + 4]\n")
        end,
        ["Return"] = function(data)
            ins("    ret\n")
        end,
        ["StoreStack"] = function(data)
            ins("    mov long [sp + "..data[2].."], "..regConv[data[1]].."\n")
        end,
        ["LoadStack"] = function(data)
            ins("    mov "..regConv[data[1]]..", long [sp + "..data[2].."]\n")
        end,
        ["LoadImm"] = function(data)
            if (data[2] & 0xFFFF) == 0 then
                ins("    lui "..data[1]..", "..(data[2] >> 16).."\n")
            elseif (data[2] & 0xFFFF0000) == 0 then
                ins("    li "..data[1]..", "..data[2].."\n")
            else
                ins("    la "..data[1]..", "..data[2].."\n")
            end
        end,
        ["LoadAddr"] = function(data)
            ins("    la "..data[1]..", "..data[2].."\n")
        end,
        ["StoreByte"] = function(data)
            ins("    mov byte ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadByte"] = function(data)
            ins("    mov "..regConv[data[1]]..", byte ["..regConv[data[2]].."]\n")
        end,
        ["LoadByteSigned"] = function(data)
            ins("    mov "..regConv[data[1]]..", byte ["..regConv[data[2]].."]\n")
            ins("    lshi "..regConv[data[1]]..", 24\n")
            ins("    ashi "..regConv[data[1]]..", 24\n")
        end,
        ["StoreHalf"] = function(data)
            ins("    mov int ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadHalf"] = function(data)
            ins("    mov "..regConv[data[1]]..", int ["..regConv[data[2]].."]\n")
        end,
        ["LoadHalfSigned"] = function(data)
            ins("    mov "..regConv[data[1]]..", int ["..regConv[data[2]].."]\n")
            ins("    lshi "..regConv[data[1]]..", 16\n")
            ins("    ashi "..regConv[data[1]]..", 16\n")
        end,
        ["StoreWord"] = function(data)
            ins("    mov long ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadWord"] = function(data)
            ins("    mov "..regConv[data[1]]..", long ["..regConv[data[2]].."]\n")
        end,
        ["LoadWordSigned"] = function(data)
            ins("    mov "..regConv[data[1]]..", long ["..regConv[data[2]].."]\n")
        end,
        ["StoreLong"] = function(data)
            ins("    mov long ["..regConv[data[2]].."], "..regConv[data[1]].."\n")
        end,
        ["LoadLong"] = function(data)
            ins("    mov "..regConv[data[1]]..", long ["..regConv[data[2]].."]\n")
        end,
        ["MovReg"] = function(data)
            ins("    mov "..data[1]..", "..data[2].."\n")
        end,
        ["AddReg"] = function(data)
            ins("    add "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SubReg"] = function(data)
            ins("    sub "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["Mul"] = function(data)
            ins("    mul signed "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["MulUnsign"] = function(data)
            ins("    mul "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["Div"] = function(data)
            ins("    div signed "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["DivUnsign"] = function(data)
            ins("    div "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["Rem"] = function(data)
            ins("    mod "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["RemUnsign"] = function(data)
            ins("    mod "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["NotReg"] = function(data)
            ins("    nor "..data..", "..data..", zero\n")
        end,
        ["AndReg"] = function(data)
            ins("    and "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["OrReg"] = function(data)
            ins("    or "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["XorReg"] = function(data)
            ins("    xor "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SllReg"] = function(data)
            ins("    lsh "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SrlReg"] = function(data)
            ins("    rsh "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SraReg"] = function(data)
            ins("    ash "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SltReg"] = function(data)
            ins("    slt signed "..data[1]..", "..data[2]..", "..data[3].."\n")
        end,
        ["SltUnReg"] = function(data)
            ins("    slt "..data[1]..", "..data[2]..", "..data[3].."\n")
        end,
        ["EqualReg"] = function(data)
            ins("    sub "..data[1]..", "..data[2]..", "..data[1].."\n")
            ins("    slti "..data[1]..", "..data[1]..", 1\n")
        end,
        ["NotEqualReg"] = function(data)
            ins("    sub "..data[1]..", "..data[2]..", "..data[1].."\n")
            ins("    slt "..data[1]..", zero, "..data[1].."\n")
        end,
        ["AddImm"] = function(data)
            if data[2] < 0 then
                ins("    subi "..data[1]..", "..data[1]..", "..(-data[2]).."\n")
            else
                ins("    addi "..data[1]..", "..data[1]..", "..data[2].."\n")
            end
        end,
        ["XorImm"] = function(data)
            ins("    xori "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SllImm"] = function(data)
            ins("    lshi "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["Branch"] = function(data)
            ins("    j "..data.."\n")
        end,
        ["LinkedBranch"] = function(data)
            ins("    jal "..data.."\n")
        end,
        ["LinkedBranchReg"] = function(data)
            ins("    jalr lr, "..data..", 0\n")
        end,
        ["BranchIfZero"] = function(data)
            ins("    beq "..data[1]..", zero, "..data[2].."\n")
        end,
        ["BranchNotZero"] = function(data)
            ins("    bne "..data[1]..", zero, "..data[2].."\n")
        end,
    }

    for _,i in ipairs(irCode[1]) do
        if ops[i["type"]] then
            ops[i["type"]](i["data"])
        else
            error("Unknown IR Opcode "..i["type"].."!")
        end
    end

    ins(".rodata\n")

    for _,i in ipairs(irCode[2]) do
        ins(i["name"]..": ")
        for _,j in ipairs(i["data"]) do
            ins(".byte "..j.." ")
        end
        ins("\n")
    end

    ins(".data\n")

    for _,i in ipairs(irCode[3]) do
        if type(i["data"]) == "table" then
            ins(".global "..i["name"]..":\n")
            for _,sym in ipairs(i["data"]) do
                ins("    .word "..sym.."\n")
            end
        else
            ins(".global "..i["name"]..": .word "..i["data"].."\n")
        end
    end

    ins(".bss\n")

    for _,i in ipairs(irCode[4]) do
        if i["size"] >= 2 and i["size"] <= 3 then
            ins(".align 2\n")
        elseif i["size"] >= 4 then
            ins(".align 4\n")
        end
        if i["size"] == 0 then
            ins(".global "..i["name"]..":\n")
        else
            ins(".global "..i["name"]..": .resb "..i["size"].."\n")
        end
    end

    return asmCode..final
end