local function parse(tokens)
    local astNodes = {}
    local cursor = 1
    local function addNode(astType,data)
        table.insert(astNodes,{type=astType,data=data})
    end
    local function parseImm(str)
        return load("return "..str,"=parseimmediate","t",{})()
    end
    local function parserError(err)
        io.stderr:write("\x1b[1;31m"..tokens[cursor].line..":"..tokens[cursor].col.." - "..err.."\x1b[0m\n")
        os.exit(2)
    end
    local function expectToken(tokenType)
        if tokens[cursor].type ~= tokenType then
            parserError("Expected token \""..tokenType.."\" got \""..tokens[cursor].type.."\".")
        end
    end
    while cursor < #tokens do
        if tokens[cursor].type == "startCall" then
            cursor = cursor + 1
            expectToken("identifier")
            local name = tokens[cursor-1].txt
            if name == "fn" then
                
            elseif name == "const" then
                cursor = cursor + 1
                expectToken("identifier")
                cursor = cursor + 1
                expectToken("number")
                cursor = cursor + 1
                addNode("constant",{name=tokens[cursor-2].txt,val=parseImm(tokens[cursor-1].txt)})
            end
        if tokens[cursor].type == "constKeyword" then
            
        else
            parserError("Unknown token \""..tokens[cursor].type.."\"")
        end
    end
    return astNodes
end

return parse