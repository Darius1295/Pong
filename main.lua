push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 100
PADDLE_ACCELERATION = 2500

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true
		})

    message = 'Hello Pong!'

	player1Score = 0
	player2Score = 0

	winningPlayer = 1

    player1 = Paddle(10, 30, 5, 30)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 30)

    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    dtotal = 0
    dtotal2 = 0
    dtotal3 = 0

	gameState = 'start'
end

function love.update(dt)
	dtotal = dtotal + dt
	error_num = math.random(-8, 8)
	if dtotal > math.random(0.05, 0.2) then
		dtotal = 0
		if ball.y + ball.height/2 + error_num < player1.y + 0.2*player1.height then --if love.keyboard.isDown('w') then
		    dtotal2 = dtotal2 + dt 
			player1.dy = -PADDLE_SPEED - 0.5 * PADDLE_ACCELERATION * (dtotal2)^2
		elseif ball.y + ball.height/2 + error_num > player1.y + 0.8*player1.height then --elseif love.keyboard.isDown('s') then
		    dtotal2 = dtotal2 + dt  
			player1.dy = PADDLE_SPEED + 0.5 * PADDLE_ACCELERATION * (dtotal2)^2
		else
			player1.dy = 0
			dtotal2 = 0
		end
	end
    
    --[[ error_num = math.random(-5, 5)
    if ball.y + ball.height/2 + error_num < player1.y + 0.8*player1.height and ball.y + ball.height/2 + error_num > player1.y + 0.2*player1.height then
        player1.dy = 0
    end --]]

	if love.keyboard.isDown('up') then
	    dtotal3 = dtotal3 + dt  
		player2.dy = math.max(-PADDLE_SPEED - 0.5 * PADDLE_ACCELERATION * (dtotal3)^2, -500)
	elseif love.keyboard.isDown('down') then
	    dtotal3 = dtotal3 + dt 
		player2.dy = math.min(PADDLE_SPEED + 0.5 * PADDLE_ACCELERATION * (dtotal3)^2, 500)
	else
		player2.dy = 0
		dtotal3 = 0
	end

	if gameState == 'play' then 
        if ball:collides(player1) then
        	ball.x = ball.x + player1.width
        	-- speed2 = ball.dx^2 + ball.dy^2
        	ball.dx = -ball.dx + 10
        	ball.dy = ((ball.y - (player1.y + player1.height/2)) / (player1.height/2)) * ball.dx
        end
        if ball:collides(player2) then
        	ball.x = ball.x - player1.width
        	-- speed2 = ball.dx^2 + ball.dy^2 
        	ball.dx = -ball.dx - 10
        	ball.dy = ((ball.y - (player2.y + player2.height/2)) / (player2.height/2)) * -ball.dx   
        end

        if ball.y < 0 then
        	ball.y = ball.y + ball.height
        	ball.dy = -ball.dy
        end
        if ball.y + ball.height > VIRTUAL_HEIGHT then
        	ball.y = ball.y - ball.height
        	ball.dy = -ball.dy
        end

        if ball.x + ball.width > VIRTUAL_WIDTH then
        	player1Score = player1Score + 1
        	ball:reset(winningPlayer)
        end
        if ball.x < 0 then
        	player2Score = player2Score + 1
        	ball:reset(winningPlayer)
        end

        if player1Score > player2Score then
        	winningPlayer = 1
        else
        	winningPlayer = 2
        end

        if player1Score == 5 then
        	gameState = 'start'
        	message = 'Player 1 Wins!'
        end
        if player2Score == 5 then
        	gameState = 'start'
        	message = 'Player 2 Wins!'
        end

        ball:update(dt)
	end

	player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then 
		love.event.quit()
	elseif key == 'enter' or key == 'return' then 
		if gameState == 'start' then
		    player1Score = 0
		    player2Score = 0
		    message = '' 
		    gameState = 'play'
		else
		    gameState = 'start'
            ball:reset()
	    end
	end
end

function love.draw()
	push:apply('start')

	love.graphics.clear(0.2, 0.21, 0.3, 1)

    love.graphics.setFont(smallFont)
	love.graphics.printf(message, 0, 20, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

	ball:render()
	player1:render()
	player2:render()

	displayFPS()
	displaySpeed()

	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displaySpeed()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('Player 2 speed: ' .. tostring(player2.dy), VIRTUAL_WIDTH - 100, 10)
end
