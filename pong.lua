-- Game rules are separate from drawing so they can be tested with plain Lua.
local Pong = {}

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

-- Axis-aligned bounding box collision: overlap must exist on BOTH axes.
function Pong.overlaps(a, b)
    return a.x < b.x + b.width and a.x + a.width > b.x
       and a.y < b.y + b.height and a.y + a.height > b.y
end

function Pong.resetBall(game, direction)
    local ball = game.ball
    ball.x = (game.width - ball.width) / 2
    ball.y = (game.height - ball.height) / 2
    ball.dx, ball.dy = 0, 0
    game.serveDirection = direction or 1
    game.waiting = true
end

function Pong.new()
    return {
        width = 960, height = 600, top = 100, bottom = 500,
        player1 = {x = 38, y = 250, width = 16, height = 100, speed = 380},
        player2 = {x = 906, y = 250, width = 16, height = 100, speed = 380},
        ball = {x = 473, y = 293, width = 14, height = 14, dx = 0, dy = 0},
        score1 = 0, score2 = 0, rally = 0, bestRally = 0,
        waiting = true, paused = false, serveDirection = 1, serveNumber = 0
    }
end

function Pong.serve(game)
    if not game.waiting or game.paused then return end
    game.serveNumber = game.serveNumber + 1
    game.ball.dx = 320 * game.serveDirection
    game.ball.dy = game.serveNumber % 2 == 1 and 180 or -180
    game.rally = 0
    game.waiting = false
end

local function movePaddle(game, paddle, direction, dt)
    -- pixels/second * seconds = displacement in pixels.
    paddle.y = clamp(paddle.y + direction * paddle.speed * dt,
                     game.top, game.bottom - paddle.height)
end

local function bounceFromPaddle(game, paddle, leftPaddle)
    local ball = game.ball
    ball.dx = -ball.dx
    -- Separate after impact to prevent repeated flips inside the paddle.
    if leftPaddle then
        ball.x = paddle.x + paddle.width + 0.01
    else
        ball.x = paddle.x - ball.width - 0.01
    end
    game.rally = game.rally + 1
    game.bestRally = math.max(game.bestRally, game.rally)
end

function Pong.update(game, dt, direction1, direction2)
    if game.paused or dt <= 0 then return end
    direction1 = clamp(direction1 or 0, -1, 1)
    direction2 = clamp(direction2 or 0, -1, 1)
    local ball = game.ball
    -- Small steps prevent tunnelling during slow frames. All dt is used.
    local maxSpeed = math.max(math.abs(ball.dx), math.abs(ball.dy),
                              game.player1.speed, game.player2.speed)
    local steps = math.max(1, math.ceil(dt * maxSpeed / 6))
    local step = dt / steps

    for _ = 1, steps do
        movePaddle(game, game.player1, direction1, step)
        movePaddle(game, game.player2, direction2, step)
        if not game.waiting then
            ball.x = ball.x + ball.dx * step
            ball.y = ball.y + ball.dy * step
            if ball.y < game.top and ball.dy < 0 then
                ball.y = 2 * game.top - ball.y
                ball.dy = -ball.dy
            elseif ball.y + ball.height > game.bottom and ball.dy > 0 then
                ball.y = 2 * (game.bottom - ball.height) - ball.y
                ball.dy = -ball.dy
            end
            if ball.dx < 0 and Pong.overlaps(ball, game.player1) then
                bounceFromPaddle(game, game.player1, true)
            elseif ball.dx > 0 and Pong.overlaps(ball, game.player2) then
                bounceFromPaddle(game, game.player2, false)
            end
            if ball.x + ball.width < 0 then
                game.score2 = game.score2 + 1
                Pong.resetBall(game, -1)
            elseif ball.x > game.width then
                game.score1 = game.score1 + 1
                Pong.resetBall(game, 1)
            end
        end
    end
end

return Pong
