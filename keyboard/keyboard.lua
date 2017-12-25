require "fmt"
require "noinv"
require "keys"

local std = stead

local keyb = {
	{ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", },
	{ "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]", },
	{ "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'", [[\]], },
	{ "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", },
}

local kbden = {
	shifted = {
	["1"] = "!",
	["2"] = "@",
	["3"] = "#",
	["4"] = "$",
	["5"] = "%",
	["6"] = "^",
	["7"] = "&",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")",
	["-"] = "_",
	["="] = "+",
	["["] = "{",
	["]"] = "}",
	["\\"] = "|",
	[";"] = ":",
	["'"] = "\"",
	[","] = "<",
	["."] = ">",
	["/"] = "?",
	}
}

local kbdru = {
	["q"] = "й",
	["w"] = "ц",
	["e"] = "у",
	["r"] = "к",
	["t"] = "е",
	["y"] = "н",
	["u"] = "г",
	["i"] = "ш",
	["o"] = "щ",
	["p"] = "з",
	["["] = "х",
	["]"] = "ъ",
	["a"] = "ф",
	["s"] = "ы",
	["d"] = "в",
	["f"] = "а",
	["g"] = "п",
	["h"] = "р",
	["j"] = "о",
	["k"] = "л",
	["l"] = "д",
	[";"] = "ж",
	["'"] = "э",
	["z"] = "я",
	["x"] = "ч",
	["c"] = "с",
	["v"] = "м",
	["b"] = "и",
	["n"] = "т",
	["m"] = "ь",
	[","] = "б",
	["."] = "ю",
	["`"] = "ё",

	shifted = {
	["q"] = "Й",
	["w"] = "Ц",
	["e"] = "У",
	["r"] = "К",
	["t"] = "Е",
	["y"] = "Н",
	["u"] = "Г",
	["i"] = "Ш",
	["o"] = "Щ",
	["p"] = "З",
	["["] = "Х",
	["]"] = "Ъ",
	["a"] = "Ф",
	["s"] = "Ы",
	["d"] = "В",
	["f"] = "А",
	["g"] = "П",
	["h"] = "Р",
	["j"] = "О",
	["k"] = "Л",
	["l"] = "Д",
	[";"] = "Ж",
	["'"] = "Э",
	["z"] = "Я",
	["x"] = "Ч",
	["c"] = "С",
	["v"] = "М",
	["b"] = "И",
	["n"] = "Т",
	["m"] = "Ь",
	[","] = "Б",
	["."] = "Ю",
	["`"] = "Ё",
	["1"] = "!",
	["2"] = "@",
	["3"] = "#",
	["4"] = ";",
	["5"] = "%",
	["6"] = ":",
	["7"] = "?",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")",
	["-"] = "_",
	["="] = "+",
	}
}
local kbdlower = {
	['А'] = 'а',
	['Б'] = 'б',
	['В'] = 'в',
	['Г'] = 'г',
	['Д'] = 'д',
	['Е'] = 'е',
	['Ё'] = 'ё',
	['Ж'] = 'ж',
	['З'] = 'з',
	['И'] = 'и',
	['Й'] = 'й',
	['К'] = 'к',
	['Л'] = 'л',
	['М'] = 'м',
	['Н'] = 'н',
	['О'] = 'о',
	['П'] = 'п',
	['Р'] = 'р',
	['С'] = 'с',
	['Т'] = 'т',
	['У'] = 'у',
	['Ф'] = 'ф',
	['Х'] = 'х',
	['Ц'] = 'ц',
	['Ч'] = 'ч',
	['Ш'] = 'ш',
	['Щ'] = 'щ',
	['Ъ'] = 'ъ',
	['Э'] = 'э',
	['Ь'] = 'ь',
	['Ы'] = 'ы',
	['Ю'] = 'ю',
	['Я'] = 'я',
}

local function tolow(s)
	if not s then
		return
	end
	s = s:lower();
	local xlat = kbdlower
	if xlat then
		local k,v
		for k,v in pairs(xlat) do
			s = s:gsub(k,v);
		end
	end
	return s;
end

local function input_esc(s)
	local rep = function(s)
		return fmt.nb(s)
	end
	if not s then return end
	local r = s:gsub("[^ ]+", rep):gsub("[ \t]", rep):gsub("{","\\{"):gsub("}","\\}");
	return r
end

local function kbdxlat(s, k)
	local kbd

	if k:len() > 1 then
		return
	end

	if s.alt_xlat and
		(game.codepage == 'UTF-8' or game.codepage == 'utf-8') then
		kbd = kbdru;
	else
		kbd = kbden
	end

	if kbd and s.shift then
		kbd = kbd.shifted;
	end

	if not kbd[k] then
		if s.shift then
			return k:upper();
		end
		return k;
	end
	return kbd[k]
end

local hook_keys = {
	['a'] = true, ['b'] = true, ['c'] = true, ['d'] = true, ['e'] = true, ['f'] = true,
	['g'] = true, ['h'] = true, ['i'] = true, ['j'] = true, ['k'] = true, ['l'] = true,
	['m'] = true, ['n'] = true, ['o'] = true, ['p'] = true, ['q'] = true, ['r'] = true,
	['s'] = true, ['t'] = true, ['u'] = true, ['v'] = true, ['w'] = true, ['x'] = true,
	['y'] = true, ['z'] = true, ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true,
	['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true, ['0'] = true,
	["-"] = true, ["="] = true, ["["] = true, ["]"] = true, ["\\"] = true, [";"] = true,
	["'"] = true, [","] = true, ["."] = true, ["/"] = true, ['space'] = true, ['backspace'] = true,
	['left alt'] = true, ['right alt'] = true, ['alt'] = true, ['left shift'] = true,
	['right shift'] = true, ['shift'] = true, ['return'] = true,
}

-- instead has function walkback() in stdlib
-- but for old versions we implement own version
local function walkback()
	local w = std.me():where():from()
	local o = w:from()
	std.walkout(w)
	w.__from = o
end

obj {
	nam = '@kbdinput';
	act = function(s, w)
		if w == 'comma' then
			w = ','
		end
		if w:find("alt") then
			std.here().alt_xlat = not std.here().alt_xlat
			return true
		end

		if w:find("shift") then
			std.here().shift = not std.here().shift
			return true
		end

		if w == 'space' then
			w = ' '
		end
		if w == 'backspace' then
			if not std.here().text or std.here().text == '' then
				return
			end
			if std.here().text:byte(std.here().text:len()) >= 128 then
				std.here().text = std.here().text:sub(1, std.here().text:len() - 2);
			else
				std.here().text = std.here().text:sub(1, std.here().text:len() - 1);
		end
		elseif w == 'cancel' then
			std.here().text = '';
			walkback();
		elseif w == 'return' then
			walkback();
			return std.call(std.here(), 'onkbd', _'@keyboard'.text, std.unpack(_'@keyboard'.args))
		else
			w = kbdxlat(stead.here(), w)
			std.here().text = std.here().text..w;
		end
	end;
}

room {
	nam = '@keyboard';
	text = '';
	alt = false;
	shift = false;
	alt_xlat = false;
	noinv = true;
	keyboard_type = true;
	cursor = fmt.b '|';
	title = false;
	args = {};
	msg = fmt.b '> ';
	act = function(s, w, ...)
		s.title = w or "?"
		s.args = { ... }
		walkin(s)
	end;
	ini = function(s, load)
		s.alt = false
		if load and std.here() == s then
			s.__flt = instead.mouse_filter(0)
		end
	end;
	enter = function(s)
		s.text = '';
		s.alt = false
		s.shift = false
		s.__flt = instead.mouse_filter(0)
	end;
	exit = function(s)
		instead.mouse_filter(s.__flt)
	end;
	onkey = function(s, press, key)
		if key:find("alt") then
			s.alt = press
			if not press then
				s.alt_xlat = not s.alt_xlat
			end
			s:decor()
			return false
		end
		if s.alt then
			return false
		end
		if key:find("shift") then
			s.shift = press
			return true
		end
		if not press then
			return false
		end
		if s.alt then
			return false
		end
		return std.call(_'@kbdinput', 'act', key);
	end;
	decor = function(s)
		p (s.msg)
		p (input_esc(s.text)..s.cursor)
		pn()
		local k,v
		for k, v in ipairs(keyb) do
			local kk, vv
			local row = ''
			for kk, vv in ipairs(v) do
				local a = kbdxlat(s, vv)
				if vv == ',' then
					vv = 'comma'
				end
				row = row.."{@kbdinput "..vv.."|"..input_esc(a).."}"..fmt.nb "  ";
			end
			pn(fmt.c(row))
		end
		pn (fmt.c[[{@kbdinput alt|«Alt»}    {@kbdinput shift|«Shift»}    {@kbdinput cancel|«Отмена»}    {@kbdinput backspace|«Забой»}    {@kbdinput return|«Ввод»}]]);
	end;
}

local hooked
local orig_filter

std.mod_start(function(load)
	if not hooked then
		hooked = true
		orig_filter = std.rawget(keys, 'filter')
		std.rawset(keys, 'filter', std.hook(keys.filter, function(f, s, press, key)
			if std.here().keyboard_type then
				return hook_keys[key]
			end
			return f(s, press, key)
		end))
	end
end)

std.mod_done(function(load)
	hooked = false
	std.rawset(keys, 'filter', orig_filter)
end)

keyboard = _'@keyboard'
