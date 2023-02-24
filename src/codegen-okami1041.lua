return function(asmCode,astNodes,sd)
    local irgen = dofile(sd.."irgen.lua")
    local irCode = irgen(astNodes,4,10)

    local final = "\n.text\n"

    local function ins(data)
        final = final .. data
    end

    local ops = {
        ["FunctionLabel"] = function(data)
            ins(".global "..data..":\n")
        end,
        ["LocalLabel"] = function(data)
            ins(data..":\n")
        end,
        ["SaveRet"] = function(data)
            ins("    sw ra, 4(sp)\n")
        end,
        ["LoadRet"] = function(data)
            ins("    lw ra, 4(sp)\n")
        end,
        ["Return"] = function(data)
            ins("    blr zero, ra\n")
        end,
        ["StoreStack"] = function(data)
            ins("    sw "..data[1]..", "..data[2].."(sp)\n")
        end,
        ["LoadStack"] = function(data)
            ins("    lw "..data[1]..", "..data[2].."(sp)\n")
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
            ins("    sb "..data[1]..", 0("..data[2]..")\n")
        end,
        ["LoadByte"] = function(data)
            ins("    lbu "..data[1]..", 0("..data[2]..")\n")
        end,
        ["LoadByteSigned"] = function(data)
            ins("    lb "..data[1]..", 0("..data[2]..")\n")
        end,
        ["StoreHalf"] = function(data)
            ins("    sh "..data[1]..", 0("..data[2]..")\n")
        end,
        ["LoadHalf"] = function(data)
            ins("    lhu "..data[1]..", 0("..data[2]..")\n")
        end,
        ["LoadHalfSigned"] = function(data)
            ins("    lh "..data[1]..", 0("..data[2]..")\n")
        end,
        ["StoreWord"] = function(data)
            ins("    sw "..data[1]..", 0("..data[2]..")\n")
        end,
        ["LoadWord"] = function(data)
            ins("    lw "..data[1]..", 0("..data[2]..")\n")
        end,
        ["MovReg"] = function(data)
            ins("    add "..data[1]..", "..data[2]..", zero\n")
        end,
        ["AddReg"] = function(data)
            ins("    add "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SubReg"] = function(data)
            ins("    sub "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["Mul"] = function(data)
            ins("    mul "..data[1]..", zero, "..data[1]..", "..data[2].."\n")
        end,
        ["MulUnsign"] = function(data)
            ins("    mulu "..data[1]..", zero, "..data[1]..", "..data[2].."\n")
        end,
        ["Div"] = function(data)
            ins("    div "..data[1]..", zero, "..data[1]..", "..data[2].."\n")
        end,
        ["DivUnsign"] = function(data)
            ins("    divu "..data[1]..", zero, "..data[1]..", "..data[2].."\n")
        end,
        ["Rem"] = function(data)
            ins("    div zero, "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["RemUnsign"] = function(data)
            ins("    divu zero, "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["NotReg"] = function(data)
            ins("    addi t7, zero, -1\n")
            ins("    xor "..data..", "..data..", t7\n")
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
            ins("    sll "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SrlReg"] = function(data)
            ins("    srl "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SraReg"] = function(data)
            ins("    sra "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["SltReg"] = function(data)
            ins("    slt "..data[1]..", "..data[2]..", "..data[3].."\n")
        end,
        ["SltUnReg"] = function(data)
            ins("    sltu "..data[1]..", "..data[2]..", "..data[3].."\n")
        end,
        ["EqualReg"] = function(data)
            ins("    sub "..data[1]..", "..data[1]..", "..data[2].."\n")
            ins("    sltiu "..data[1]..", "..data[1]..", 1\n")
        end,
        ["NotEqualReg"] = function(data)
            ins("    sub "..data[1]..", "..data[1]..", "..data[2].."\n")
            ins("    sltu "..data[1]..", zero, "..data[1].."\n")
        end,
        ["AddImm"] = function(data)
            ins("    addi "..data[1]..", "..data[1]..", "..data[2].."\n")
        end,
        ["Branch"] = function(data)
            ins("    b "..data.."\n")
        end,
        ["LinkedBranch"] = function(data)
            ins("    bl "..data.."\n")
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
        ins(".global "..i["name"]..": ")
        for _,j in ipairs(i["data"]) do
            ins(".byte "..j.." ")
        end
        ins("\n")
    end

    ins(".bss\n")

    for _,i in ipairs(irCode[4]) do
        ins(".global "..i["name"]..": .resb "..i["size"].."\n")
    end

    return asmCode..final
end
