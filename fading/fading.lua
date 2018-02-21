require "sprite"
require "theme"
require "timer"

instead.fading = false

local f = std.obj {
	{
		started = false;
		timer = false;
		step = 0;
		effects = {};
	};
	delay = 20;
	effect = 'fadeblack';
	max = 16; -- iterations
	nam = '@fading';
}

function f.effects.fadeblack(s, src, dst)
	sprite.scr():fill('black')
	if s.step < s.max / 2 then -- fadeout old
		local alpha = 255 - (s.step * 2 / s.max) * 255;
		if alpha > 0 then
			src:draw(sprite.scr(), 0, 0, alpha);
		end
	else -- fadein new
		local alpha = ((s.step - 1 - s.max / 2) / s.max) * 255 * 2;
		if alpha > 0 then
			dst:draw(sprite.scr(), 0, 0, alpha);
		end
	end
end

function f.effects.crossfade(s, src, dst)
	local alpha = ((s.step - 1) / s.max) * 255;
	src:draw(sprite.scr(), 0, 0, 255 - alpha);
	dst:draw(sprite.scr(), 0, 0, alpha);
end

function f.effects.move_left(s, src, dst)
	sprite.scr():fill('black')
	local x = theme.scr.w() * s.step / s.max
	src:copy(sprite.scr(), x, 0);
	dst:copy(sprite.scr(), x - theme.scr.w(), 0);
end

function f.effects.move_right(s, src, dst)
	sprite.scr():fill('black')
	local x = theme.scr.w() * s.step / s.max
	dst:copy(sprite.scr(), theme.scr.w() - x, 0);
	src:copy(sprite.scr(), -x, 0);
end

function f.effects.move_up(s, src, dst)
	sprite.scr():fill('black')
	local y = theme.scr.h() * s.step / s.max
	src:copy(sprite.scr(), 0, y);
	dst:copy(sprite.scr(), 0, y - theme.scr.h());
end

function f.effects.move_down(s, src, dst)
	sprite.scr():fill('black')
	local y = theme.scr.h() * s.step / s.max
	dst:copy(sprite.scr(), 0, theme.scr.h() - y);
	src:copy(sprite.scr(), 0, -y);
end

local scr, scr2
local cb = timer.callback

function timer:callback(...)
	if f.started then
		return '@fading'
	end
	return cb(self, ...)
end

function f.start()
	local old = sprite.direct()
	sprite.direct(true)
	sprite.scr():copy(scr)
	sprite.direct(old)
	f.timer = timer:get()
	f.step = 0
	f.started = true
	timer:set(f.delay)
end

local oldrender = sprite.render_callback()

sprite.render_callback(function()
	if f.started and not sprite.direct() then
		sprite.direct(true)
		sprite.scr():copy(scr2)
		scr:copy(sprite.scr())
	end
	if not f.started and oldrender then
		oldrender()
	end
end)

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@fading' then
		return
	end

	f.step = f.step + 1

	f.effects[f.effect](f, scr, scr2)

	if f.step > f.max then
		f.started = false
		timer:set(f.timer)
		sprite.direct(false)
		return std.nop()
	end
	return
end)

std.mod_start(function()
	scr = sprite.new(theme.get 'scr.w', theme.get 'scr.h')
	scr2 = sprite.new(theme.get 'scr.w', theme.get 'scr.h')
end)

std.mod_step(function(state)
	if not state then
		return
	end
	if player_moved() and std.cmd[1] ~= 'load' then
		f.start()
	end
end)

fading = f
