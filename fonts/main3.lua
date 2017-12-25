require "fonts"
local fnt = _'$fnt'
fnt:face ('sans', 'sans.ttf', 33)
room {
	nam = 'main';
	dsc = '{$fnt sans}';
}:with {
	obj {
		dsc = 'Тут лежит {{$fnt sans|что\\|то}}';
		act = '{$fnt sans|Вы нажали на что-то}';
	};
	obj {
		nam = 'test';
		act = 'test!';
	};

}