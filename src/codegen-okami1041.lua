return function(astNodes)
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
    

    return ".text\n"..sections[1].."\n.rodata\n"..sections[2].."\n.data\n"..sections[3].."\n.bss\n"..sections[4]
end