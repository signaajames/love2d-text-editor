lines = {""}
cursorLine = #lines
cursorColumn = #lines[#lines] + 1
cameraX = 0
cameraY = 0

function love.load()
    font = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 64)
    love.graphics.setFont(font)

    debugFont = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 10)
end
function love.update(dt)
    local lastLine = lines[#lines]
    local caretX = font:getWidth(lastLine)
    local caretY = font:getHeight(lastLine)

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if caretX - cameraX > screenWidth - 50 then
        cameraX = caretX - (screenWidth - 50)
    end

    if caretX - cameraX < 50 then
        cameraX = math.max(0, font:getWidth(lines[#lines]) - love.graphics.getWidth() + 100)
    end

    position = cursorLine.. ",".. cursorColumn
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-cameraX, 0)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font)

    local lastLine = lines[#lines]
    -- draw the text
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

    love.graphics.setFont(debugFont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print("Cursor Line: ".. cursorLine, 10, love.graphics.getHeight() - 20)
    love.graphics.print("Cursor Column: ".. cursorColumn, 10, love.graphics.getHeight() - 30)
    love.graphics.print("Position: ".. position, 10, love.graphics.getHeight() - 45)
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
        if #lines > 1 and lines[#lines] == "" then
            table.remove(lines)
        end
        lines[#lines] = lines[#lines]:sub(1, -2)
        cursorColumn = math.max(1, cursorColumn -1)
    end
    if key == "return" then
        table.insert(lines, "")
        cursorLine = #lines
    end
    if key == 'left' then
        cursorColumn = math.max(1, cursorColumn -1)
    end
    if key == 'right' then
        cursorColumn = math.max(1, cursorColumn + 1)
    end
end