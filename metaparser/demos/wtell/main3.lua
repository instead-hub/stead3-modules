--$Name:Вильгельм Телль$
require "mp-ru"
require "fmt"

game.dsc = [[^Пример простой игры на Inform
^Авторы: Роджер Фирт (Roger Firth) и Соня Кессерих (Sonja Kesserich).
^Перевод Александра Мосьпана a.k.a. Ugo^
^Перенос на МЕТАПАРСЕР 3 выполнил Пётр Косых^^
Место: Альтдорф, кантон Ури, Швейцария. Год 1307. Швейцария под командованием Императора Альбрехта Габсбурга.
Его наместник -- фогт -- жестокий Герман Гесслер, повесил свою шляпу на вершине столба, установленного посередине
городской площади. Каждый проходящий мимо должен был кланяться этому ненавистному символу Императорского могущества.
^^
Ты, вместе с сыном, спустился от своего домика, расположенного высоко в горах, чтобы купить провизии. Ты -- гордый и
независимый мужчина, охотник и проводник, известный мастерством владения луком, и неумением скрывать своё презрение
к фогту, что, конечно, неумно, учитывая, сколько вокруг его солдат.
^^
Сегодня базарный день -- город забит людьми с окрестных деревень и селений.^]];

const 'MAX_SCORE' (3)

global 'score' (0)

Prop = Class {
	before_Exam = function() return false end;
	before_Default = function(s, ev, w)
		p ("Вам нет нужды беспокоиться о ", s:noun 'пр', ".");
	end;
}: attr 'scenery'

Furniture = Class {
	['before_Take,Pull,Push,PushDir'] = "Слишком тяжело.";
}: attr 'static,supporter'

Arrow = Class {
	word = -"стрела,стрел*";
	arrow = true;
	description = "Все твои стрелы верны и остры.";
	['before_Drop,Give,ThrowAt'] = "Ты не хочешь расставаться со своими острыми стрелами.";
}

NPC = Class {
	['life_Answer,Ask,AskTo,AskFor,Tell'] = function(s, w)
		p ('Введите просто "говорить с ', s:noun'тв', '".')
	end;
} : attr 'animate'

room {
	-"улица";
	nam = 'street';
	title = "Улица Альтдорфа";
	dsc = function(s)
		pn [[Узкая улочка тянется на север, к городской площади. Местные жители стекаются в город через ворота на юге.
    Они выкрикивают приветствия, предлагают товары, обмениваются новостями, с наигранным недоверием торгуются с
    лавочниками, чьи прилавки сильно затрудняют движение.]];
		if s:once() then
			pn '^"Держись поближе ко мне, сынок, -- говоришь ты. -- Иначе потеряешься в этой толпе".';
		end
	end;
	n_to = 'below_square';
	s_to = function() p "Поток народа, движущийся на север, к площади, не даёт тебе пройти."; end;
}: with {
	Prop {
		-"ворота";
		description = "Огромные деревянные ворота в городской стене. Они широко распахнуты.";
	};
}

Prop {
	-"прилавки|прилавок";
	description = "Еда, инструменты, одежда -- обычное барахло.";
	found_in = { 'street', 'below_square' };
}

Prop {
	-"товары|товар|еда|одежда|интсрумент|барахло";
	description = "Ничто не приковывает твой взгляд.";
	found_in = { 'street', 'below_square' };
}

Prop {
	-"торговцы,купцы,продавцы,лавочники";
	description = [[Несколько жуликоватых, но довольно прилично выглядящих торговцев, откровенно преувеличивая,
    расхваливают свой товар.]];
	found_in = { 'street', 'below_square' };
}: attr 'animate'

Prop {
	-"жители|люди|народ|толпа";
	description = "Горный народ, такой же, как и ты.";
	found_in = function() return true; end;
}

room {
	-"улица";
	nam = 'below_square';
	title = "Улица";
	dsc = [[Народ проталкивается от южных ворот к городской площади, располагающейся немного севернее.
    Ты узнаёшь торговку за прилавком фруктово-овощной лавки.]];
	n_to = 'south_square';
	s_to = 'street';
}

Furniture {
	-"овощная лавка|лавка|прилавок,стол";
	found_in = 'below_square';
	nam = 'stall';
	description = "Это всего лишь маленький стол с большой кучей картошки, кучкой морковки и репы, и парой яблок.";
	before_Search = function(s) mp:xaction("Exam", s) end;
} : attr 'scenery'

Prop {
	-"картошка|картофель";
	found_in = { 'below_square' };
	description = "Должно быть, какой-то особенно ранний сорт... лет так на триста!",
}

Prop {
	-"фрукты/~од|овощи|морковь,морковка|репа,репка";
	found_in = { 'below_square' };
	description = "Отличные местные овощи.";
}

