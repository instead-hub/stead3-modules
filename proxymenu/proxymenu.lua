require "fmt"

stead.proxy_prefix = '   '

local function proxy_wrap(nam, fwd)
	if not fwd then fwd = nam end
	return function(s, ...)
		local t
		local o = _(s.ref)
		local act = s.acts or { }
		local par = { ... }

		act = act[nam] or nam

		if nam == 'use' then
			local oo = par[1]
			if oo:type 'proxy' then
				oo = _(oo.ref)
				par[1] = oo
			end
		end

		local r, v = std.call(std.game, 'before_'..act, o, std.unpack(par))
		t = std.par(std.scene_delim, t or false, r)
		if v == false then
			return t or r, true
		end

		if nam == 'use' then
			r, v = std.call(par[1], s.acts.used or 'used', o)
			t = std.par(std.scene_delim, t or false, r)
			if v == true then
				oo['__nr_used'] = (oo['__nr_used'] or 0) + 1
				return t or r, true
			end
		end

		r, v = std.call(o, act, std.unpack(par))

		t = std.par(std.scene_delim, t or false, r)

		if type(v) == 'boolean' then
			o['__nr_'..act] = (o['__nr_'..act] or 0) + 1
		end

		if r ~= nil and v == false then -- deny
			return t or r, true
		end

		if v then
			r, v = std.call(std.game, 'after_'..act, o, std.unpack(par))
			t = std.par(std.scene_delim, t or false, r)
		end

		if not t then -- game action
			r, v = std.call(game, act, o, std.unpack(par))
			t = std.par(std.scene_delim, t or false, r)
		end
		return t or r, true
	end
end

std.proxy_obj = std.class ({
	__proxy_type = true;
	new = function(s, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.proxy_obj: "..std.tostr(v), 2)
		end
		if not v.ref then
			std.err ("Wrong argument to std.proxy_obj (no ref attr): "..std.tostr(v), 2)
		end
		if v.use_mode then
			v.__menu_type = false
		end
		v = std.obj (v)
		return v
	end;
	disp = function(s)
		local o = _(s.ref)
		local d = std.dispof(o)
		if type(d) ~= 'string' then
			return d
		end
		if have(o) then
			return stead.proxy_prefix..fmt.em(d)
		end
		return stead.proxy_prefix..d
	end;
	act = proxy_wrap ('act');
	inv = proxy_wrap ('inv');
	use = proxy_wrap ('use');
	menu = proxy_wrap ('menu');
	tak = proxy_wrap ('tak');
}, std.menu)

local function fill_obj(v, s)
	if not v:visible() then
		return nil, false -- do not do it recurse
	end
	if not v:type 'menu' and not std.is_system(v)  then -- usual objects
	-- add to proxy
		local o = { 
			ref = std.nameof(v),
			use_mode = s.use_mode,
			sources = s.sources,
			acts = s.acts,
		}
		s.obj:add(new(proxy_obj, o))
	end
	if v:closed() then
		return nil, false -- do not do it recurse
	end
end

std.proxy_menu = std.class ({
	__proxy_menu_type = true;
	new = function(s, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.proxy_obj: "..std.tostr(v), 2)
		end
		if v.disp then
			v.title = v.disp
			v.disp = nil
		end
		return std.menu(v)
	end;
	disp = function(s)
		local d
		if s.title then
			d = std.call(s, 'title')
		else
			d = std.dispof(s)
		end
--		s:fill()
		if not s:closed() then
			return fmt.u(fmt.b(fmt.nb(d)))
		else
			return fmt.b(fmt.nb(d))
		end
	end;
	menu = function(s) -- open/close
		if not s:closed() then
			s:close()
		else
			std.me().obj:for_each(function (v)
				if v:type 'proxy_menu' and v ~= s then
					v:close()
				end
			end)
			s:open()
		end
		return false
	end;
	fill = function(s) -- fill prox
		s:for_each(function(v)
			delete(v) -- delete obj
		end)
		s.obj:zap()
		-- by default -- all obj
		local src = s.sources or { scene = true }

		if src.inv then
			me():inventory():for_each(function(v)
				fill_obj(v, s)
			end)
		end

		if src.scene then
			std.here():for_each(function(v)
				return fill_obj(v, s)
			end)
		end

		if src.ways then
			std.here().way:for_each(function(v)
				fill_obj(v, s)
			end)
		end

	end;
}, std.menu)

std.menu_player = std.class ({
	__menu_player_type = true;
	new = function(self, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.menu_player: "..std.tostr(v), 2)
		end
		if not v.nam then
			v.nam = 'menu_player'
		end
		if not v.room then
			v.room = 'main'
		end
		v.invent = std.list {}
		return std.player(v)
	end;
	inventory = function(s)
		return s.invent
	end;
}, std.player)

function proxy_obj(v)
	local vv = {
		ref = v.ref;
		use_mode = v.use_mode;
		sources = v.sources;
		acts = v.acts;
	}
	return std.proxy_obj(vv)
end

function proxy_menu(v)
	local vv = {
		nam = v.nam;
		disp = v.disp;
		use_mode = v.use_mode;
		sources = v.sources;
		acts = v.acts;
	}
	return std.proxy_menu(vv):close()
end

std.mod_init(function() -- declarations
	declare 'proxy_obj' (proxy_obj)
	declare 'proxy_menu' (proxy_menu)
end)

std.mod_step(function()
	me().obj:for_each(function(v)
		if v:type 'proxy_menu' then
			v:fill()
		end
	end)
end)
