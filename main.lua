-- Part 1: create a window and move two table-based paddles with delta time.
local player1, player2
local WIDTH, HEIGHT = 960, 600

function love.load()
    love.window.setMode(WIDTH, HEIGHT)
    love.window.setTitle("Pong - Rahaf Haj Ali")
    love.graphics.setBackgroundColor(0.035, 0.055, 0.09)
    player1 = {x = 36, y = 248, width = 16, height = 104, speed = 380}
    player2 = {x = WIDTH - 52, y = 248, width = 16, height = 104, speed = 380}
end

function love.update(dt)
    if love.keyboard.isDown("w") then player1.y = player1.y - player1.speed * dt end
    if love.keyboard.isDown("s") then player1.y = player1.y + player1.speed * dt end
    if love.keyboard.isDown("up") then player2.y = player2.y - player2.speed * dt end
    if love.keyboard.isDown("down") then player2.y = player2.y + player2.speed * dt end
    for _, paddle in ipairs({player1, player2}) do
        paddle.y = math.max(0, math.min(HEIGHT - paddle.height, paddle.y))
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    for _, paddle in ipairs({player1, player2}) do
        love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)
    end
end
