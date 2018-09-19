head_list = {} -- таблица в которой будут храниться имена персонажей, их айди и аватарки для меню выбора персонажа

data_list = {} -- таблица, содержащая в себе id каждого объекта из data.txt и путь до файла этого объекта
maps_list = {}

loading_list = {"4"} -- список файлов, которые нужно загрузить в память перед началом боя 

entity_list = {} -- массив, хранящий в себе все объекты, находящиеся на сцене


function LoadingBeforeBattle() -- функция вызывается перед началом каждого боя. Она очищает массивы объектов и изображений, затем перебирает список loading_list и загружает в память все файлы и картинки. В конце очищая список файлов на загрузку
-------------------------------------

	for i in pairs(images_list) do
		table.remove(images_list, i)
		collectgarbage()
	end -- очистка списка изображений
	images_list = {}

	for i in pairs(entity_list) do
		table.remove(entity_list, i)
		collectgarbage()
	end -- очистка списка объектов
	entity_list = {}

	for i in pairs(loading_list) do
		table.insert(entity_list, LoadEntity(loading_list[i]))
	end -- цикл последовательной загрузки объектов из списка

	for i in pairs(loading_list) do
		table.remove(loading_list, i)
		collectgarbage()
	end -- очистка списка объектов
	loading_list = {}
end


function CreateDataList() -- вызываемая при запуске игры, функция перебирает файл data.txt, составляя список доступных к загрузке объектов в формате [id] - [путь к файлу]
-------------------------------------

	local data = love.filesystem.read("data.txt")
	for id, file in string.gmatch(data, "id: (%d+)%s+file: ([%w._/]+)")
	do
		if data_list[id] == nil then
			data_list[id] = file
		else
			love.window.showMessageBox( "Duplicate id for file", "["..id .. "] " .. file, "info", true)
		end
	end

end


function LoadEntity(id) -- функция парсинга кода dat файла в возвращаемую таблицу "объекта"
-------------------------------------
	local file = data_list[id] -- помещаем ссылку на загружаемый объект
	local en = {} -- создаём объект

	local dat = love.filesystem.read(file) -- помещаем в строку содержимое файла персонажа

	if not (dat == nil) then -- если датка не пустая, пытаемся её парсить


		-- | Загрузка головной части объекта | --
		
		local head = string.match(dat, "<head>(.*)</head>")
		if not (head == nil) then
			en.name = string.match(head, "name: ([%w_% ]+)")
			en.authorname = string.match(head, "authornamename: ([%w_% ]+)")
			en.type = string.match(head, "type: ([%w]+)")
			en.life = Get(string.match(head, "life: ([%d]+)"))
			en.lifemax = Get(string.match(head, "lifemax: ([%d]+)"))
			--en.weight = Get(string.match(head, "weight: ([%d]+)"))
			--en.physic = Get(string.match(head, "physic: ([%w]+)"))
			
			if(en.physic == "true") then 
				en.physic = true
			else
				en.physic = false 
			end


			-- | Загрузка спрайтовой части объекта | --
			en.sprites = {}
			for s in string.gmatch(head, "sprite: {([^{}]*)}") do
				
				local path = string.match(s, "file: \"(.*)\"")
				local image = LoadImage(path)
				local w = string.match(s, "w: (%d+)")
				local h = string.match(s, "h: (%d+)")
				local row = string.match(s, "row: (%d+)")
				local col = string.match(s, "col: (%d+)")
				local pics = SpriteCutting(w,h,row,col,image)

				local sprites = {
					file = image,
					pics = pics,
					name = path
				}

				table.insert(en.sprites,sprites)
			end
		end

		-- | Загрузка "специальных" переменных | --

		en.vars = {}
		local vars = string.match(dat, "<vars>(.*)</vars>")
		if not (vars == nil) then
			for key, value in string.gmatch(vars, "(%w+): ([%w%d])") do
				en.vars[key] = value
			end
		end


		--| Загрузка фреймов |--

		en.frames = {}
		for f in string.gmatch(dat, "<frame>([^<>]*)</frame>") do
			local frame = {}
			local frame_number = string.match(f, "(%d+)")

			frame.pic = tonumber(Get(string.match(f, "pic: (%d+)")))
			frame.next = tonumber(Get(string.match(f, "next: (-%d+)")))
			frame.wait = tonumber(Get(string.match(f, "wait: (%d+)")))
			frame.centerx = tonumber(Get(string.match(f, "centerx: ([-%d]+)")))
			frame.centery = tonumber(Get(string.match(f, "centery: ([-%d]+)")))
			frame.shadow = tonumber(Get(string.match(f, "shadow: (%d+)")))
			
			frame.collaiders = {}

			for b in string.gmatch(f, "body: {([^{}]*)}") do
				local collaider = {}
				collaider.type = "body"
				collaider.x = tonumber(string.match(b, "x: ([-%d]+)"))
				collaider.y = tonumber(string.match(b, "y: ([-%d]+)"))
				collaider.w = tonumber(string.match(b, "w: ([-%d]+)"))
				collaider.h = tonumber(string.match(b, "h: ([-%d]+)"))
				table.insert(frame.collaiders, collaider)
			end

			for i in string.gmatch(f, "itr: {([^{}]*)}") do
				local collaider = {}
				collaider.type = "itr"
				collaider.x = tonumber(string.match(i, "x: ([-%d]+)"))
				collaider.y = tonumber(string.match(i, "y: ([-%d]+)"))
				collaider.w = tonumber(string.match(i, "w: ([-%d]+)"))
				collaider.h = tonumber(string.match(i, "h: ([-%d]+)"))
				table.insert(frame.collaiders, collaider)
			end

			for p in string.gmatch(f, "platform: {([^{}]*)}") do
				local collaider = {}
				collaider.type = "platform"
				collaider.x = tonumber(string.match(p, "x: ([-%d]+)"))
				collaider.y = tonumber(string.match(p, "y: ([-%d]+)"))
				collaider.w = tonumber(string.match(p, "w: ([-%d]+)"))
				collaider.h = tonumber(string.match(p, "h: ([-%d]+)"))
				table.insert(frame.collaiders, collaider)
			end

			en.frames[frame_number] = frame
		end


		--| Загрузка системных значений |--
		
		en.x = math.random(30.0, 400.0)
		en.y = 100.0
		en.z = 0.0
		en.life = en.max_hp
		en.facing = 1
		en.frame = 1
		en.velocity_x = 0.0
		en.velocity_y = 0.0
		en.velocity_z = 0.0
		en.in_air = false
		en.collisions = {}
		en.test = false

		--| Инициализация стейта,таймера |--
		en.stateno = 5900
		en.prevstateno = nil
		en.time = 0
		

	end

	return en
end


function Get(var)
	local result
	if not (var == nil) then
		result = var
	else
		result = 0
	end
	return result
end



-----------------------------------------------------


function Draw(en)

	local pic = en.data[en.frame].pic
	local x = en.x

	if en.facing == -1 then
		x = x + en.data[en.frame].centerx
	else
		x = x - en.data[en.frame].centerx
	end

	local y = en.y - en.data[en.frame].centery

	local frame
	for s = 1, #en.sprite do
		if pic > #char1.sprite[s].frames then
			pic = pic - #char1.sprite[s].frames
		else
			frame = char1.sprite[s]
		end
	end

	love.graphics.draw(frame.list, frame.frames[pic], x, y, 0, 1 * en.facing, 1)
	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.draw(frame.list, frame.frames[pic], x, en.y * 2 - y, 0, 1 * en.facing, -1, 0, 0, 0.4 * en.facing, 0)
	love.graphics.setColor(255, 255, 255, 1)
end