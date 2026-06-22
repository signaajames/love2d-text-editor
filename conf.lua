debugging = true

lines = {""}
cursorLine = #lines
cursorColumn = #lines[cursorLine] + 1
position = nil
cameraX = 0
cameraY = 0
BackspaceStatus = 'nil'
LineReturnStatus = 'nil'
DelStatus = 'nil'
LeftStatus = 'nil'
UpStatus = 'nil'
RightStatus = 'nil'
DownStatus = 'nil'

LineBackspaceRight = '...'
LineDelRight = '...'
LineReturnRight = '...'
LineReturnLeft = '...'
DelRight = '...'
DelMergContent = "..."

function love.conf(t)
    t.window.width = 1024
    t.window.height = 600
end