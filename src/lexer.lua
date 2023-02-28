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
        table.insert(tokens,{type=tokenType,line=line,col=cursorStart-lineStart,txt=code:sub(cursorStart,cursor)})
        cursorStart = cursor + 1
        cursor = cursor + 1
    end
    local function isNumber(c)
        return c >= "0" and c <= "9"
    end
    local function isNumberExt(c)
        return isNumber(c) or ((c:lower() >= "a" and c:lower() <= "f") or c == "x" or c == "o")
    end
    local function isSymbol(c)
        return c == "!" or c == "@" or c == "=" or c == "<" or c == ">" or c == "|" or c == "^" or c == "*" or c =="+" or c == "-" or c == "/" or c == "%" or c == "&" or c == "."
    end
    local function isAlpha(c)
        return (c:lower() >= "a" and c:lower() <= "z") or c == "_"
    end
    local function isAlphaExt(c)
        return isAlpha(c) or (c:lower() >= "0" and c:lower() <= "9")
    end
    while cursor <= #code do
        if code:sub(cursorStart,cursor) == " " or code:sub(cursorStart,cursor) == "\n" or code:sub(cursorStart,cursor) == "\t" or code:sub(cursorStart,cursor) == "\r" then
            cursorStart = cursor + 1
            cursor = cursor + 1
            if code:sub(cursorStart-1,cursorStart-1) == "\n" then
                line = line + 1
                lineStart = cursor - 1
            end
        elseif code:sub(cursor,cursor+1) == "/*" then
            while code:sub(cursor,cursor+1) ~= "*/" do cursor = cursor + 1 end
            cursor = cursor + 2
            cursorStart = cursor
        elseif code:sub(cursor,cursor) == "(" then
            addToken("startCall")
        elseif isAlpha(code:sub(cursor,cursor)) or isSymbol(code:sub(cursor,cursor)) then
            while isAlphaExt(code:sub(cursor,cursor)) or isSymbol(code:sub(cursor,cursor)) do cursor = cursor + 1 end
            cursor = cursor - 1
            local str = code:sub(cursorStart,cursor)
            addToken("identifier")
        elseif code:sub(cursor,cursor) == '"' then
            cursor = cursor + 1
            while (code:sub(cursor,cursor) ~= '"') or (code:sub(cursor,cursor) == '"' and code:sub(cursor,cursor-1) == "\\") do cursor = cursor + 1 end
            addToken("string")
        elseif isNumber(code:sub(cursor,cursor)) then
            while isNumberExt(code:sub(cursor,cursor)) do cursor = cursor + 1 end
            cursor = cursor - 1
            addToken("number")
        elseif code:sub(cursor,cursor) == ")" then
            addToken("endCall")
        else
            --[[for i,j in ipairs(tokens) do
                io.write("Token "..i..": ")
                for key, val in pairs(j) do
                    io.write(key.."="..val.." ")
                end
                print()
            end]]
            lexerError("Invalid Syntax")
        end
    end
    return tokens
end