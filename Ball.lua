Ball = Class{}

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dy = math.random(-100, 100) -- math.random(2) == 1 and 100 or -100
	self.dx = 250 -- math.random(-50, 50) * 7.5
end

function Ball:reset(winningPlayer)
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2
	self.dy = math.random(-100, 100) -- math.random(2) == 1 and 100 or -100
	if winningPlayer == 1 then
	    self.dx = -250 -- math.random(-50, 50) * 7.5
	elseif winningPlayer == 2 then
		self.dx = 250
	end
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt 
	self.y = self.y + self.dy * dt
end

function Ball:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:collides(paddle)
	if self.x + self.width >= paddle.x and self.x <= paddle.x + paddle.width 
		and self.y + self.height >= paddle.y and self.y <= paddle.y + paddle.height then
		return true
	else
		return false
	end
end


