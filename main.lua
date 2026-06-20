lines = {""}
cursorLine = #lines
cursorColumn = #lines[cursorLine] + 1
position = nil
cameraX = 0
cameraY = 0
DeletionStatus = 'nil'
lineDeletionRight = '...'
lineReturnStatus = 'nil'
lineReturnRight = '...'
lineReturnLeft = '...'

function love.load()
    font = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 64)
    love.graphics.setFont(font)

    debugFont = love.graphics.newFont("JetBrainsMonoNerdFontMono-Regular.ttf", 10)
end
function love.update(dt)
    local caretX = font:getWidth(lines[cursorLine] or "")
    caretY = #lines * font:getHeight() -- could be like 84 if theres 1 line, or 252 if theres 3
    local lineheight = font:getHeight()

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- this deals with moving the camera forwards
    if caretX - cameraX > screenWidth - 50 then
        cameraX = caretX - (screenWidth - 50)
    end
    -- this deals with moving the camera backwards
    if caretX - cameraX < 50 then
        cameraX = math.max(0, font:getWidth(lines[cursorLine]) - love.graphics.getWidth() + 100)
    end

    -- this deals with moving the camera downwards
    if caretY - cameraY > screenHeight - lineheight then
        cameraY = caretY - (screenHeight - lineheight)
    end
    -- this deals with moving the camera upwards
    if caretY - cameraY < lineheight * 2 then
        cameraY = math.max(0, caretY - screenHeight + 100)
    end

    -- for debugging
    position = cursorLine.. ",".. cursorColumn
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-cameraX, 0)
    love.graphics.translate(0, -cameraY)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font)

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
        love.graphics.print("Cursor Pos: ".. position, 10, love.graphics.getHeight() - 20)
        love.graphics.print("Cursor Line: ".. cursorLine, 10, love.graphics.getHeight() - 30)
        love.graphics.print("Cursor Line Content: ".. lines[cursorLine], 10, love.graphics.getHeight() - 40)
        love.graphics.print("Cursor Column: ".. cursorColumn, 10, love.graphics.getHeight() - 50)
        love.graphics.print("Total Height: ".. caretY, 10, love.graphics.getHeight() - 60)
        --second part
        love.graphics.setColor(0,0.8,0,1)
        love.graphics.print("Content on Line Deletion Right: ".. lineDeletionRight, 150, love.graphics.getHeight() - 20)
        love.graphics.print("Deletion Status: ".. DeletionStatus, 150, love.graphics.getHeight() - 30)
        love.graphics.print("Line Return Status: ".. lineReturnStatus, 150, love.graphics.getHeight() - 50)
        love.graphics.print("Content on Line Return Right: ".. lineReturnRight, 150, love.graphics.getHeight() - 60)
        love.graphics.print("Content on Line Return Left: ".. lineReturnLeft, 150, love.graphics.getHeight() - 70)
        --third part
        love.graphics.setColor(0,0.6,0,1)
        love.graphics.print("Screen Height: ".. screenHeight, screenWidth - 120, love.graphics.getHeight() - 20)
        love.graphics.print("Screen Width: ".. screenWidth, screenWidth - 120, love.graphics.getHeight() - 30)
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
        -- Char deletion
        if cursorColumn > 1 then
            DeletionStatus = "Char"
            local left = line:sub(1, cursorColumn - 2) -- everything before the caret (to the left of the cursor)
            local right = line:sub(cursorColumn) -- everything after the caret (to the right of the cursor)

            lines[cursorLine] = left .. right -- change the line to the new one
            cursorColumn = cursorColumn - 1 -- move the caret
            
        elseif cursorLine > 1 and cursorColumn == 1 then
            -- checked if cursorColumn was not > 1
            if #line >= 1 then
                DeletionStatus = "Merg"
                local right = line:sub(cursorColumn)
                lineDeletionRight = right
            
                table.remove(lines, cursorLine)
                cursorLine = cursorLine - 1
                cursorColumn = #lines[cursorLine] + 1
            
                lines[cursorLine] = lines[cursorLine] .. right
            else -- if theres more than 1 cursorLine and cursorColumn is less than or equal to 1, delete the line.
                DeletionStatus = 'Line'
                table.remove(lines, cursorLine)
                cursorLine = cursorLine - 1
                cursorColumn = #lines[cursorLine] + 1
            end
        end
    end

    if key == "return" then
        local line = lines[cursorLine]
        if cursorColumn == #lines[cursorLine] + 1 then -- if the cursorColumn is at the end of the current line
            lineReturnStatus = 'casual'
            table.insert(lines, "") -- add a new empty table
            cursorLine = cursorLine + 1 -- set the current line to the length of the lines table (bug rn)
        
            cursorColumn = math.min(cursorColumn, #lines[cursorLine] + 1) -- set the cursorColumn to the end of the new line
        elseif cursorColumn ~= #lines[cursorLine] + 1 then -- if the cursorColumn is not at the end of the current line
            lineReturnStatus = 'seperating'

            local left = line:sub(1, cursorColumn - 1)
            local right = line:sub(cursorColumn)
            lineReturnRight = right
            lineReturnLeft = left
            
            lines[cursorLine] = left
            table.insert(lines, right)
            cursorLine = cursorLine + 1
            cursorColumn = 1
        end
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