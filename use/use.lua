--[[ FAKE use module. Emualtes USE mechanics via menu objects ]]--

require 'theme'
require 'click'
require 'fmt'

local USE = false

std.menu.__real_menu_type = true

local cursor_norm = theme.get 'scr.gfx.cursor.normal'
local cursor_use = theme.get 'scr.gfx.cursor.use'

local function use_on(w)
	theme.set('scr.gfx.cursor.normal', cursor_use)
	USE = w
end

local function use_off(w)
	theme.set('scr.gfx.cursor.normal', cursor_norm)
	USE = false
end

local function use_mode()
	return USE
end

local onew = std.obj.new
std.obj.new = function(self, v)
	if not v.__stat_type then
		std.rawset(v, '__menu_type', true)
	end
	return onew(self, v)
end

local oact = std.player.action
std.player.action = function(s, w, ...)
	if use_mode() then
		local o = use_mode()
		return std.player.useon(s, o, w)
	end
	return oact(s, w, ...)
end;

local otake = std.player.take
std.player.take = function(s, ...)
	if use_mode() then
		return
	end
	return otake(s, ...)
end;

local useit = std.player.useit
std.player.useit = function(s, w)
	if not use_mode() then
		if w.__real_menu_type then
			return useit(s, w)
		end
		use_on(w)
		return std.nop()
	end
	local o = use_mode()
	if w == use_mode() then
		return useit(s, w)
	end
	return std.player.useon(s, o, w)
end;

game.use = function()
--	return std.nop()
end

game.act = function()
--	return std.nop()
end

game.inv = function()
--	return std.nop()
end

local old_use_mode

std.mod_cmd(function(cmd)
	if cmd[1] == '@use_mode_off' then
		use_off()
		return std.nop()
	end
	old_use_mode = use_mode() 
end)

std.mod_step(function(state)
	if state and old_use_mode and not std.abort_cmd then
		use_off()
	end
end)

local input = std.ref '@input'

local oclick = input.click

function input:click(press, btn, ...)
	if not press and use_mode() then
		return '@use_mode_off'
	end
	return oclick(press, btn, ...)
end

local dispof = std.dispof
function std.dispof(w)
	if use_mode() == w then
		return fmt.u(dispof(w))
	end
	return dispof(w)
end