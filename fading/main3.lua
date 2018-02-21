loadmod 'fading'

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
		fading.effect = effects[effect]
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
