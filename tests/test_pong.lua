local Pong = require("pong")
local passed = 0
local function near(a, b) assert(math.abs(a - b) < 0.001, tostring(a) .. " ~= " .. tostring(b)) end
local function test(name, fn)
    fn()
    passed = passed + 1
    print("PASS " .. name)
end

test("centered ball waits for a serve", function()
    local g = Pong.new()
    near(g.ball.x + g.ball.width / 2, g.width / 2)
    near(g.ball.y + g.ball.height / 2, g.height / 2)
    Pong.update(g, 0.5, 0, 0)
    near(g.ball.dx, 0)
    near(g.ball.x, 473)
end)

test("serve starts both velocity components once", function()
    local g = Pong.new()
    Pong.serve(g)
    assert(not g.waiting and g.ball.dx ~= 0 and g.ball.dy ~= 0)
    Pong.serve(g)
    assert(g.serveNumber == 1)
end)

test("paddle displacement uses elapsed seconds", function()
    local g = Pong.new()
    Pong.update(g, 0.1, 1, -1)
    near(g.player1.y, 288)
    near(g.player2.y, 212)
end)

test("equal motion at 30, 60 and 144 FPS", function()
    for _, fps in ipairs({30, 60, 144}) do
        local g = Pong.new()
        Pong.serve(g)
        for _ = 1, fps / 2 do Pong.update(g, 1 / fps, 0, 0) end
        near(g.ball.x, 473 + 320 * 0.5)
        near(g.ball.y, 293 + 180 * 0.5)
    end
end)

test("both paddles stay inside the playing area", function()
    local g = Pong.new()
    Pong.update(g, 2, -1, 1)
    near(g.player1.y, g.top)
    near(g.player2.y, g.bottom - g.player2.height)
    Pong.update(g, 2, 1, -1)
    near(g.player1.y, g.bottom - g.player1.height)
    near(g.player2.y, g.top)
end)

test("AABB requires overlap on both axes", function()
    local a = {x = 0, y = 0, width = 10, height = 10}
    assert(Pong.overlaps(a, {x = 9, y = 9, width = 10, height = 10}))
    assert(not Pong.overlaps(a, {x = 10, y = 0, width = 10, height = 10}))
    assert(not Pong.overlaps(a, {x = 0, y = 11, width = 10, height = 10}))
end)

test("top wall reverses vertical velocity", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.y, g.ball.dy = 101, -180
    Pong.update(g, 0.02, 0, 0)
    assert(g.ball.dy > 0 and g.ball.y >= g.top)
end)

test("bottom wall reverses vertical velocity", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.y, g.ball.dy = 485, 180
    Pong.update(g, 0.02, 0, 0)
    assert(g.ball.dy < 0 and g.ball.y + g.ball.height <= g.bottom)
end)

test("left paddle bounces and separates the ball", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.x, g.ball.y, g.ball.dx, g.ball.dy = 56, 280, -320, 0
    Pong.update(g, 0.02, 0, 0)
    assert(g.ball.dx > 0 and not Pong.overlaps(g.ball, g.player1))
    assert(g.rally == 1 and g.bestRally == 1)
    Pong.update(g, 0.02, 0, 0)
    assert(g.ball.dx > 0 and g.rally == 1)
end)

test("right paddle bounces and separates the ball", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.x, g.ball.y, g.ball.dx, g.ball.dy = 890, 280, 320, 0
    Pong.update(g, 0.02, 0, 0)
    assert(g.ball.dx < 0 and not Pong.overlaps(g.ball, g.player2))
    assert(g.rally == 1)
end)

test("a slow frame cannot skip through a paddle", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.x, g.ball.y, g.ball.dx, g.ball.dy = 800, 280, 2400, 0
    Pong.update(g, 0.1, 0, 0)
    assert(g.ball.dx < 0 and g.rally == 1 and g.score1 == 0)
end)

test("a missed right paddle awards exactly one point", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.x, g.ball.y, g.ball.dx, g.ball.dy = 955, 120, 320, 0
    Pong.update(g, 0.1, 0, 0)
    assert(g.score1 == 1 and g.score2 == 0 and g.waiting)
    near(g.ball.x, 473)
    Pong.update(g, 0.1, 0, 0)
    assert(g.score1 == 1)
end)

test("a missed left paddle awards player two a point", function()
    local g = Pong.new()
    Pong.serve(g)
    g.ball.x, g.ball.y, g.ball.dx, g.ball.dy = -13, 120, -320, 0
    Pong.update(g, 0.1, 0, 0)
    assert(g.score2 == 1 and g.score1 == 0 and g.waiting)
end)

test("pause freezes the ball and both paddles", function()
    local g = Pong.new()
    Pong.serve(g)
    g.paused = true
    Pong.update(g, 1, 1, -1)
    near(g.ball.x, 473)
    near(g.player1.y, 250)
    near(g.player2.y, 250)
end)

-- Check the actual callbacks and key names without opening a graphics window.
test("keyboard callbacks support W/S, arrows, pause and reset", function()
    local keys = {}
    love = {
        window = {setMode = function() end, setTitle = function() end},
        graphics = {setBackgroundColor = function() end, newFont = function() return {} end},
        keyboard = {isDown = function(key) return keys[key] or false end},
        event = {quit = function() end}
    }
    local app = require("main")
    love.load()
    keys.w, keys.down = true, true
    love.update(0.1)
    near(app.getGame().player1.y, 212)
    near(app.getGame().player2.y, 288)
    keys.w, keys.down, keys.s, keys.up = false, false, true, true
    love.update(0.1)
    near(app.getGame().player1.y, 250)
    near(app.getGame().player2.y, 250)
    love.keypressed("space")
    assert(not app.getGame().waiting)
    love.keypressed("p")
    love.update(1)
    near(app.getGame().player1.y, 250)
    love.keypressed("r")
    assert(app.getGame().waiting and app.getGame().score1 == 0)
end)

print(string.format("%d tests passed.", passed))
