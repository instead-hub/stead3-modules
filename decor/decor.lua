require "sprite"
require "theme"
require "click"
loadmod "color2rgb"

local function utf_ff(b, pos)
	if type(b) ~= 'string' or b:len() == 0 then
		return 0
	end
	local utf8 = (std.game.codepage == 'UTF-8' or std.game.codepage == 'utf-8')
	if not utf8 then return 1 end
	local i = pos or 1
	local l = 0
	if b:byte(i) < 0x80 then
		return 1
	end
	i = i + 1
	l = l + 1
	while b:byte(i) >= 0x80 and b:byte(i) <= 0xbf do
		i = i + 1
		l = l + 1
		if i > b:len() then
			break
		end
	end
	return l
end

local cache = {
}

function cache:new(max, ttl)
	local c = {
		cache = {};
		list = {};
		ttl = ttl or 4;
		max = max or 16;
	}
	self.__index = self
	return std.setmt(c, self)
end

function cache:add(name, value)
	local v = self.cache[name]
	if v then
		v.value = value
		v.use = v.use + 1
		return v.value
	end
	v = { name = name, value = value, use = 1 }
	self.cache[name] = v
	table.insert(self.list, 1, v)
	return v.value
end

function cache:get(name)
	local v = self.cache[name]
	if not v then
		return
	end
	v.use = v.use + 1
	return v.value
end

function cache:clear()
	local nr = #self.list
	local list = {}
	if nr <= self.max then
		return
	end
	local todel = nr - self.max
	for k, v in ipairs(self.list) do
		if v.use == 0 and todel > 0 then
			v.ttl = v.ttl - 1
			if v.ttl <= 0 then
				self.cache[v.name] = nil
				if DEBUG then
					dprint("cache purge: "..v.name)
				end
				todel = todel - 1
			else
				table.insert(list, v)
			end
		else
			table.insert(list, v)
		end
	end
	self.list = list
end

