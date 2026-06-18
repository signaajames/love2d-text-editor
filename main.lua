lines = {""}
cursorLine = #lines
cursorColumn = #lines[cursorLine] + 1
cameraX = 0
cameraY = 0

function love.load()
    font = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 64)
    love.graphics.setFont(font)

    debugFont = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 10)
end
function love.update(dt)
    local caretX = font:getWidth(lines[cursorLine] or "")

    local screenWidth = love.graphics.getWidth()

    if caretX - cameraX > screenWidth - 50 then
        cameraX = caretX - (screenWidth - 50)
    end

    if caretX - cameraX < 50 then
        cameraX = math.max(0, font:getWidth(lines[cursorLine]) - love.graphics.getWidth() + 100)
    end

    position = cursorLine.. ",".. cursorColumn
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-cameraX, 0)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font)

    local lastLine = lines[#lines]
    -- draw the text from lines
    for i, line in ipairs(lines) do
        love.graphics.print(
            line,
            0,
            0 + (i - 1) * font:getHeight()
        )
    end
    -- draw the caret
    local beforeCursor =
    lines[cursorLine]:sub(1, cursorColumn - 1)

    local cursorX = font:getWidth(beforeCursor)
    local cursorY = (cursorLine - 1) * font:getHeight()
    love.graphics.line(
        cursorX,
        cursorY,
        cursorX,
        cursorY + font:getHeight()
    )

    love.graphics.pop()

    -- bunch of debugging stuff
    if debugging then
        love.graphics.setFont(debugFont)
        love.graphics.setColor(0,1,0,1)
        love.graphics.print("Cursor Line: ".. cursorLine, 10, love.graphics.getHeight() - 20)
        love.graphics.print("Cursor Column: ".. cursorColumn, 10, love.graphics.getHeight() - 30)
        love.graphics.print("Position: ".. position, 10, love.graphics.getHeight() - 45)
    end
end

function love.textinput(t)
    local line = lines[cursorLine]

    lines[cursorLine] = 
        line:sub(1, cursorColumn -1)
        .. t ..
        line:sub(cursorColumn)

    cursorColumn = cursorColumn + #t
end

function love.keypressed(key)
    if key == "backspace" then
        local line = lines[cursorLine]

        if cursorColumn > 1 then
            local left = line:sub(1, cursorColumn - 2)
            local right = line:sub(cursorColumn)

            lines[cursorLine] = left .. right
            cursorColumn = cursorColumn - 1
        end

        if cursorLine ~= 1 then
            table.remove(lines, cursorLine)
            cursorLine = cursorLine - 1
            cursorColumn = #lines[cursorLine] + 1
        end
    end
    if key == "return" then
        table.insert(lines, "")
        cursorLine = #lines
        
        local line = lines[cursorLine]
        cursorColumn = math.min(cursorColumn, #line + 1)
    end
    -- deal with moving left in a line
    if key == 'left' then
        cursorColumn = math.max(1, cursorColumn -1)
    end
    -- deal with moving right in a line
    if key == 'right' then
        local line = lines[cursorLine]
        cursorColumn = math.min(#line + 1, cursorColumn + 1)
    end
    -- deal with moving up lines
    if key == 'up' then
        cursorLine = math.max(1, cursorLine - 1)

        local line = lines[cursorLine]
        cursorColumn = math.min(cursorColumn, #line + 1)
    end
    -- deal with moving down lines
    if key == 'down' and cursorLine ~= #lines then
        cursorLine = math.max(1, cursorLine + 1)

        local line = lines[cursorLine]
        cursorColumn = math.min(cursorColumn, #line + 1)
    end
end