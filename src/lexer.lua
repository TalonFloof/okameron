return function(code)
    local tokens = {}
    local cursorStart = 1
    local cursor = 1
    local line = 1
    local lineStart = 0
    local function lexerError(err)
        io.stderr:write("\x1b[1;31m"..line..":"..(cursor-lineStart).." - "..err.."\x1b[0m\n")
        os.exit(1)
    end
    local function addToken(tokenType)
        table.insert(tokens,{type=tokenType,begin=cursorStart,["end"]=cursor,txt=code:sub(cursorStart,cursor)})
        cursorStart = cursor + 1
        cursor = cursor + 1
    end
    local function isNumber(c)
        return c >= "0" and c <= "9"
    end
    local function isNumberExt(c)
        return isNumber(c) or ((c:lower() >= "a" and c:lower() <= "f") or c == "x" or c == "o")
    end
    local function isAlpha(c)
        return (c:lower() >= "a" and c:lower() <= "z") or c == "_"
    end
    local function isAlphaExt(c)
        return isAlpha(c) or (c:lower() >= "0" and c:lower() <= "9")
    end
    while cursor < #code do
        if code:sub(cursorStart,cursor) == " " or code:sub(cursorStart,cursor) == "\n" or code:sub(cursorStart,cursor) == "\t" or code:sub(cursorStart,cursor) == "\r" then
            cursorStart = cursor + 1
            cursor = cursor + 1
            if code:sub(cursorStart-1,cursorStart-1) == "\n" then
                line = line + 1
                lineStart = cursor - 1
            end
        elseif code:sub(cursorStart,cursor) == "/*" then
            while code:sub(cursor,cursor+1) ~= "*/" do cursor = cursor + 1 end
            cursor = cursor + 1
            addToken("comment")
        elseif isAlpha(code:sub(cursor,cursor)) then
            while isAlphaExt(code:sub(cursor,cursor)) do cursor = cursor + 1 end
            cursor = cursor - 1
            local str = code:sub(cursorStart,cursor)
            if str == "fn" then
                addToken("fnKeyword")
            elseif str == "end" then
                addToken("endKeyword")
            elseif str == "if" then
                addToken("ifKeyword")
            elseif str == "elseif" then
                addToken("elseifKeyword")
            elseif str == "else" then
                addToken("elseKeyword")
            elseif str == "do" then
                addToken("doKeyword")
            elseif str == "loop" then
                addToken("loopKeyword")
            elseif str == "break" then
                addToken("breakKeyword")
            elseif str == ".include_asm" then
                addToken("includeASM")
            elseif str == "auto" then
                addToken("autoKeyword")
            elseif str == "var" then
                addToken("varKeyword")
            elseif str == "const" then
                addToken("constKeyword")
            elseif str == "struct" then
                addToken("structKeyword")
            else
                addToken("identifier")
            end
        elseif isNumber(code:sub(cursor,cursor)) then
            while isNumberExt(code:sub(cursor,cursor)) do cursor = cursor + 1 end
            cursor = cursor - 1
            addToken("number")
        elseif code:sub(cursorStart,cursor) == "(" then
            addToken("parameterStart")

        else
            lexerError("Invalid Syntax")
        end
    end
    return tokens
end