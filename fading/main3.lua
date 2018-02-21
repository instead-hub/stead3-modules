loadmod 'fading'
--[[
fading.set {'имя эффекта', параметры } -- задание эффекта на 1 раз (на следующий переход)
параметры:
delay = 20 -- значение таймера
max = 16 -- число итераций

fading.change {'имя эффекта', параметры } -- задание эффекта навсегда (на все переходы)
Это синоним эффекта по умолчанию.

]]--
local effects = {
	'crossfade',
	'fadeblack',
	'move_left',
	'move_right',
	'move_up',
	'move_down',
}

global 'effect' (1);
obj {
	nam = 'эффект';
	dsc = function()
		p("Эффект: {", effects[effect], "}")
	end;
	act = function(s)
		effect = effect + 1;
		if effect > #effects then effect = 1 end
		fading.change {effects[effect], max = 32, delay = 25}
	end;
}

room {
	nam = 'main';
	obj = { 'эффект' };
	way = { 'main2' };
}

room {
	nam = 'main2';
	obj = { 'эффект' };
	way = { 'main' };
}
