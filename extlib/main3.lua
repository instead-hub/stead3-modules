loadmod 'extlib-ru'

local mrd = require "morph/mrd"
local lang = require "morph/lang-ru"

function init()
	mrd:init(lang)
end

obj {
	-"винтовка";
	nam = "винтовка";
	onuse = function(s, w)
		if w ^ 'ваза' then
			p [[Бах!]];
			remove(w)
			return
		end
		return false
	end;
}:attr 'item'

obj {
	-"телевизор";
	nam = "телевизор";
}:attr 'switchable';

obj {
	-"стол";
	nam = "стол";
}:attr 'supporter': with { 'винтовка', 'ваза', 'коробка', 'телевизор' }

obj {
	-"коробка";
	nam = "коробка";
}:attr 'openable,container';

obj {
	-"ваза";
	nam = "ваза";
}:attr 'container,item':with 'цветок'

obj {
	-"цветок";
	nam = "цветок";
}:attr 'item';

room {
	nam = 'main';
	title = "extlib demo";
	obj = { 'стол' };
}
