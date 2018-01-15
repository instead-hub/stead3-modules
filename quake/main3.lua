loadmod 'quake'

obj {
	nam = 'бомба';
	dsc = [[На полу лежит {бомба}.]];
	act = function(s)
		p [[БАХ!!!]];
		quake.start()
		remove(s)
	end;
}

room {
	nam = 'main';
	dsc = [[Комната.]];
	obj = { 'бомба' };
}