function cache:put(name)
	local v = self.cache[name]
	if not v then
		return
	end
	v.use = v.use - 1
	if v.use <= 0 then v.use = 0; v.ttl = self.ttl; end
	--    for k, vv in ipairs(self.list) do
	--	if vv == v then
	--	    table.remove(self.list, k)
	--	    table.insert(self.list, #self.list, v)
	--	    break
	--	end
	--    end
	return v.value
end

local img = {
	cache = cache:new();
}

function img:delete(v)

end

function img:clear()
	self.cache:clear()
end

function img:render(v)
	if v.frames and v.w and v.h then
		local delay = v.delay or 25
		local w, h = v.sprite:size()
		local width = math.floor(w / v.w)
		local height = math.floor(h / v.h)
		local frame = v.frame_nr or 0
		local yy = math.floor(frame / width)
		local xx = math.floor(frame % width)
		v.fx = xx * v.w
		v.fy = yy * v.h
		if instead.ticks() - (v.__delay or 0) >= delay then
			if frame < v.frames - 1 then
				frame = frame + 1
			else
				frame = 0
			end
			v.frame_nr = frame
			v.__delay = instead.ticks()
		end
	end
	if v.background then
		if v.fx and v.fy and v.w and v.h then
			v.sprite:copy(v.fx, v.fy, v.w, v.h, sprite.scr(), v.x - v.xc, v.y - v.yc)
		else
			v.sprite:copy(sprite.scr(), v.x - v.xc, v.y - v.yc)
		end
		return
	end
	if type(v.render) == 'function' then
		v.render(v)
		return
	end
	if v.fx and v.fy and v.w and v.h then
		v.sprite:draw(v.fx, v.fy, v.w, v.h, sprite.scr(), v.x - v.xc, v.y - v.yc, v.alpha)
	else
		v.sprite:draw(sprite.scr(), v.x - v.xc, v.y - v.yc, v.alpha)
	end
end

function img:new_spr(v, s)
	v.xc = v.xc or 0
	v.yc = v.yc or 0
	v.x = v.x or 0
	v.y = v.y or 0
	v.sprite = s
	if not s then
		return v
	end
	local w, h = s:size()
	if v.w then w = v.w end
	if v.h then h = v.h end
	if v.xc == true then
		v.xc = math.floor(w / 2)
	end
	if v.yc == true then
		v.yc = math.floor(h / 2)
	end
	v.w, v.h = w, h
	return v
end

function img:new(v)
	local fname = v[3]
	if type(fname) == 'function' then
		if not std.functions[fname] then
			std.err("Non declared function", 2)
		end
		local s = fname(v)
		if not s then
			std.err("Can not construct sprite", 2)
		end
		return self:new_spr(v, s)
	elseif type(fname) ~= 'string' then
		std.err("Wrong filename in image")
	end
	local s = self.cache:get(fname)
	if not s then
		local sp = sprite.new(fname)
		if not sp then
			std.err("Can not load sprite: "..fname, 2)
		end
		s = self.cache:add(fname, sp)
	end
	self.cache:put(fname)
	return self:new_spr(v, s)
end

local raw = {
}

function raw:delete(v)
end
function raw:clear()
end
function raw:render(v)
	if type(v.render) ~= 'function' then
		return
	end
	v.render(v)
	return
end
function raw:new(v)
	if type(v[3]) == 'function' then
		v[3](v)
		return v
	end
	return v
end

local fnt = {
	cache = cache:new();
}

function fnt:key(name, size)
	return name .. std.tostr(size)
end

function fnt:clear()
	self.cache:clear()
	for k, v in ipairs(self.cache.list) do
		v.value.cache:clear()
	end
end

function fnt:_get(name, size)
	local f = self.cache:get(self:key(name, size))
	if not f then
		local fnt = sprite.fnt(name, size)
		if not fnt then
			std.err("Can not load font", 2)
		end
		f = { fnt = fnt, cache = cache:new(256, 16) }
		self.cache:add(self:key(name, size), f)
	end
	return f
end

function fnt:get(name, size)
	return self:_get(name, size).fnt
end

function fnt:text_key(text, color, style)
	local key = std.tostr(color)..'#'..std.tostr(style or "")..'#'..tostring(text)
	return key
end

function fnt:text(name, size, text, color, style)
	local fn = self:_get(name, size);
	local key = self:text_key(text, color, style)
	local sp = fn.cache:get(key)
	if not sp then
		sp = fn.fnt:text(text, color, style)
		fn.cache:add(key, sp)
	end
	fn.cache:put(key)
	self:put(name, size)
	return sp
end

function fnt:put(name, size)
	self.cache:put(self:key(name, size))
end

local txt_mt = {
}

local txt = {
}

function txt_mt:pages()
	return #self.__pages
end

function txt_mt:page(nr)
	if nr == nil then
		return self.page_nr
	end
	if nr > self:pages() then
		return false
	end
	if nr < 1 then
		return false
	end
	if self.typewriter then
		self.finished = false
	end
	txt:make_page(self, nr)
	return true
end

function txt_mt:next_page()
	if self.typewriter and self.started then
		self.typewriter = false
		txt:make_page(self, self.page_nr or 1)
		self.typewriter = true
		self.started = false
		self.finished = true
		return
	end
	return self:page((self.page_nr or 1) + 1)
end

local function make_align(l, width, t)
	if t == 'left' then
		return
	end
	if t == 'center' then
		local delta = math.floor((width - l.w) / 2)
		for _, v in ipairs(l) do
			v.x = v.x + delta
		end
		return
	end
	if t == 'right' then
		local delta = math.floor(width - l.w)
		for _, v in ipairs(l) do
			v.x = v.x + delta
		end
		return
	end
	if t == 'justify' then
		local n = 0
		for _, v in ipairs(l) do
			if not v.unbreak then
				n = n + 1
			end
		end
		n = n - 1
		if n == 0 then
			return
		end
		local delta = math.floor((width - l.w) / n)
		local ldelta = (width - l.w) % n
		local xx = 0
		for k, v in ipairs(l) do
			if k > 1 then
				if not v.unbreak then
					if k == 2 then
						xx = xx + ldelta
					end
					xx = xx + delta
				end
				v.x = v.x + xx
			end
		end
		return
	end
end

local function parse_xref(str)
	str = str:gsub("^{", ""):gsub("}$", "")
	local h = str:find("|", 1, true)
	if not h then
		return false, str
	end
	local l = str:sub(h + 1)
	h = str:sub(1, h - 1)
	return h, l
end

local function preparse_links(text, links)
	local links = {}
	local link_id = 0

	local s = std.for_each_xref(text,
				    function(str)
					    local h, l = parse_xref(str)
					    if not h then
						    std.err("Wrong xref: "..str, 2)
					    end
					    local o = ""
					    link_id = link_id + 1
					    for w in l:gmatch("[^ \t]+") do
						    if o ~= '' then o = o ..' ' end
						    table.insert(links, {h, w, link_id})
						    o = o .. "\3".. std.tostr(#links)  .."\4"
					    end
					    return o
	end)
	s = s:gsub('\\?'..'[{}]', { ['\\{'] = '{', ['\\}'] = '}' })
	return s, links
end

function txt:make_page(v, nr)
	local page = nr or v.page_nr or 1
	local lines = v.__lines
	local spr = v.sprite
	local size = v.size or std.tonum(theme.get 'win.fnt.size')
	local color = v.color or theme.get('win.col.fg')
	local link_color = v.color_link or theme.get('win.col.link')
	local alink_color = v.color_alink or theme.get('win.col.alink')
	local font = v.font or theme.get('win.fnt.name')
	v.page_nr = page
	if v.w == 0 or v.h == 0 then
		return
	end
	if not v.__spr_blank then
		v.__spr_blank = sprite.new(v.w, v.h)
	end
	local lnr = v.__pages[page]
	v.__spr_blank:copy(v.sprite)
	if #lines == 0 then return end
	local off = lines[lnr].y
	v.__offset = off
	for _ = lnr, #lines do
		local l = lines[_]
		if l.y + l.h - off > v.h or l.pgbrk then
			break
		end
		for _, w in ipairs(l) do
			if not w.spr and w.w > 0 then
				w.spr = fnt:text(font, size, w.txt,
						 w.id and link_color or color, w.style)
			end
			if w.id then -- link
				if not w.link then
					w.link = fnt:text(font, size, w.txt, alink_color, w.style)
				end
			else
				w.link = nil
			end
			if w.spr then
				w.spr:copy(v.sprite, w.x, w.y - off)
			end
		end
	end
	if v.typewriter then
		v.step = 0; -- typewriter effect
		if not v.__spr_blank then
			v.__spr_blank = sprite.new(v.w, v.h)
		end
		if not v.finished then
			v.started = true
			v.finished = false
			v.__spr_blank:copy(v.sprite)
		end
	end
end

function txt:new(v)
	local text = v[3]
	if type(text) == 'function' then
		if not std.functions[text] then
			std.err("Non declared function", 2)
		end
		text = text(v)
	end
	if type(text) ~= 'string' then
		std.err("Wrong text in txt decorator")
	end

	local align = v.align or 'left'
	local style = v.style or 0
	local font = v.font or theme.get('win.fnt.name')
	local intvl = v.interval or std.tonum(theme.get 'win.fnt.height')
	local size = v.size or std.tonum(theme.get 'win.fnt.size')

	local x, y = 0, 0
	v.fnt = fnt:get(font, size)
	local spw, _ = v.fnt:size(" ")

	local next = pixels.new(_, _)

	local r, g, b = color2rgb(v.color or theme.get('win.col.fg'))

	next:fill_poly({0, 0, _ - 1, 0, _ / 2, _ / 2 - 1}, r, g, b)
	next:polyAA({0, 0, _ - 1, 0, _ / 2, _ / 2 - 1}, r, g, b)

	v.btn = next:sprite()

	local lines = {}
	local line = { h = v.fnt:height() }
	local link_list = {}
	local maxw = v.w
	local maxh = v.h
	local W = 0
	local H = 0

	local function newline()
		line.y = y
		line.w = 0
		if #line > 0 then
			line.w = line[#line].x + line[#line].w
		end
		local h = v.fnt:height()
		for _, w in ipairs(line) do
			if w.h > h then
				h = w.h
			end
		end
		y = y + h * intvl
		if y > H then
			H = y
		end
		if #line > 0 then
			if #line == 1 and line[1].txt == '[break]' then line.pgbrk = true end
			table.insert(lines, line)
		end
		line = { h = v.fnt:height() }
		x = 0
		if maxh and y > maxh then
			return true
		end
	end

	local links
	text, links = preparse_links(text)
	local styles = {}
	local ww
	for w in text:gmatch("[^ \t]+") do
		while w and w ~= '' do
			local s, _ = w:find("\n", 1, true)
			if not s then
				ww = w
				w = false
			elseif s > 1 then
				ww = w:sub(1, s - 1)
				w = w:sub(s)
			else -- s == 1
				ww = '\n'
				w = w:sub(2)
			end
			if ww == '\n' then
				newline()
			else
				local t, act
				local applist = {}
				local xx = 0

				while ww and ww ~= '' do
					s, _ = ww:find("\3[0-9]+\4", 1)
					local id
					if s == 1 then
						local n = std.tonum(ww:sub(s + 1, _ - 1))
						local ll = links[n]
						act, t, id = ll[1], ll[2], ll[3]
						ww = ww:sub(_ + 1)
					elseif s then
						t = ww:sub(1, s - 1)
						ww = ww:sub(s)
					else
						t = ww
						ww = false
					end
					while t:find("^%[[ibu]%]") do
						table.insert(styles, t:sub(2, 2))
						t = t:gsub("^%[[ibu]%]", "")
					end

					local st = style

					local m = { b = 1, i = 2, u = 4 }

					for i = 1, #styles do
						st = st + m[styles[i]]
					end

					while t:find("%[/[ibu]%]$") do
						table.remove(styles, #styles)
						t = t:gsub("%[/[ibu]%]$", "")
					end
					local width, height = v.fnt:size(t, st)
					if height > line.h then
						line.h = height
					end

					if t == '[pause]' then
						width = 0
					end

					local witem = { style = st,
							action = act, id = id, x = xx, y = y,
							w = width, h = height, txt = t }
					if id then
						table.insert(link_list, witem)
					end
					table.insert(applist, witem)
					xx = xx + width
				end
				local sx = 0;

				if maxw and x + xx + spw > maxw and #line > 0 then
					newline()
				else
					sx = x
				end

				for k, v in ipairs(applist) do
					v.y = y
					v.x = v.x + sx
					x = v.x + v.w
					if k ~= 1 then
						v.unbreak = true
					end
					v.line = line
					table.insert(line, v)
				end
				if #applist > 0 then
					for i = #applist, 1, -1 do
						if applist[i].w > 0 then
							x = x + spw
							break
						end
					end
				end
				if x > W then
					W = x
				end
			end
		end
	end

	if #line > 0 then
		newline()
	end

	if (maxw or W) ~= 0 and (maxh or H) ~= 0 then
		v.sprite = sprite.new(maxw or W, maxh or H)
	end
	local pages = {}
	local off = 0;
	if #lines >= 1 then
		table.insert(pages, 1)
	end
	local brk
	for _, l in ipairs(lines) do
		l.page = #pages
		if l.pgbrk then
			brk = true
		elseif (l.y + l.h - off > (maxh or H)) or brk then
			off = l.y
			table.insert(pages, _)
			brk = false
		else
			make_align(l, maxw or W, align)
			brk = false
		end
	end
	v.__pages = pages
	v.__lines = lines
	v.__link_list = link_list
	if v.sprite then
		v.w, v.h = v.sprite:size()
	else
		v.w, v.h = 0, 0
	end
	if #link_list > 0 or #pages > 1 then
		v.click = true
	end
	std.setmt(v, txt_mt)
	txt_mt.__index = txt_mt
	self:make_page(v)
	return img:new_spr(v, v.sprite)
end

function txt:make_tw(v, step)
	local n = 0
	local spr = v.sprite
	local lnr = v.__pages[v.page_nr]
	for _ = lnr, #v.__lines do
		if n >= step then
			break
		end
		local l = v.__lines[_]
		if l.y + l.h - v.__offset > v.h or l.pgbrk then
			v.started = false
			v.finished = true
			break
		end
		for _, w in ipairs(l) do
			if n >= step then
				break
			end
			if w.txt:len() + n <= step then
				n = n + w.txt:len()
				n = n + 1
				if n >= step and w.spr then
					w.spr:copy(spr, w.x, w.y - v.__offset)
				end
			else
				local nm = step - n
				local i = 1
				while i < nm do
					i = i + utf_ff(w.txt, i)
				end
				step = step + i - nm
				local txt = w.txt:sub(1, i - 1)
				local ww, hh = v.fnt:size(txt)
				if w.spr then
					if type(decor.beep) == 'function' then
						decor.beep(v)
					end
					w.spr:copy(0, 0, ww, hh, spr, w.x, w.y - v.__offset)
				end
				n = step
			end
		end
	end
	v.step = n
	if n < step then
		v.started = false
		v.finished = true
	end
	return step > n
end

function txt:link(v, x, y)
	if v.typewriter and v.started then
		return
	end
	local off = v.__offset or 0
	y = y + off

	for _, w in ipairs(v.__link_list) do
		if w.line.page == (v.page_nr or 1) then
			if x >= w.x and y >= w.y then
				if x < w.x + w.w and y < w.y + w.h then
					return w, _
				end
				local next = v.__link_list[_ + 1]
				if next and next.id == w.id and
				x < next.x and y < next.y + next.h then
					return w, _
				end
			end
		end
	end
end

function txt:click(v, press, x, y)
	local w = self:link(v, x, y)
	if w then
		return std.cmd_parse(w.action)
	end
	return {}
end

function txt:render(v)
	if v.w == 0 or v.h == 0 then
		return
	end
	if v.typewriter and v.started then
		local d = instead.ticks() - (v.__last_tw or 0)
		decor.dirty = true
		if d > (v.delay or 25) then
			v.__last_tw = instead.ticks()
			v.step = (v.step or 0) + (v.speed or 1)
			txt:make_tw(v, v.step)
		end
		img:render(v)
		return
	end
	local x, y = instead.mouse_pos()
	x = x - v.x + v.xc
	y = y - v.y + v.yc
	local w = txt:link(v, x, y)

	local action = w and w.action or false
	local id = w and w.id or false

	for _, w in ipairs(v.__link_list) do
		if w.line.page == (v.page_nr or 1) then
			if w.id == id then
				if not w.__active then
					w.__active = true
					w.link:copy(v.sprite, w.x, w.y - v.__offset)
				end
			else
				if w.__active then
					w.__active = false
					w.spr:copy(v.sprite, w.x, w.y - v.__offset)
				end
			end
		end
	end
	img:render(v)
	if v:page() < v:pages() and v.btn then
		local w, h = v.btn:size()
		v.btn:draw(sprite.scr(), v.x + v.w - v.xc - w, v.y + v.h - v.yc - h)
	end
end

function txt:delete(v)
	if v.sprite then
		fnt:put(v.font or theme.get('win.fnt.name'), v.size)
	end
end

decor = obj {
	nam = '@decor';
	{
		img = img;
		fnt = fnt;
		txt = txt;
		raw = raw;
		dirty = false;
		objects = {
		}
	};
	bgcol = 'black';
}
--[[
	decor:img{ 'hello', 'img' }
]]--

function decor:zap()
	local l = {}
	for k, v in pairs(self.objects) do
		table.insert(l, k)
	end
	for _, name in ipairs(l) do
		local tt = self.objects[name].type
		self[tt]:delete(self.objects[name])
		self.objects[name] = nil
	end
end

function decor:new(v)
	if type(v) == 'string' then
		v = self.objects[v]
	end
	local name = v[1]
	local t = v[2]
	if not v.z then
		v.z = 0
	end
	if type(name) ~= 'string' then
		std.err("Wrong parameter to decor:new(): name", 2)
	end
	if self.objects[name] then
		local tt = self.objects[name].type
		self[tt]:delete(self.objects[name])
	end
	if t == nil then
		self.objects[name] = nil
		return
	end
	if type(t) ~= 'string' then
		std.err("Wrong parameter to decor:new(): type", 2)
	end
	if not self[t] or type(self[t].new) ~= 'function' then
		std.err("Wrong type decorator: "..t, 2)
	end
	v.name = name
	v.type = t
	self.objects[name] = self[t]:new(v)
	return v
end;

function decor:get(n)
	if type(n) ~= 'string' then
		std.err("Wrong parameter to decor:get(): name", 2)
	end
	return self.objects[n]
end

local after_list = {}

function decor:process()
	local t = instead.ticks()
	for _, v in pairs(self.objects) do
		if not v.hidden and type(v.process) == 'function' then
			decor.dirty = true
			if t - (v.__last_time or 0) > (v.speed or 25) then
				v:process()
				v.__last_time = t
			end
		end
		if v.frames then decor.dirty = true end
	end
end

function decor:render()
	local list = {}
	if not decor.dirty then
		return
	end
	decor.dirty = false
	after_list = {}
	for _, v in pairs(self.objects) do
		local z = v.z or 0
		if not v.hidden then
			if z >= 0 then
				table.insert(list, v)
			else
				table.insert(after_list, v)
			end
		end
	end
	table.sort(list, function(a, b)
			   if a.z == b.z then return a.name < b.name end
			   return a.z > b.z
	end)
	table.sort(after_list, function(a, b)
			   if a.z == b.z then return a.name < b.name end
			   return a.z > b.z
	end)
	sprite.scr():fill(self.bgcol)
	for _, v in ipairs(list) do
		self[v.type]:render(v)
	end
end
std.mod_init(function(s)
local oldrender = sprite.render_callback()
sprite.render_callback(
	function()
		for _, v in ipairs(after_list) do
			decor[v.type]:render(v)
		end
		if oldrender then
			oldrender()
		end
end)
end)

function decor:click_filter(press, x, y)
	local c = {}
	for _, v in pairs(self.objects) do
		if v.click and x >= v.x - v.xc and y >= v.y - v.yc and
		x < v.x - v.xc + v.w and y < v.y - v.yc + v.h then
			if v[2] == 'txt' then
				if not press then
					table.insert(c, v)
				end
			else
				table.insert(c, v)
			end
		end
	end
	if #c == 0 then
		return false
	end
	local e = c[1]
	for _, v in ipairs(c) do
		if v.z == e.z then
			if v.name > e.name then
				e = v
			end
		elseif v.z < e.z then
			e = v
		end
	end
	return e
end

function decor:cache_clear()
	self.img:clear();
	self.fnt:clear();
end

function decor:load()
	--	for _, v in pairs(self.fonts) do
	--		self:fnt(v)
	--	end
	--	for _, v in pairs(self.sprites) do
	--		self:spr(v)
	--	end
	for _, v in pairs(self.objects) do
		self:new(v)
	end
end
std.mod_cmd(
	function(cmd)
		if cmd[1] ~= '@decor_click' then
			return
		end
		local nam = cmd[2]
		local e = decor.objects[nam]
		local t = e[2]
		local press, x, y, btn = cmd[3], cmd[4], cmd[5], cmd[6]
		local r, v
		local a
		if type(decor[t].click) == 'function' then
			a = decor[t]:click(e, press, x, y, btn)
		else
			a = { }
		end
		table.insert(a, 1, nam)
		table.insert(a, 2, press)
		table.insert(a, 3, x - e.xc)
		table.insert(a, 4, y - e.yc)
		table.insert(a, 5, btn)

		local r, v = std.call(std.here(), 'ondecor', std.unpack(a))
		if not r and not v then
			r, v = std.call(std.game, 'ondecor', std.unpack(a))
		end
		if not r and not v then
			return nil, false
		end
		return r, v
end)
std.mod_start(
	function(load)
		if load then
			for k, _ in pairs(theme.vars) do
				theme.restore(k)
			end
		end
		theme.set('scr.gfx.scalable', 5)
		instead.wait_use(false)
		instead.grab_events(true)
		if load then
			sprite.scr():fill(decor.bgcol)
			decor:load()
		end
		decor:render()
end)

std.mod_step(
	function(state)
		if not state then
			if std.cmd[1] == '@timer' then
				decor:cache_clear()
				decor:process()
				decor:render()
			end
			return
		end
		if not iface:raw_mode() then -- debugger?
			decor:cache_clear()
			decor:process()
			decor:render()
		end
end)

local input = std.ref '@input'
local clickfn = input.click

function input:click(press, btn, x, y, px, py, ...)
	local e = decor:click_filter(press, x, y)
	if e then
		x = x - e.x + e.xc
		y = y - e.y + e.yc
		local a
		for _, v in std.ipairs {e[1], press, x, y, btn} do
			a = (a and (a..', ') or ' ') .. std.dump(v)
		end
		return '@decor_click'.. (a or '')
	end
	if clickfn then
		return clickfn(input, press, btn, x, y, px, py, ...)
	end
	return false
end

function D(n)
	decor.dirty = true
	if n == nil then
		return decor:zap()
	end
	if type(n) == 'table' then
		return decor:new(n)
	end
	return decor:get(n)
end

function T(nam, val)
	if val then
		return theme.set(nam, tostring(val))
	else
		return theme.get(nam)
	end
end

std.mod_save(function(fp)
		fp:write(string.format("std'@decor'.objects = %s\n", std.dump(decor.objects, false)))
end)
