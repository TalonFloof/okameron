local args = {...}
local arch = "okami1041"

local nl = string.char(10) -- newline
function serialize_list (tabl, indent)
    indent = indent and (indent.."  ") or ""
    local str = ''
    str = str .. indent.."{"..nl
    for key, value in pairs (tabl) do
        local pr = (type(key)=="string") and ('["'..key..'"]=') or ""
        if type (value) == "table" then
            str = str..pr..serialize_list (value, indent)
        elseif type (value) == "string" then
            str = str..indent..pr..'"'..tostring(value)..'",'..nl
        else
            str = str..indent..pr..tostring(value)..','..nl
        end
    end
    str = str .. indent.."},"..nl
    return str
end

while #args > 0 and string.sub(args[1],1,1) == "-" do
    if string.sub(args[1],2,6) == "arch=" then
        arch = string.sub(args[1],7)
    else
        print("Unknown option \""..args[1].."\"")
        return
    end
    table.remove(args,1)
end

if #args < 2 then
    print("Usage: vos [-arch=okami1041] [sourcefile] [assemblyfile]")
    return
end

local codegen = require("codegen-"..arch)
local lexer = require("lexer")
local parser = require("parser")
local infile = io.open(args[1],"rb")
local code = infile:read("*a").."\n"
infile:close()
for i in code:gmatch("([^\n]*)\n") do
    if i:sub(1,10) == ".include \"" then
        local str = load("return "..i:sub(10),"=includeparse","t",{})()
    end
end
local tokens = lexer(code)
local astNodes = parser(tokens)
print(serialize_list(astNodes))