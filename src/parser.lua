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
    local function parseScope(endType)
        local nodes = {}
        local function addLocalNode(astType,data)
            table.insert(nodes,{type=astType,data=data})
        end
        while tokens[cursor].type ~= endType do
            if tokens[cursor].type == "number" then
                addLocalNode("pushNumber",parseImm(tokens[cursor].txt))
            elseif tokens[cursor].type == "string" then
                addLocalNode("pushString",parseImm(tokens[cursor].txt))
            elseif tokens[cursor].type == "identifier" then

            else
                parserError("Unknown inner scope Token - \""..tokens[cursor].type.."\"")
            end
            cursor = cursor + 1
        end
        cursor = cursor + 1
        return nodes
    end
    while cursor < #tokens do
        if tokens[cursor].type == "constKeyword" then
            cursor = cursor + 1
            expectToken("identifier")
            cursor = cursor + 1
            expectToken("number")
            cursor = cursor + 1
            addNode("constant",{name=tokens[cursor-2].txt,val=parseImm(tokens[cursor-1].txt)})
        elseif tokens[cursor].type == "fnKeyword" then
            cursor = cursor + 1
            expectToken("identifier")
            cursor = cursor + 1
            local curPara = "in"
            local para = {["in"]={},out={}}
            if tokens[cursor].type == "parameter" then
                while tokens[cursor].type == "parameter" do
                    table.insert(para[curPara],tokens[cursor].txt)
                    cursor = cursor + 1
                    if tokens[cursor].type == "parameterSeperator" then
                        curPara = "out"
                        cursor = cursor + 1
                    end
                end
            end
            parseScope("endKeyword")
        else
            parserError("Unknown token \""..tokens[cursor].type.."\"")
        end
    end
end

return parse