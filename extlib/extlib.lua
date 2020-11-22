local mrd = require "morph/mrd"
local lang = require "morph/lang-ru"
local type = type

local ex = { shortcut = {}, msg = {} }
local function pfmt(...)
	p(std.exfmt(...))
end

function ex.save_ctx()
	return {
		first = std.first,
		second = std.second,
		first_hint = std.first_hint,
		second_hint = std.second_hint,
	}
end

function ex.restore_ctx(ctx)
	std.first, std.second = ctx.first, ctx.second
	std.first_hint, std.second_hint = ctx.first_hint, ctx.second_hint
end

local function pnoun(noun, ...)
	local ctx = ex.save_ctx()
	std.first = noun
	std.first_hint = noun:gram().hint
	local r = std.exfmt(...)
	ex.restore_ctx(ctx)
	return r
end

std.mod_init(function()
	mrd:init(lang)
end)

function std.obj:hint(hint)
	return self:gram()[mrd.lang.gram_t[hint] or hint]
end

local function str_strip(str)
	return std.strip(str)
end

local function str_split(str, delim)
	local a = std.split(str, delim)
	for k, _ in ipairs(a) do
		a[k] = str_strip(a[k])
	end
	return a
end

function std.obj:attr(str)
	local a = str_split(str, ", ")
	for _, v in ipairs(a) do
		local val =  (v:find("~", 1, true) ~= 1)
		v = v:gsub("^~", "")
		self['__attr__' .. v] = val
	end
	return self
end

function std.obj:hasnt(attr)
	return not self:has(attr)
end

function std.obj:has(attr)
	attr = std.strip(attr)
	local val =  (attr:find("~", 1, true) ~= 1)
	attr = attr:gsub("^~", "")
	if val then
		return self['__attr__' .. attr]
	else
		return not self['__attr__' .. attr]
	end
end
local table = std.table

std.room.display = function(s)
	local deco = std.call(s, 'decor'); -- static decorations
	return std.par(std.scene_delim, deco or false, std.obj.display(s))
end

std.obj.display = function(s)
	local r
	local after = {}
	if s:closed() then
		return
	end
	for i = 1, #s.obj do
		if r then
			r = r .. std.space_delim
		end
		local o = s.obj[i]
		if o:visible() then
			local dsc = std.call(o, 'dsc')
			if type(dsc) ~= 'string' then
				if o:hasnt'concealed' then
					table.insert(after, o)
				end
			else
				local disp = o:display()
				local d = o:__xref(std.par(' ', dsc, disp))
				if type(d) == 'string' then
					r = (r or '').. d
				end
			end
		end
	end
	if #after == 0 then
		return r
	end
	if r then
		r = r .. std.scene_delim
	end
	if std.here() == s then
		r = (r or '').. mrd.lang.cap(ex.msg.HERE) .. ' '
	else
		if s:has 'supporter' then
			r = (r or '').. pnoun(s, ex.msg.ON) .. ' '
		elseif s:has 'container' then
			r = (r or '').. pnoun(s, ex.msg.IN) .. ' '
		end
	end
	if #after > 1 or after[1]:hint'plural' then
		r = r .. ex.msg.ARE
		if #after > 1 then
			r = r .. ': '
		else
			r = r .. ' '
		end
	else
		r = r .. ex.msg.IS ..' '
	end
	for i = 1, #after do
		local o = after[i]
		local disp = '{'..std.nameof(o)..'|'..std.dispof(o)..'}'
		if o:has'openable' and not o:closed() then
			disp = disp .. " ("..pnoun(o, ex.msg.IS_OPENED)..")"
		end
		local d = o:__xref(disp);
		if i > 1 then
			if i == #after then
				r = r .. ' '..ex.msg.AND .. ' '
			else
				r = r .. ', '
			end
		end
		if type(d) == 'string' then
			r = (r or '').. d
		end
	end
	r = r .. '.'
	for i = 1, #after do
		local o = after[i]
		if not o:closed() or o:has'transparent' or o:has'supporter' then
			local d = o:display()
			if type(d) == 'string' then
				r = (r and (r .. std.space_delim) or '') .. d
			end
		end
	end
	return r
end

std.obj.tak = function(s)
	if s:has'item' then
		pfmt(ex.msg.TAKE)
		return
	end
	return false
end

std.obj.act = function(s)
	local u = std.call(s, 'onact')
	if u then
		return u
	end
	if s:has'openable' then
		if s:closed() then
			pfmt(ex.msg.OPEN)
			s:open()
		else
			pfmt(ex.msg.CLOSE)
			s:close()
		end
		return
	end
	if s:has'switchable' then
		if s:has'on' then
			pfmt(ex.msg.SWITCHOFF)
			s:attr'~on'
		else
			pfmt(ex.msg.SWITCHON)
			s:attr'on'
		end
		return
	end
	pfmt(ex.msg.EXAM)
end

