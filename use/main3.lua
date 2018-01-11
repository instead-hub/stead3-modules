require "use"

obj {
	nam = 'яблоко';
	dsc = [[На полу лежит {яблоко}.]];
	act = [[Пусть себе лежит.]];
	inv = 'Это яблоко. Красное!';
}

obj {
	nam = 'нож';
	dsc = [[Рядом с ним лежит {нож}.]];
	tak = 'Взял нож.';
	inv = 'Это нож';
	use = function(s, w)
		if w ^ 'яблоко' then
			p [[Почищу-ка я яблочко!]]
		else
			return false
		end
	end
}

game.use = function(s, w, o)
	pn "А стоит ли?"
	p (w, '->', o)
end

menu {
	nam = 'menu';
	disp = 'меню';
	inv = 'Это всего лишь настоящее меню';
}

take 'menu'

room {
	nam = 'main';
	obj = {
	    'яблоко', 'нож',
	}
}
