-- example module
require "timer"

std.cut_text = '>>>'

local function get_token(txt, pos)
	if not pos then 
		pos = 1
	end
	local s,e;
	e = pos
	while true do
		s, e = txt:find("[\\%[]", e);
		if not s then
			break
		end
		if txt:sub(s, s) == '\\' then
			e = e + 2
		else
			break
		end
	end
	local nest = 1
	local ss, ee
	ee = e
	while s do
		ss, ee = txt:find("[\\%[%]]", ee + 1);
		if ss then
			if txt:sub(ss, ss) == '\\' then
				ee = ee + 1
			elseif txt:sub(ss, ss) == '[' then
				nest = nest + 1
			else
				nest = nest - 1
			end
			if nest == 0 then
				return s, ee
			end
		else
			break
		end
	end
	return nil
end

local function parse_token(txt)
	local s, e, t
	t = txt:sub(2, -2)
	local c = t:gsub("^([a-zA-Z]+)[ \t]*.*$", "%1");
	local a = t:gsub("^[^ \t]+[ \t]*(.*)$", "%1");
	if a then a = a:gsub("[ \t]+$", "") end
	return c, a
end

cutscene = function(v)
	v.txt = v.decor

	if v.exit then
		error ("Do not use left in cutscene.", 2)
	end

	v.exit = function(s)
		timer:set(s._timer);
		s:reset()
	end;

	if v.timer then
		error ("Do not use timer in cutscene.", 2)
	end

	v.timer = function(s)
		if not s.__to then
			if game.timer then
				return game:timer()
			end
			return
		end
		instead.fading_value = s.__fading
		s.__state = s.__state + 1
		timer:stop()
		s:step()
	end;

	if not v.pic then
		v.pic = function(s)
			return s.__pic
		end;
	end

	v.reset = function(s)
		s.__state = 1
		s.__code = 1
		s.__fading = nil
		s.__txt = nil
		s.__dsc = nil
		s.__pic = nil
		s.__to = nil
		s.__timer_fn = nil
	end

	v:reset()

	if v.enter then
		error ("Do not use entered in cutscene.", 2)
	end

	v.enter = function(self)
		self:reset()
		self.__timer = timer:get()
		self:step();
	end;

	v.step = function(self)
		local s, e, c, a
		local n = v.__state
		local txt = ''
		local code = 0
		local out = ''
		if not self.__txt then
			if type(self.txt) == 'table' then
				local k,v 
				for k,v in ipairs(self.txt) do
					if type(v) == 'function' then
						v = v()
					end
					txt = txt .. tostring(v)
				end
			else
				txt = stead.call(self, 'txt')
			end
			self.__txt = txt
		else
			txt = self.__txt
		end
		while n > 0 and txt do
			if not e then
				e = 1
			end
			local oe = e
			s, e = get_token(txt, e)
			if not s then
				c = nil
				out = out..txt:sub(oe)
				break
			end
			local strip = false
			local para = false
			c, a = parse_token(txt:sub(s, e))
			if c == "pause" or c == "cut" or c == "fading" then
				n = n - 1
				strip = true
				para = true
			elseif c == "pic" then
				if a == '' then a = nil end
				self.__pic = a
				strip = true
			elseif c == "code" then
				code = code + 1
				if code >= self.__code then
					local f = stead.eval(a)
					if not f then
						error ("Wrong expression in cutscene: "..tostring(a))
					end
					self.__code = self.__code + 1
					f()
				end
				strip = true
			elseif c == "walk" then
				if a and a ~= "" then
					return stead.walk(a)
				end
			elseif c == "cls" then
				out = ''
				strip = true
			end
			if strip then
				out = out..txt:sub(oe, s - 1)
			elseif c then
				out = out..txt:sub(oe, e)
			else
				out = out..txt:sub(oe)
			end
			if para and n == 1 and stead.cut_delim then
				out = out .. std.cut_delim
			end
			e = e + 1
		end
		if stead.cut_scroll then
			out = out..iface.anchor()
		end
		v.__dsc = out
		if c == 'pause' then
			if not a or a == "" then
				a = 1000
			end
			self.__to = tonumber(a)
			timer:set(self.__to)
		elseif c == 'cut' then
			self.__state = self.__state + 1
			if not a or a == "" then
				a = stead.cut_text
			end
			v.__dsc = v.__dsc .. "{#cut|"..a.."}";
		elseif c == "fading" then
			if not a or a == "" then
				a = instead.fading_value
			end
			instead.need_fading(true)
			self.__fading = instead.fading_value
			instead.fading_value = a
			self.__to = 10
			timer:set(self.__to)
		end
	end
	v.decor = function(s)
		if s.__dsc then
			return s.__dsc
		end
	end
	if not v.obj then
		v.obj = {}
	end
	stead.table.insert(v.obj, 1, obj { nam = '#cut', act = function() here():step(); return true; end })
	return room(v)
end
