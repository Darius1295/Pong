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

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

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

	gameState = 'menu'
	modeSelect = 1
end

function love.update(dt)
 	dtotal = dtotal + dt
	error_num = math.random(-8, 8)
	if modeSelect == 1 then
		if dtotal > math.random(0.05, 0.2) then
			dtotal = 0
			if ball.y + ball.height/2 + error_num < player1.y + 0.2*player1.height then 
			    dtotal2 = dtotal2 + dt 
				player1.dy = -PADDLE_SPEED - 0.5 * PADDLE_ACCELERATION * (dtotal2)^2
			elseif ball.y + ball.height/2 + error_num > player1.y + 0.8*player1.height then
			    dtotal2 = dtotal2 + dt  
				player1.dy = PADDLE_SPEED + 0.5 * PADDLE_ACCELERATION * (dtotal2)^2
			else
				player1.dy = 0
				dtotal2 = 0
			end
		end
	elseif modeSelect == 2 then
		if love.keyboard.isDown('w') then
	        dtotal2 = dtotal2 + dt  
		    player1.dy = math.max(-PADDLE_SPEED - 0.5 * PADDLE_ACCELERATION * (dtotal2)^2, -500)
	    elseif love.keyboard.isDown('s') then
	        dtotal2 = dtotal2 + dt 
		    player1.dy = math.min(PADDLE_SPEED + 0.5 * PADDLE_ACCELERATION * (dtotal2)^2, 500)
	    else
		    player1.dy = 0
		    dtotal2 = 0
		end
	end 

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
        	sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
        	ball.x = ball.x - player1.width
        	-- speed2 = ball.dx^2 + ball.dy^2 
        	ball.dx = -ball.dx - 10
        	ball.dy = ((ball.y - (player2.y + player2.height/2)) / (player2.height/2)) * -ball.dx
        	sounds['paddle_hit']:play()   
        end

        if ball.y < 0 then
        	ball.y = ball.y + ball.height
        	ball.dy = -ball.dy
        	sounds['wall_hit']:play()
        end
        if ball.y + ball.height > VIRTUAL_HEIGHT then
        	ball.y = ball.y - ball.height
        	ball.dy = -ball.dy
        	sounds['wall_hit']:play()
        end

        if ball.x + ball.width > VIRTUAL_WIDTH then
        	sounds['score']:play()
        	player1Score = player1Score + 1
        	ball:reset(winningPlayer)
        end
        if ball.x < 0 then
        	sounds['score']:play()
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
    if gameState == 'menu' then
    	if key == 'up' or key == 'w' then
    	    modeSelect = 1
    	elseif key == 'down' or key =='s' then
    		modeSelect = 2
    	end
    end

	if key == 'escape' then 
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
	    if gameState == 'menu' then
	        gameState = 'instructions'  
		elseif gameState == 'start' then
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

	if gameState == 'menu' then
		love.graphics.setFont(scoreFont)
		love.graphics.printf('PONG', 0, 20, VIRTUAL_WIDTH, 'center')

		love.graphics.setFont(smallFont)
		love.graphics.printf('Choose a mode:', 0, 100, VIRTUAL_WIDTH, 'center')
		if modeSelect == 1 then
		    love.graphics.printf('> 1 Player', -4, 120, VIRTUAL_WIDTH, 'center')
		    love.graphics.printf('2 Player', 0, 140, VIRTUAL_WIDTH, 'center')
		elseif modeSelect == 2 then
			love.graphics.printf('1 Player', 0, 120, VIRTUAL_WIDTH, 'center')
		    love.graphics.printf('> 2 Player', -4, 140, VIRTUAL_WIDTH, 'center')
		end

	elseif gameState == 'instructions' then
		if modeSelect == 1 then
		    love.graphics.setFont(smallFont)
		    love.graphics.printf('You are player 2', 0, 100, VIRTUAL_WIDTH, 'center')
		    love.graphics.printf("Press up arrowkey to move up, down arrowkey to move down", 0, 120, VIRTUAL_WIDTH, 'center')
		    love.graphics.printf('First person to get 5 points wins', 0, 140, VIRTUAL_WIDTH, 'center')
		elseif modeSelect == 2 then
			love.graphics.setFont(smallFont)
			love.graphics.printf("Player 1: Press 'w' to move up, 's' to move down" , 0, 100, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Player 2: Press up arrowkey to move up, down arrowkey to move down", 0, 120, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('First person to get 5 points wins', 0, 140, VIRTUAL_WIDTH, 'center')             
        end
    else 
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
	end

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
