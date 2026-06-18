lines = {""}
cursorLine = 1
cursorColumn = 4
cameraX = 0
cameraY = 0
local font

function love.load()
    font = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 64)
    love.graphics.setFont(font)
end

function love.update(dt)
    local lastLine = lines[#lines]
    local cursorX = font:getWidth(lastLine)
    local cursorY = font:getHeight(lastLine)

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if cursorX - cameraX > screenWidth - 50 then
        cameraX = cursorX - (screenWidth - 50)
    end
    if cursorY - cameraY > screenHeight - 50 then
        cameraY = cursorY - (screenHeight - 50)
    end

    if cursorX - cameraX < 50 then
        cameraX = math.max(0, font:getWidth(lines[#lines]) - love.graphics.getWidth() + 100)
    end
    if cursorY - cameraY < 50 then
        cameraY = math.max(0, font:getHeight(lines[#lines]) - love.graphics.getHeight() + 100)
    end
end

function love.draw()
    local lastLine = lines[#lines]
    love.graphics.push()
    love.graphics.translate(-cameraX, 0)

    local textX = 0
    local textY = 0

    for i, line in ipairs(lines) do
        love.graphics.print(
            line,
            0,
            0 + (i - 1) * font:getHeight()
        )
    end

    local cursorX = textX + font:getWidth(lastLine)
    love.graphics.line(
        cursorX,
        textY,
        cursorX,
        textY + font:getHeight()
    )

    love.graphics.pop()
end

function love.textinput(t)
    lines[#lines] = lines[#lines] .. t
end

function love.keypressed(key)
    if key == "backspace" then
        if #lines > 1 and lines[#lines] == "" then
            table.remove(lines)
        end
        lines[#lines] = lines[#lines]:sub(1, -2)
    end
    if key == "return" then
        table.insert(lines, "")
    end
end