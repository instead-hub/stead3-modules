require "sprite"
require "theme"
require "timer"

local q = std.obj {
	{
		started = false;
		timer = false;
		step = 0;
	};
	max = 3; -- iterations
	power = 30; -- power
	post = true; -- after action or before it
	nam = '@quake';
}

local scr
local cb = timer.callback

function timer:callback(...)
	if q.started then
		return '@quake'
	end
	return cb(self, ...)
end

function q.start()
	local old = sprite.direct()
	sprite.direct(true)
	sprite.scr():copy(scr)
	sprite.direct(old)
	q.timer = timer:get()
	q.step = 0
	q.started = true
	timer:set(50)
	if not q.post then
		sprite.direct(true)
	end
end

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@quake' then
		return
	end
	if not sprite.direct() then
		sprite.direct(true)
		sprite.scr():copy(scr)
	end
	q.step = q.step + 1
	sprite.scr():fill('black')
	scr:copy(sprite.scr(), rnd(q.power) - q.power / 2, rnd(q.power) - q.power / 2);
	if q.step > q.max then
		q.started = false
		timer:set(q.timer)
		sprite.direct(false)
		return std.nop()
	end
	return false
end)

std.mod_start(function()
	scr = sprite.new(theme.get 'scr.w', theme.get 'scr.h')
end)

quake = q
