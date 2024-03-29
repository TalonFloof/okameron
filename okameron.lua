function getdirectory(p)
	for i = #p, 1, -1 do
		if p:sub(i,i) == "/" then
			return p:sub(1,i)
		end
	end

	return "./"
end
local sd = getdirectory(arg[0])

local args = {...}

arch = "okami1041"

local scan = dofile(sd.."scanner.lua")
local parse = dofile(sd.."parser.lua")
local irgen = dofile(sd.."irgen.lua")

local startup = ""

useXrSDK = false

while #args > 0 and string.sub(args[1],1,1) == "-" do
    if string.sub(args[1],2,6) == "arch=" then
        arch = string.sub(args[1],7)
    elseif string.sub(args[1],2,9) == "startup=" then
        local file = io.open(string.sub(args[1],10),"rb")
        startup = file:read("*a")
        file:close()
    elseif string.sub(args[1],2,#args[1]) == "xrsdk" then
        useXrSDK = true
    else
        print("Unknown option \""..args[1].."\"")
        return
    end
    table.remove(args,1)
end

local codegen = dofile(sd.."codegen-"..arch..".lua")

local tokens = {}

function serialize_list (list,newlines,subNewline)
    local str = "("
    for _,i in ipairs(list) do
        if type(i) == "table" then
            str = str .. serialize_list(i,subNewline,subNewline)
        else
            str = str .. tostring(i)
        end
        str = str .. (newlines and "\n" or " ")
    end
    if #list > 0 then
        str = string.sub(str,1,#str-1)
    end
    str = str .. ")"
    return str
end

local nl = string.char(10)
function serialize_table (tabl, indent)
    indent = indent and (indent.."  ") or ""
    local str = ''
    str = str .. indent.."{"..nl
    for key, value in pairs (tabl) do
        local pr = (type(key)=="string") and ('["'..key..'"]=') or ""
        if type (value) == "table" then
            str = str..pr..serialize_table (value, indent)
        elseif type (value) == "string" then
            str = str..indent..pr..'"'..tostring(value)..'",'..nl
        else
            str = str..indent..pr..tostring(value)..','..nl
        end
    end
    str = str .. indent.."},"..nl
    return str
end

local function addToTokens(t)
    while #t > 0 do
        table.insert(tokens,table.remove(t,1))
    end
end

for _,i in ipairs(args) do
    local file = io.open(i,"rb")
    addToTokens(scan(i,file:read("*a")))
    file:close()
end
local tree, asm = parse(tokens,systemWordSize)
asm = startup .. "\n" .. asm
--io.stderr:write(serialize_list(tree,true,false).."\n")
local ircode = irgen(tree,systemWordSize)
--io.stderr:write(serialize_list(ircode[1],true,false).."\n\n\n")
--io.stderr:write(serialize_list(ircode[2],true,false).."\n")
codegen(ircode,asm)
