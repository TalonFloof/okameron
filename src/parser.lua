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
    local function dontExpectToken(tokenType)
        if tokens[cursor].type == tokenType then
            parserError("Didn't expect token \""..tokenType.."\" but got it anyway.")
        end
    end
    local function parseCall()
        local nodes = {}
        local function addLocalNode(astType,data)
            table.insert(nodes,{type=astType,data=data})
        end
        local start = cursor
        expectToken("startCall")
        cursor = cursor + 1
        expectToken("identifier")
        local name = tokens[cursor].txt
        cursor = cursor + 1
        while tokens[cursor].type ~= "endCall" do
            if tokens[cursor].type == "startCall" then
                table.insert(nodes,parseCall())
            elseif tokens[cursor].type == "identifier" then
                addLocalNode("symbol",tokens[cursor].txt)
                cursor = cursor + 1
            elseif tokens[cursor].type == "number" then
                addLocalNode("number",parseImm(tokens[cursor].txt))
                cursor = cursor + 1
            elseif tokens[cursor].type == "string" then
                addLocalNode("string",parseImm(tokens[cursor].txt))
                cursor = cursor + 1
            else
                parserError("Unknown token \""..tokens[cursor].type.."\" in function scope")
            end
        end
        cursor = cursor + 1
        return {type="call",data={name=name,nodes=nodes}}
    end
    while cursor < #tokens do
        if tokens[cursor].type == "startCall" then
            cursor = cursor + 1
            expectToken("identifier")
            local name = tokens[cursor].txt
            if name == "fn" then
                local args = {}
                cursor = cursor + 1
                expectToken("identifier")
                local fnName = tokens[cursor].txt
                cursor = cursor + 1
                expectToken("startCall")
                cursor = cursor + 1
                while tokens[cursor].type ~= "endCall" do
                    expectToken("identifier")
                    table.insert(args,tokens[cursor].txt)
                    cursor = cursor + 1
                end
                cursor = cursor + 1
                local nodes = {}
                while tokens[cursor].type ~= "endCall" do
                    table.insert(nodes,parseCall())
                end
                cursor = cursor + 1
                addNode("function",{name=fnName,args=args,nodes=nodes})
            elseif name == "const" then
                cursor = cursor + 1
                expectToken("identifier")
                cursor = cursor + 1
                expectToken("number")
                cursor = cursor + 1
                expectToken("endCall")
                cursor = cursor + 1
                addNode("constant",{name=tokens[cursor-3].txt,val=parseImm(tokens[cursor-2].txt)})
            else
                parserError("Unknown keyword \""..tokens[cursor].type.."\" in global scope")
            end
        else
            parserError("Unknown token \""..tokens[cursor].type.."\" in global scope")
        end
    end
    return astNodes
end

return parse