std.obj.inv = function(s)
	local u = std.call(s, 'oninv')
	if u then
		return u
	end
	pfmt(ex.msg.EXAM)
end

std.obj.use = function(s, w)
	local u = std.call(s, 'onuse', w)
	if u then
		return u
	end
	if s:has'item' then
		if w:has'supporter' then
			pfmt(ex.msg.PUTON)
			place(s, w)
			return
		elseif w:has'container' then
			if w:closed() then
				pfmt(ex.msg.PUTCLOSED)
				return
			end
			pfmt(ex.msg.INSERT)
			place(s, w)
			return
		end
	end
	return false
end

std.callpush = function(v, w, ...)
        std.call_top = std.call_top + 1;
	if std.call_top == 1 then
		std.first = v
		std.second = w
		std.first_hint = v and v:gram().hint
		std.second_hint = std.is_obj(w) and w:gram().hint
	end
        std.call_ctx[std.call_top] = { txt = nil, self = v };
end

function std.shortcut_obj(ob)
	if ob == '#first' then
		ob = std.first
	elseif ob == '#second' then
		ob = std.second
	elseif ob == '#firstwhere' then
		ob = std.first:where()
	elseif ob == '#secondwhere' then
		ob = std.second:where()
	elseif ob == '#me' then
		ob = std.me()
	elseif ob == '#where' then
		ob = std.me():where()
	elseif ob == '#here' then
		ob = std.here()
	else
		ob = false
	end
	return ob
end

local function shortcut(ob, hint)
	return ob:noun(hint)
end

function ex.shortcut.where(hint)
	return shortcut(std.me():where(), hint)
end

function ex.shortcut.firstwhere(hint)
	return shortcut(std.first:where(), hint)
end

function ex.shortcut.secondwhere(hint)
	return shortcut(std.second:where(), hint)
end

function ex.shortcut.here(hint)
	return shortcut(std.here(), hint)
end

function ex.shortcut.first(hint)
	return shortcut(std.first, hint)
end

function ex.shortcut.firstit(hint)
	return std.first:it(hint)
end

function ex.shortcut.second(hint)
	return shortcut(std.second, hint)
end

function ex.shortcut.me(hint)
	return shortcut(std.me(), hint)
end

local function hint_append(hint, h)
	if h == "" or not h then return hint end
	if hint == "" or not hint then return h end
	return hint .. ',' .. h
end

function ex.shortcut.word(hint)
	local w = str_split(hint, ",")
	if #w == 0 then
		return hint
	end
	local verb = w[1]
	table.remove(w, 1)
	hint = ''
	for _, k in ipairs(w) do
		if k == '#first' then
			hint = hint_append(hint, std.first_hint)
		elseif k == '#second' then
			hint = hint_append(hint, std.second_hint)
		elseif k:find("#", 1, true) == 1 then
			local ob = std.shortcut_obj(k)
			if not ob then
				std.err("Wrong shortcut word: "..k, 2)
			end
			hint = hint_append(hint, ob:gram().hint)
		else
			hint = hint_append(hint, k)
		end
	end
	local t = mrd:noun(verb .. '/' .. hint)
	return t
end

function ex.shortcut.if_hint(hint)
	local w = str_split(hint, ",")
	if #w < 3 then
		return hint
	end
	local attr = w[2]
	local ob = w[1]
	ob = std.shortcut_obj(ob)
	if not ob then
		std.err("Wrong object in if_has shortcut: "..hint, 2)
	end
	if not ob:hint(attr) then
		return w[4] or ''
	end
	return w[3] or ''
end

function ex.shortcut.if_has(hint)
	local w = str_split(hint, ",")
	if #w < 3 then
		return hint
	end
	local attr = w[2]
	local ob = w[1]
	ob = std.shortcut_obj(ob)
	if not ob then
		std.err("Wrong object in if_has shortcut: "..hint, 2)
	end
	if not ob:has(attr) then
		return w[4] or ''
	end
	return w[3] or ''
end

function std.exfmt(...)
	local args = {}
	for _, v in ipairs({...}) do
		local finish
		if type(v) == 'string' then
		repeat
			finish = true
			v = v:gsub("{#[^{}]*}", function(w)
				local ww = w
				w = w:gsub("^{#", ""):gsub("}$", "")
				local hint = w:gsub("^[^/]*/?", "")
				w = w:gsub("/[^/]*$", "")
				local cap = mrd.lang.is_cap(w)
				w = w:lower()
				if ex.shortcut[w] then
					w = ex.shortcut[w](hint)
					if cap then
						w = mrd.lang.cap(w)
					end
				else
					std.err("Wrong shortcut: ".. ww, 2)
				end
				finish = false
				return w
			end)
		until finish
		end
		table.insert(args, v)
	end
	local ret
	for i = 1, #args do
		ret = std.par('', ret or false, std.tostr(args[i]));
	end
	return ret
end

return ex