NPC {
	-"Хельга|торговка,продавщица,женщина|платье|шарф";
	nam = 'stallholder';
	found_in = { 'below_square' };
	description = "Хельга -- полноватая жизнерадостная женщина, одетая в бесформенное платье и пёстрый платок.";
	init_dsc = function(s)
		pn "Хельга отвлекается от сортировки картошки, чтобы уделить тебе внимание.";
		if s:once() then
			move('apple', pl)
			pn [[^"Привет, Вильгельм! Отличный денёк для торговли! Это твой Уолтер? О, как он вырос! Держи яблоко для него --
            тут один край немного подгнил, но всё остальное хорошее. Как там фрау Телль? Передавай ей привет".]];
		end
	end;
	times_spoken_to = 0; -- ! для подсчёта разговоров
	life_Kiss = [["Ох, а ты дерзкий тип!"]];
        life_Talk = function(s)
		s.times_spoken_to = s.times_spoken_to + 1;
		if s.times_spoken_to == 1 then
			score = score + 1;
			p "Ты тепло благодаришь Хельгу за яблоко.";
		elseif s.times_spoken_to == 2 then
			p [["Ещё увидимся!"]];
		else
			return false;
		end
	end
}

room {
	title =  "Южный край площади";
	nam = 'south_square';
	dsc = [[Узкая улица выходит на южный край городской площади, продолжаясь на дальней её стороне.
Чтобы продолжить путь к месту назначения -- сыромятне Йохансона -- ты должен пройти на север, через площадь,
в центре которой ты видишь отвратительный столб со шляпой Гесслера на верхушке. Если ты пойдёшь прямо,
придётся пройти мимо него. Солдаты императора грубо толкаются среди толпы, раздавая тумаки и громко ругаясь.]];
	n_to = 'mid_square';
	s_to = 'below_square';
}

Prop {
	-"шляпа,шапка|шест,столб";
	['before_Default,Exam'] = "Издали плохо видно.";
	found_in = {'south_square', 'north_square' };
}

NPC {
	nam = 'guard';
	-"солдаты,стражники";
	description = "Неотёсанные, жестокие люди не из этих мест.";
        ['before_FireAt,Attack'] = "Их намного больше.";
	before_Talk = "Разговаривать с этими мерзавцами -- ниже твоего достоинства.";
	found_in = { 'south_square', 'mid_square', 'north_square', 'marketplace' };
} :attr 'animate,scenery'

room {
	-"центр|площадь";
	title = "Центр площади";
	nam = 'mid_square';
	dsc = [[В центре площади давка совсем не такая сильная. Большинство людей предпочитают держаться подальше от столба,
на который нахлобучена эта нелепая церемониальная шапка. Группа солдат стоит неподалёку, осматривая всех, кто проходит.]];
	n_to = 'north_square';
	s_to = 'south_square';
	warnings_count = 0; -- количество предупреждений солдата
	before_Walk = function(s, w)
		if mp:compass_dir(w) == 's_to' then
			s.warnings_count = 0;
			_'pole'.has_been_saluted = false;
		end
		if mp:compass_dir(w) == 'n_to' then
			if _'pole'.has_been_saluted then
				p [[^"Хорошего дня".^]];
				return false;
			end
			s.warnings_count = s.warnings_count + 1;
			if s.warnings_count == 1 then
				p [[Солдат преграждает тебе дорогу.^^
"Эй ты, сноб, забыл хорошие манеры? Как насчёт того, чтобы поклониться шляпе фогта?"]];
			elseif s.warnings_count == 2 then
				p [["Я тебя знаю, ты Телль, мятежник, не правда ли?
Ладно, мы не хотим начинать тут драку, так что будь хорошим мальчиком,
отдай честь этой чёртовой шляпе, в третий раз я просить не буду".]];
			else
				p [["Ладно, {$fmt u|господин} Телль, у вас серьёзные неприятности.
Я вежливо попросил, но вы оказались слишком гордым
и слишком глупым. Думаю, фогт захочет с вами немного побеседовать".^^
С этими словами солдаты хватают тебя и Уолтера, и пока сержант бежит докладывать Гесслеру,
они грубо тащат вас к старому липовому дереву, растущему на рыночной площади.^]];
				move('apple', 'son')
				move(pl, 'marketplace');
			end
			return
		end
		return false
	end
}

Furniture {
	-"шляпа|столб|перо|шапка";
	nam = 'pole';
	description = [[Столб из соснового ствола диаметром в несколько дюймов и высотой в девять или десять футов.
На самой верхушке надёжно закреплена нелепая шляпа Гесслера из черной и красной кожи, с широкими
изогнутыми полями и пучком перьев из мёртвого гуся.]];
	has_been_saluted = false;
	before_FireAt = "Заманчиво, но ты не хочешь неприятностей.";
        before_Salute = function(s)
		s.has_been_saluted = true;
		p [[Ты отдаёшь честь шляпе на столбе.^^
            "Благодарю вас, сэр", -- ухмыляется солдат.]];
	end;
	found_in = { 'mid_square' };
} : attr 'scenery'

room {
	nam = 'north_square';
	title = "Северный край площади";
	dsc = [[Узкая улочка ведёт на север от мощёной площади, в центре которой едва виднеется столб и шапка.]];
	n_to = function(s)
		p "Вместе с Уолтером ты уходишь с площади, направляясь к сыромятне Йохансона.";
		walk 'theend'
	end;
	s_to = function(s) p "Ты не можешь себя заставить снова пройти через это."; end;
}

room {
	nam = 'marketplace';
	title = "Рыночная площадь";
	dsc = [[Рыночная площадь Альтдорфа примыкает к центральной площади. Она была поспешно очищена от прилавков.
Группа солдат расталкивает людей, чтобы очистить место перед липой, которая растет тут с незапамятных
времён. Обычно в её тени собираются старики, чтобы посплетничать, поглазеть на девушек и поиграть в карты.
Но сегодня под ней никого нет, кроме Уолтера, которого привязали к стволу. Двое солдат удерживают тебя примерно
в сорока метрах от него.]];
	cant_go = "Что? Оставить своего сына связанным здесь?";
}

obj {
	-"липа|дерево";
	nam = 'tree';
	found_in = { 'marketplace' };
	description = "Обычное большое дерево.";
	before_FireAt = function(s, w)
		if BowOrArrow(w) then
			p "Твоя рука слегка дрожит, и стрела входит в ствол на несколько дюймов выше головы Уолтера.";
			walk 'theend'
		end
	end;
}:attr 'scenery'

NPC {
	-"герцог|Гесслер,фогт,Герман";
	nam = 'governor';
	found_in = { 'marketplace' };
	description = [[Невысокий, коренастый, с противным лицом, Гесслер наслаждается властью, которую он имеет над этим городком.]];
	init_dsc = function(s)
		pn "Гесслер с глумливым лицом наблюдает за происходящим с безопасного расстояния.";
		if s:once() then
			pn [[^"Похоже, нужно преподать тебе урок, глупец. Никто не смеет проходить через площадь, не отдав дань
уважения Его Императорскому Высочеству Альберту. Никто, ты слышишь? Я мог бы лишить тебя головы за измену,
но проявлю снисхождение. Не жди моей милости, если снова проявишь подобную глупость, но в этот раз я отпущу
тебя... после того, как ты продемонстрируешь своё мастерство владения луком. Попади в это яблоко с того места,
где ты стоишь. Это не должно быть слишком сложным. Сержант, лови. Поставь его на голову этого мелкого ублюдка".]];
		end;
	end;
	before_Attack = "Как ты думаешь это сделать?";
	life_Talk = "Ты не можешь заставить себя заговорить с ним.";
	before_FireAt = function(s, w)
		if BowOrArrow(w) then
			p [[Прежде, чем солдаты успевают среагировать, ты разворачиваешься, и выпускаешь стрелу в Гесслера.
Она пронзает его сердце, и герцог оседает на землю. На мгновение толпа замирает в недоумении, но тут же
разражается криками ликования.]];
			walk 'theend'
		end
	end;
} : dict {
	["Гесслер/вн"] = "Гесслера";
	["Гесслер/рд"] = "Гесслера";
	["Гесслер/дт"] = "Гесслеру";
	["Гесслер/тв"] = "Гесслером";
	["Гесслер/пр"] = "Гесслере";
}

obj {
	-"лук";
	nam = 'bow';
	description = "Твой верный лук из тиса, с натянутой льняной тетивой.";
	['before_Drop,Give,ThrowAt'] = "Ты никогда не расстаёшься со своим верным луком.";
}: attr 'clothing'

obj {
	-"колчан";
	nam = "quiver";
	description = "Он сделан из козьей кожи и обычно висит за твоим левым плечом. В колчане есть стрелы.";
	['before_Drop,Give,ThrowAt'] = "Но это ведь подарок твоей жены Хедвиг.";
}: attr 'container,open,clothing'

Arrow {
	found_in = {'quiver'};
}

Arrow {
	found_in = {'quiver'};
}

Arrow {
	found_in = {'quiver'};
}

NPC {
	nam = 'son';
	-"сын,мальчик,мальчишка,парень|Уолтер";
	description = function(s)
		if std.here() ^ 'marketplace' then
			p [[Он смотрит на тебя, пытаясь выглядеть спокойным и смелым. Его руки связаны за спиной.
            Яблоко лежит в его светлых волосах.]];
				return
		end
		p "Тихий светлый мальчик восьми лет, он быстро учится сельской работе.";
	end;
	life_Give = function(s, w)
		score = score + 1;
		move(w, s)
		p [["Спасибо, пап".]];
	end;
        life_Talk = function(s, w)
		if std.here() ^ 'marketplace' then
			p [["Стой спокойно, сынок, Господь нам поможет".]];
		else
			p [[Ты показываешь сыну несколько интересных мест в городе.]];
		end
	end;
	['before_Exam,Listen,Salute,Talk'] = function()
		return false
	end;
	before_FireAt = function(s, w)
		if std.here() ^ 'marketplace' then
			if BowOrArrow(w) then
				p "Упс! Наверняка вы имели в виду не это?";
				walk 'theend'
			end
			return
                end
		return false
	end;
        before_Default = function(s)
		if std.here() ^ 'marketplace' then
			p "Солдаты не позволят тебе этого.";
			return
		end
                return false
	end;
	found_in = function()
		return true
	end;
}:attr 'transparent,scenery';

obj {
	-"яблоко,яблочко";
	nam = 'apple';
	description = function()
		if std.here()^'marketplace' then
			p "Отсюда ты едва видишь его.";
		else
			p "Яблоко зелёное, с коричневым пятном.";
		end
	end;
	before_Drop = "Вполне съедобное яблоко, не стоит его выбрасывать.";
        before_Eat = "Хельга дала его для Уолтера...";
	before_Default = function(s)
		if parent(s)^'son' then
			if std.here() ^ 'marketplace' then
				p "Отсюда ты едва видишь его."
				return
			end
			p "Лучше оставить яблоко сыну."
			return
		end
		return false
	end;
        before_FireAt = function(s, w)
		if std.here() ^ 'marketplace' then
			if BowOrArrow(w) then
				score = score + 1;
				p [[Мягко и спокойно ты кладёшь стрелу на тетиву, оттягивая её, и, предельно
сконцентрировавшись, берёшь прицел. Задержав дыхание, не мигая, ты в ужасе
отправляешь стрелу в цель. Она летит через площадь к твоему сыну, и, пронзая яблоко, впивается
в дерево. Толпа взрывается криками радости. Гесслер остаётся разочарованным.]];
				walk 'happyend'
			end
			return
		end
                return false;
	end
}

function init()
	pl.room = 'street'
	move('bow', pl)
	move('quiver', pl)
	_'quiver':attr 'worn'
	pl.description = "Ты одет в традиционную одежду швейцарского горца.";
end

room {
	nam = 'theend';
	title = 'Конец';
	noparser = true;
	dsc = function(s)
		pn "Вы испортили любимую народную легенду.";
		p ("Ваш счет: ", score, " из ", MAX_SCORE)
	end;
}
room {
	nam = 'happyend';
	title = 'Конец';
	noparser = true;
	dsc = function(s)
		pn [[Поздравляю, вы прошли игру!]]
		p ("Ваш счет: ", score, " из ", MAX_SCORE)
	end;
}

function BowOrArrow(o)
	if not o or (o^'bow' or o.arrow) then return true end
        p "Это не похоже на оружие, не правда ли?^";
	return false;
end

function mp:FireAt(w, wh)
	if not w then
		p "Ты не хочешь просто стрелять куда зря.";
		return
	end
	if BowOrArrow(wh) then
		p "Немыслимо!"
	end
	return
end

Verb {
	"#FireAt",
	"стреля/ть,стрельн/уть,целить/ся,застрели/ть,выстрел/ить",
	"FireAt",
	"в {noun}/вн,scene : FireAt",
	"~ {noun}/вн,scene : FireAt",
	"~ ?в {noun}/вн,scene из {noun}/рд,held : FireAt",
	"~ из {noun}/рд,held в {noun}/вн,scene : FireAt reverse",
	"~ {noun}/тв,held в {noun}/вн,scene : FireAt reverse",
}

function mp:Salute(w)
	if mp:animate(w) then
		p (w:Noun(), " приветствует тебя.")
	else
		p (w:Noun(), " не замечает этого.")
	end
end

Verb {
	"#Salute",
	"поклони/ться,честь",
	"{noun}/дт,scene : Salute"
}
Verb {
	"#Salute2",
	"мах/ать,помах/ать,помаш/и,маш/и",
	"{noun}/дт,scene : Salute"
}

function mp:Untie(w)
	p"Ты не можешь развязать это."
end

Verb {
	"развяз/ать,отвяз/ать,освобод/ить",
	"{noun}/вн,scene : Untie"
}

game.hint_verbs = { "#Exam", "#Walk", "#Take", "#Drop", "#FireAt", "#Salute", "#Talk" }
