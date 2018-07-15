require "timer"
loadmod "decor"
--[[
Создание декоратора:
D { "имя декоратора", "тип декоратора", параметры ... }
Удаление декоратора:
D { "имя декоратора" }

Получение декоратора, для изменения его параметров:
D"имя декоратора"

Пересоздание декоратора:
D(D"имя декоратора")

Общие аргументы декораторов:
x, y - позиции на сцене
xc, yc - точка центра декоратора (по умолчанию 0, 0 -- левый верхний угол)
xc и yc могут принимать значение true - тогда xc и/или yc расчитаются самостоятельно как центр картинки
w, h - ширина и высотра. Если не заданы, в результате создания декоратора будут вычислены самостоятельно
z - слой. Чем больше - тем дальше от нас. Отрицательные значения - ПЕРЕД слоем текста, положительные - ПОСЛЕ.
click -- если равен true - то клики по этому объекту будут доставляться в here():ondecor() или game:ondecor()

Например:
function game:ondecor(name, press, x, y, btn)
name - имя декоратора
press - нажато или отжато
x, y -- координаты относительно декоратора (с учетом xc, yc)
btn - кнопка

hidden -- если равен true - то декоратор не видим

Если вы используете анимацию, или подсветку ссылок в текстовом декораторе нужно включить таймер на желаемую частоту,
например:
timer:set(50)

Типы декораторов:

"img" - картинка или анимация
Параметры:
сначала идет графический файл, из которого будет создан декоратор.
Вместо файла можно задать declared функцию, возвращающую спрайт.
frames = число -- если это анимация. В анимации кадры записаны в одном полотне. Размер каждого кадра задается w и h.
delay = число мс -- задержка анимации.
background - если true, этот спрайт считается фоном и просто копируется (быстро). Для фонов ставьте z побольше.

fx, fy - числа - если рисуем картинку из полотна, можно указать позицию в котором она находится

Пример:
	D {"cat", "img", "anim.png", x = -64, y = 48, frames = 3, w = 64, h = 54, delay = 100, click = true }
	D {"title", "img", "title.png", x = 400, y = 300, xc = true, yc = true } -- по центру, если тема 800x600


"txt" - текстовое поле
В текстовом поле создается текст с требуемым шрифтом.
В тексте могут быть переводы строк '\n' и ссылки {ссылка|текст}.
Параметры:
font - файл шрифта. Если не указан, берется из темы
size - размер шрифта. Если не указан, берется из темы
interval - интервал. Если не указан, берется из темы
style - число Если не указано, то 0 (обычный)
color - цвет, если не указано, берется из темы
color_link, color_alink - цвет ссылки/подсвеченной ссылки (если не указано, берется из темы)

Ссылки обрабатываются как у декораторов. Например:

function game:ondecor(name, press, x, y, btn, act, ...)
press - нажатие или отжатие (для текстовых декораторов приходит только отжатие
x, y -- координаты ОТНОСИТЕЛЬНО декоратора
name -- имя декоратора
act и ... -- ссылка и ее аргументы
Например {walk 'main'|Ссылка}

function game:ondecor(name, press, x, y, btn, act, where)
act будет равен 'walk'
where будет равно 'main'

T('параметр темы', значение) -- смена параметров темы, которые попадут в save
]]--

obj {
    nam = 'milk';
    dsc = [[На полу стоит блюдце с {молоком}.]];
    act = function()
	p [[Это для котика.]];
    end;
}

room {
    nam = 'main';
    title = 'ДЕКОРАТОРЫ';
    dsc = [[Привет, мир!]];
    obj = { 'milk' };
    ondecor = function(s, name, press) -- котика обработаем в комнате
	if name == 'cat' and press then
	    local mew = { 'Мяу!', 'Муррр!', 'Мурлык!', 'Мяуууу! Мяуууу!', 'Дай поесть!' };
	    p (mew[rnd(#mew)])
	    return
	end
	return false -- а все остальное -- в game
    end
}

local text = [[Привет любителям и авторам INSTEAD!
[break]
Это простая демонстрация
альфа версии декораторов.
[break]
Название позаимствовано от FireURQ.
[break]
Надеюсь, вам понравится INSTEAD 3.2!
Теперь вы можете нажать на {restart|ссылку}.]];
function game:timer()
	return false
end
function game:ondecor(name, press, x, y, btn, act, a, b)
	-- обработчик кликов декораторов (кроме котика, который обработан в main)
	if name == 'text' and not act then
		D'text':next_page()
		return false
	end
	if act == 'restart' then
	    D'text':page(1)
	    p("click:", name, ":",a, " ", b, " ", x, ",", y) -- вывели информацию о клике
	    return
	end
	return false
end

declare 'box_alpha' (function (v)
	return sprite.new("box:"..std.tostr(v.w).."x"..std.tostr(v.h)..",black"):alpha(32)
end)

declare 'flake' (function (d)
    d.y = d.y + rnd(3)
    d.x = d.x + rnd(3) - 2
    if d.y > 600 then
	d.y = 0
	d.x = rnd(800)
    end
end)

declare 'kitten' (function (cat)
    cat.x = cat.x + 2
end)

function init()
	timer:set(50)
	for i = 1, 100 do
		decor:new {"snow"..std.tostr(i), "img", "box:4x4,black", process = flake, x= rnd(800), y = rnd(600), xc = true, yc = true, z = -1 }
	end
	decor.bgcol = 'white'
	D {"cat", "img", "anim.png", process = kitten, x = -64, y = 48, frames = 3, w = 64, h = 54, delay = 100, click = true, z = -1}
	D {"bg", "img", box_alpha, xc = true, yc = true, x = 400, w = 180, y = 300, h = 148, z = 2  }
	D {"text", "txt", text, xc = true, yc = true, x = 400, w = 160, y = 300, align = 'left', hidden = false, h = 128, typewriter = true, z =1 }
end
