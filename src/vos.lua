local args = {...}
local arch = "okami1041"

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
local infile = io.open(args[1],"rb")
local code = infile:read("*a")
infile:close()
local tokens = lexer(code)
for i,j in ipairs(tokens) do
    io.write("Token "..i..": ")
    for key, val in pairs(j) do
        io.write(key.."="..val.." ")
    end
    print()
end