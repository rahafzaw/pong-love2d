local Pong = require("pong")
local game
local fonts = {}
local colors = {
    background = {0.035, 0.055, 0.09}, court = {0.065, 0.09, 0.135},
    line = {0.17, 0.22, 0.29}, white = {0.93, 0.96, 1},
    muted = {0.57, 0.65, 0.74}, left = {0.28, 0.9, 0.79},
    right = {1, 0.65, 0.39}
}

-- Runs once: prepare the window, initial state and fonts.
function love.load()
    love.window.setMode(960, 600, {resizable = false, vsync = 1})
    love.window.setTitle("Pong - Rahaf Haj Ali")
    love.graphics.setBackgroundColor(colors.background)
    fonts.small = love.graphics.newFont(13)
    fonts.body = love.graphics.newFont(16)
    fonts.title = love.graphics.newFont(20)
    fonts.score = love.graphics.newFont(40)
    game = Pong.new()
end

-- Runs each frame: poll held keys and update positions using seconds (dt).
function love.update(dt)
    local direction1, direction2 = 0, 0
    if love.keyboard.isDown("w") then direction1 = direction1 - 1 end
    if love.keyboard.isDown("s") then direction1 = direction1 + 1 end
    if love.keyboard.isDown("up") then direction2 = direction2 - 1 end
    if love.keyboard.isDown("down") then direction2 = direction2 + 1 end
    Pong.update(game, dt, direction1, direction2)
end

function love.keypressed(key)
    if key == "space" then
        Pong.serve(game)
    elseif key == "p" then
        game.paused = not game.paused
    elseif key == "r" then
        game = Pong.new()
    elseif key == "escape" then
        love.event.quit()
    end
end

local function label(text, x, y, color, font)
    love.graphics.setColor(color)
    love.graphics.setFont(font)
    love.graphics.print(text, x, y)
end

-- Runs each frame: draw the state without moving any objects.
function love.draw()
    label("PONG", 30, 20, colors.white, fonts.title)
    label("LOCAL TWO-PLAYER", 30, 49, colors.muted, fonts.small)
    label("RALLY  " .. string.format("%02d", game.rally), 790, 23, colors.white, fonts.body)
    label("BEST  " .. string.format("%02d", game.bestRally), 790, 49, colors.muted, fonts.small)
    love.graphics.setFont(fonts.score)
    love.graphics.setColor(colors.left)
    love.graphics.printf(tostring(game.score1), 340, 16, 100, "center")
    love.graphics.setColor(colors.right)
    love.graphics.printf(tostring(game.score2), 520, 16, 100, "center")
    label(":", 475, 22, colors.muted, fonts.title)

    love.graphics.setColor(colors.court)
    love.graphics.rectangle("fill", 24, game.top, 912, game.bottom - game.top)
    love.graphics.setColor(colors.line)
    love.graphics.setLineWidth(1)
    love.graphics.line(24, game.top, 936, game.top)
    love.graphics.line(24, game.bottom, 936, game.bottom)
    for y = game.top + 8, game.bottom - 8, 24 do
        love.graphics.rectangle("fill", 479, y, 2, 12)
    end
    local p1, p2, ball = game.player1, game.player2, game.ball
    love.graphics.setColor(colors.left)
    love.graphics.rectangle("fill", p1.x, p1.y, p1.width, p1.height, 3, 3)
    love.graphics.setColor(colors.right)
    love.graphics.rectangle("fill", p2.x, p2.y, p2.width, p2.height, 3, 3)
    love.graphics.setColor(colors.white)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height, 2, 2)

    if game.paused or game.waiting then
        local heading = game.paused and "PAUSED" or "READY TO RALLY?"
        local instruction = game.paused and "P to resume" or "SPACE to serve"
        love.graphics.setColor(0.035, 0.055, 0.09, 0.94)
        love.graphics.rectangle("fill", 306, 192, 348, 87, 8, 8)
        love.graphics.setColor(colors.white)
        love.graphics.setFont(fonts.title)
        love.graphics.printf(heading, 306, 206, 348, "center")
        love.graphics.setColor(colors.muted)
        love.graphics.setFont(fonts.body)
        love.graphics.printf(instruction, 306, 239, 348, "center")
    end
    label("PLAYER 1   W / S", 30, 524, colors.left, fonts.body)
    label("PLAYER 2   UP / DOWN", 724, 524, colors.right, fonts.body)
    love.graphics.setColor(colors.muted)
    love.graphics.setFont(fonts.small)
    love.graphics.printf("SPACE  serve     P  pause     R  reset     ESC  quit", 0, 565, 960, "center")
end

-- The recorder can inspect the game. LÖVE ignores this return value.
return {getGame = function() return game end}
