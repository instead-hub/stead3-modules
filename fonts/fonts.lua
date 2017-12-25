-- example module
require "sprite"
require "theme"
local std = stead
local type = std.type
local pairs = std.pairs
local table = std.table

local fnt = std.obj {
	nam = '$fnt';
	{
		faces = {};
	};
	face = function(s, fn, name, size, scaled)
		if type(fn) ~= 'string' then
			std.err("Wrong argument to fnt:face()"..std.tostr(fn), 2)
		end
		if not size then
			size = std.tonum(theme.get 'win.fnt.size')
		end
		if scaled then
			size = sprite.font_scaled_size(size)
		end
		if not name then
			name = theme.get 'win.fnt.name'
		end
		s.faces[fn] = {}
		s.faces[fn].font = sprite.fnt(name, size)
		s.faces[fn].cache = {}
		s.faces[fn].list = {}
	end;
	cache_get = function(s, fn, w, color, t)
		local k = w..color..tostring(t)
		local c = s.faces[fn].cache
		if not c then
			return
		end
		if c[k].time ~= -1 then
			c[k].time = std.game:time()
		end
		return c[k]
	end;
	cache_clear = function(s, fn, age)
		local k, v
		local new_list = {}
		if not age then 
			age = 0 
		end

		local self = s.faces[fn]

		for k, v in ipairs(self.list) do
			local key = v.word..v.color..std.tostr(v.t)
			if v.time ~= -1 and std.game:time() - v.time >= age then
				self.cache[key] = nil
			else
				std.table.insert(new_list, v)
				if v.time ~= -1 then
					s:cache_add(fn, v.word, v.color, v.t, nil) -- renew time
				else
					s:cache_add(fn, v.word, v.color, v.t, -1)
				end
			end
		end
		self.list = new_list
	end;
	cache_add = function(s, fn, w, color, t, key, time)
		local k = w..color..tostring(t)
		local self = s.faces[fn]
		if not self.cache[k] then
			self.cache[k] = {}
			self.cache[k].img = self.font:text(w, color, t);
			self.cache[k].word = w;
			self.cache[k].color = color;
			self.cache[k].t = t;
			self.cache[k].time = std.game:time();
			table.insert(self.list, self.cache[k]);
		end
		if not std.game and not time then
			time = -1
		end
		if time then
			self.cache[k].time = time
		else
			self.cache[k].time = std.game:time(); -- renew time
		end
		return self.cache[k]
	end;
	txt = function(self, fn, txt, color, t)
		local s, e;
		local ss = 1
		local res = ''
		if not color then
			color = theme.get 'win.col.fg'
		end
		if not t then
			t = 0
		end
		while true do
			local start = ss
			while true do
				local s1, e1 = txt:find("\\", ss)
				s, e = txt:find("[ \t\n^]+", ss);
				if not s1 or not s then
					break
				end
				if s1 < s then
					s, e = s1, e1
					ss = s + 2
				else
					break
				end
			end
			ss = start
			local w
			if s then s = s - 1 end
			w = txt:sub(ss, s);
			local c
			if w then
				if s then
					c = txt:sub(s + 1, e)
				end
				w = w:gsub("\\(.)", "%1")
				w = w:gsub("[ \t\n]+$", "");
			end
			if w and w ~= '' and w ~= '\n' then
				self:cache_add(fn, w, color, t)
				res = res .. iface:img(self:cache_get(fn, w, color, t).img);
			end
			if not e then break end
			ss = e + 1
			if not c then c = '' end
			res = res .. c;
		end
		self:cache_add(fn, " ", color, t)
		local space = iface:img(self:cache_get(fn, " ", color, t).img)
		res = res:gsub(" ", space)
		return res;
	end;
	life = function(s)
		if std.me():moved() then
			for k, v in pairs(s.faces) do
				s:cache_clear(k, 2)
			end
		end
	end;
	act = function(s, face, ...)
		local a = {...}
		local txt = table.remove(a, #a)
		return s:txt(face, txt, std.unpack(a));
	end;
}
std.mod_step(function(st)
	if st then
		fnt:life()
	end
end)
