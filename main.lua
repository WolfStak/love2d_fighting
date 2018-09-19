love.graphics.setDefaultFilter("nearest", "nearest")
entites = require "libs.entites"
sprites = require "libs.sprites"
physics = require "libs.physics"
camera = require "libs.gamera"
love.math.setRandomSeed(love.timer.getTime())


function love.load()
	CreateDataList()
	loading_list = {"4", "2"}
	LoadingBeforeBattle()
end 

function love.update(dt)

	delta_time = dt

	for en_id = 1, #entity_list do
		Gravity(entity_list[en_id])
		Motion(en_id, dt)
	end

	if love.keyboard.isDown("w") then
		entity_list[1].velocity_y = entity_list[1].velocity_y - 0.1
	end
	if love.keyboard.isDown("s") then
		entity_list[1].velocity_y = entity_list[1].velocity_y + 0.1
	end
	if love.keyboard.isDown("a") then
		entity_list[1].velocity_x = entity_list[1].velocity_x - 0.1
		entity_list[1].facing = -1
	end
	if love.keyboard.isDown("d") then
		entity_list[1].velocity_x = entity_list[1].velocity_x + 0.1
		entity_list[1].facing = 1
	end


end 

function love.draw()
	for key, val in pairs(entity_list) do
		DrawEntity(val)

		--| System params debug |--
		fps = love.timer.getFPS( )
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 5)
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 5)
		love.graphics.print("Objects: "..tostring(#entity_list), 10, 20)

		--| Players params debug |--
		wwidth, wheight, wflags = love.window.getMode( )
		love.graphics.print("Life: "..tostring(entity_list[1].life), 10, wheight-20)
		
	end

		love.graphics.print(delta_time, 10, 35)
end 

