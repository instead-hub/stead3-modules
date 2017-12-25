require "noinv"

loadmod 'proxymenu'


game.useit = 'Не помогло.'
game.use = 'Не сработает.'
game.give = function(s, w, ww)
	p 'Отдать? Ни за что!'
	p (w, "->", ww)
end
game.eat = 'Не буду это есть.'
game.drop = 'Еще пригодится.'
game.exam = 'Ничего необычного.'
game.take = 'Стоит ли это брать?'
game.push = 'Ничего не произошло.'

game.after_take = function(s, w)
	take(w)
end

game.after_drop = function(s, w)
	drop(w)
end

obj {
	nam = 'ножик',
	dsc = 'На полу валяется ножик.',
	exam = 'Бесполезный перочинный ножик.',
	useon = function(s, w)
		return 'Вы пытаетесь юзать нож на объект: '..std.dispof(w)..'. Получилось!'
	end,
}
xact.walk = walk
room {
	nam = 'main',
	title = false,
	noinv = true;
	decor = [[Введение. {@ walk "r1"|Дальше}]];
	exit = function(s)
		take 'ножик'
	end,
}

obj {
	nam = 'куб',
	dsc = 'В центре комнаты находится куб.',
	take = 'Вы взяли куб',
	exam = 'Мультифункциональный куб -- написано на кубе.',
	drop = 'Вы положили куб.',
	useit = 'Как можно использовать куб?',
	talk = 'Вы поговорили с кубом.',
	eat = function(s)
		return 'Вы не можете разгрызть куб.', false;
	end,
	openit = 'Вы открыли куб.',
	closeit = 'Вы закрыли куб.',
	push = 'Вы толкаете куб.',
	give = function(s, w)
		return 'Вы пытаетесь отдать куб объекту: '..std.dispof(w)..'.', false
	end,
	useon = function(s, w)
		return 'Вы пытаетесь юзать куб на объект: '..std.dispof(w)..'. Получилось!'
	end,
--	used = 'Куб поюзан.',
};

obj {
	nam = 'сфера',
	dsc = 'В центре комнаты находится сфера.',
	take = 'Вы взяли сферу',
	exam = 'Мультифункциональная сфера -- написано на сфере.',
	drop = 'Вы положили сферу.',
	useit = 'Как можно использовать сферу?',
	talk = 'Вы поговорили с сферой.',
	eat = function(s)
		return 'Вы не можете разгрызть сферу.', false;
	end,
	openit= 'Вы открыли сферу.',
	closeit = 'Вы закрыли сферу.',
	push = 'Вы толкаете сферу.',
	give = function(s, w)
		return 'Вы пытаетесь отдать сферу объекту: '..std.dispof(w)..'.', false
	end,
	useon = function(s, w)
		return 'Вы пытаетесь юзать сферу на объект: '..std.dispof(w)..'. Получилось!'
	end,
--	used = 'Сфера поюзана.',
};

room {
	nam = 'r1',
	title = false;
	dsc = 'Вы в комнате',
	obj = { 'куб', 'сфера' },
}

game.player = std.menu_player { nam = 'player' }

place( proxy_menu {
	disp = 'С СОБОЙ', 
	acts = { inv = 'exam' };
	sources = { inv = true };
}, me())

place( proxy_menu { 
	disp = 'ОСМОТРЕТЬ';
	acts = { inv = 'exam' };
	sources = { scene = true };
}, me())

place( proxy_menu { 
	disp = 'ВЗЯТЬ';
	acts = { inv = 'take' };
	sources = { scene = true };
}, me())

place( proxy_menu { 
	disp = 'БРОСИТЬ';
	acts = { inv = 'drop' };
	sources = { inv = true };
}, me())

place( proxy_menu { 
	disp = 'ЕСТЬ';
	acts = { inv = 'eat' };
	sources = { inv = true };
}, me())

place( proxy_menu { 
	disp = 'ТОЛКАТЬ';
	acts = { inv = 'push' };
	sources = { scene = true };
}, me())

place( proxy_menu { 
	disp = 'ИСПОЛЬЗОВАТЬ';
	use_mode = true;
	acts = { use = 'useon', used = 'used', inv = 'useit' };
	sources = { inv = true, scene = true };
}, me())

place( proxy_menu { 
	disp = 'ОТДАТЬ';
	use_mode = true;
	acts = { use = 'give', used = 'accept' };
	sources = { inv = true, scene = true };
}, me())

place( proxy_menu { 
	disp = 'ИДТИ';
	acts = { inv = 'walk' };
	sources = { ways = true };
}, me())


function init()
	instead.noways = true

end
