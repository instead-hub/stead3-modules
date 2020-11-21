if not instead.tiny then
local std = stead
local iface = std.ref '@iface'
require 'sprite'
local theme = std.ref '@theme'
local xrt = {
	'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
	'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
	'u', 'v', 'w', 'x', 'y', 'z',
}

local xrs = {}
local ixrs = {}
local xrm = {}
local style = 1 -- bold
local scale = 0.7
local function load_fn()
	local size = std.tonum(theme.get 'win.fnt.size')
	size = sprite.font_scaled_size(size * scale)
	local name = theme.get 'win.fnt.name'
	local fnt = sprite.fnt(name, size)
	local color = theme.get 'win.col.fg'
	for i, v in ipairs(xrt) do
		xrs[i] = fnt:text(' '..v, color, style);
		xrm[v] = i
	end
	size = std.tonum(theme.get 'inv.fnt.size')
	size = sprite.font_scaled_size(size * scale)
	name = theme.get 'inv.fnt.name'
	fnt = sprite.fnt(name, size)
	color = theme.get 'inv.col.fg'
	for i, v in ipairs(xrt) do
		ixrs[i] = fnt:text(' '..v, color, style);
	end

end

local dict = {}
local links = {}
function iface:xref(str, o, ...)
	if type(str) ~= 'string' then
		std.err ("Wrong parameter to iface:xref: "..std.tostr(str), 2)
	end
	if not std.is_obj(o) or std.is_obj(o, 'stat') then
		return str
	end
	local a = { ... }
	local args = ''
	for i = 1, #a do
		if type(a[i]) ~= 'string' and type(a[i]) ~= 'number' then
			std.err ("Wrong argument to iface:xref: "..std.tostr(a[i]), 2)
		end
		args = args .. ' '..std.dump(a[i])
	end
	local xref = std.string.format("%s%s", std.deref_str(o), args)
	-- std.string.format("%s%s", iface:esc(std.deref_str(o)), iface:esc(args))

	if not dict[xref] then
		table.insert(dict, xref)
		dict[xref] = #dict
	end
	local nr = dict[xref]
	xref = nr
	local r
	if xref > #xrt then
		r = std.string.format("[%s]", str)
	elseif std.cmd[1] == 'inv' then
		r = std.string.format("%s%s", str, iface:top(iface:img(ixrs[xref])))
	else
		r = std.string.format("%s%s", str, iface:top(iface:img(xrs[xref])))
	end
	if std.cmd[1] == 'way' then
		links[nr] = 'go'
		return std.string.format("<a:go %s>", xref)..r.."</a>"
	elseif std.is_obj(o, 'menu') or std.is_system(o) then
		links[nr] = 'act'
		if std.cmd[1] == 'inv' then
			links[nr] = 'use'
		end
		return std.string.format("<a:act %s>", xref)..r.."</a>"
	elseif std.cmd[1] == 'inv' then
		links[nr] = 'use'
		return std.string.format("<a:use %s>", xref)..r.."</a>"
	end
	links[nr] = 'act'
	return std.string.format("<a:obj/act %s>", xref)..r.."</a>"
end

local iface_cmd = function(_, inp)
	local cmd = std.cmd_parse(inp)
	if std.debug_input then
		std.dprint("* input: ", inp)
	end
	if not cmd then
		return "Error in cmd arguments", false
	end

	std.cmd = cmd
	std.cache = {}
	local r, v = std.ref 'game':cmd(cmd)
	if r == true and v == false then
		return nil, true -- hack for menu mode
	end
	r = iface:fmt(r, v) -- to force fmt
	if std.debug_output then
		std.dprint("* output: ", r, v)
	end
	return r, v
end;

function iface:cmd(inp)
	local hdr = ''
	local a = std.split(inp)
	if a[1] == 'act' or a[1] == 'use' or a[1] == 'go' then
		if a[1] == 'use' then
			local use = std.split(a[2], ',')
--			if use[2] then
--				hdr = std.string.format("%s -> %s\n", use[1], use[2])
--			end
			for i = 1, 2 do
				local u = std.tonum(use[i])
				if u then
					use[i] = dict[u]
				end
			end
			a[2] = std.join(use, ',')
		elseif std.tonum(a[2]) then
--			hdr = std.string.format("%s\n", a[2])
			a[2] = dict[std.tonum(a[2])]
		end
		inp = std.join(a)
	end
	local r, v = iface_cmd(self, inp)
	if type(r) == 'string' then r = hdr .. r end
	return r, v
end

local old_input = iface.input
local shift = false
local item = false
function iface:input(event, a, b, ...)
	if event == 'kbd' and b:find 'shift' then
		shift = a
		if not shift then
			item = false
		end
	end
	if event == 'kbd' and a == false and xrm[b] then
		local nr = xrm[b]
		if links[nr] then
			if shift and not item then
				item = nr
			elseif shift then
				local o = item
				item = false
				shift = false
				return std.string.format("use %d,%d", o, nr)
			else
				shift = false
				return links[nr]..' '..nr
			end
		else
			item = false
			shift = false
		end
	end
	return old_input(iface, event, a, b, ...)
end

std.mod_start(function()
	local col = theme.get('win.col.fg')
	theme.set('win.col.link', col)
	theme.set('win.col.alink', col)
	col = theme.get('inv.col.fg')
	theme.set('inv.col.link', col)
	theme.set('inv.col.alink', col)

	dict = {}
	links = {}
end)

std.mod_step(function(state)
	if state then
		dict = {}
		links = {}
		item = false
		shift = false
	end
end)

load_fn()
end
