local lang = require "morph/lang-en"
loadmod "mp"
loadmod "mplib"

local mp = _'@metaparser'

local mrd = require "morph/mrd"
mrd.lang = lang

function mrd:init() -- no dictionary!
end

std.mod_init(
	function()
	mp:init(mrd)
end)
game.dsc = function()
	p ([[METAPARSER3 Version: ]]..mp.version.."^")
	p [[http://instead-hub.github.io^^
Enter "HELP" for help.
^]]
end
local utf = mp.utf

std.obj.the_noun = function(s, ...)
	return "the "..s:noun(...)
end

_'@darkness'.word = "darkness"
_'@darkness'.before_Any = "Darkness, noun.  An absence of light to see by."
_'@darkness':attr 'persist'

_'@n_to'.word = "north";
_'@ne_to'.word = "northeasr";
_'@e_to'.word = "east";
_'@se_to'.word = "southeast";
_'@s_to'.word = "south";
_'@sw_to'.word = "southwest";
_'@w_to'.word = "west";
_'@nw_to'.word = "northwest";
_'@u_to'.word = "up,above";
_'@d_to'.word = "down";
_'@out_to'.word = "out,outside";
_'@in_to'.word = "in,inside"

local shorten = {
	["n"] = "north";
	["e"] = "east";
	["w"] = "west";
	["s"] = "south";
	["ne"] = "northeast";
	["se"] = "southeast";
	["sw"] = "southwest";
	["nw"] = "northwest";
	["x"] = "examine";
}

function mp:pre_input(str)
	if shorten[str] then return shorten[str] end
	return str
end

_'@compass'.before_Default = 'Try to verb "go".'

function mp.msg.SCORE(d)
	if d > 0 then
		pn ("{$fmt em|(Score is increased by ", d, ")}")
	else
		pn ("{$fmt em|(Score is decreased by ", d, ")}")
	end
end
mp.door.word = -"door";
mp.msg.TITLE_SCORE = "Score: "
mp.msg.TITLE_TURNS = "Turns: "
mp.msg.YES = "Yes"
mp.msg.WHEN_DARK = "Darkness."
mp.msg.UNKNOWN_THEDARK = "Probably, it is because there is no light?"
mp.msg.COMPASS_NOWAY = "{#Me} can't go that way."
mp.msg.COMPASS_EXAM_NO = "Nothing interesting in that direction."
mp.msg.ENUM = "items."
mp.msg.CUTSCENE_HELP = "Press <Enter> or enter {$fmt em|next} to continue."
mp.msg.DLG_HELP = "Enter number to select the phrase."
mp.msg.TAKE_BEFORE = function(w)
	pn (iface:em("(taking "..w:the_noun().." before)"))
end
mp.msg.DISROBE_BEFORE = function(w)
	pn (iface:em("(disrobing "..w:the_noun().." before)"))
end

mp.msg.CLOSE_BEFORE = function(w)
	pn (iface:em("(closing "..w:the_noun() .. " before)"))
end

local function str_split(str, delim)
	local a = std.split(str, delim)
	for k, _ in ipairs(a) do
		a[k] = std.strip(a[k])
	end
	return a
end

function mp.shortcut.the_noun(hint)
	local w = str_split(hint, ",")
	if #w == 0 then
		return ""
	end
	for _, k in ipairs(w) do
		local ob = mp:shortcut_obj(k)
		if ob then
			return ob:the_noun()
		end
	end
	return ""
end

function mp.shortcut.is(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob:hint'plural' then
		return 'are'
	end
	return 'is'
end

function mp.shortcut.have(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob:hint'plural' or ob:hint'first' or ob:hint'second' then
		return 'have'
	end
	return 'has'
end

function mp.shortcut.does(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob:hint'plural' or ob:hint'first' or ob:hint'second' then
		return 'do'
	end
	return 'does'
end

function mp.shortcut.yourself(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	return mp:myself(ob)[1]
end

mp.msg.SCENE = "{#Me} {#is/#me} {#if_has/#here,supporter,on,in} {#the_noun/#here}.";
mp.msg.INSIDE_SCENE = "{#Me} {#is/#me} {#if_has/#where,supporter,on,in} {#the_noun/#where}.";
mp.msg.TITLE_INSIDE = "({#if_has/#where,supporter,on,in} {#the_noun/#where})";

mp.msg.COMPASS_EXAM = function(dir, ob)
	if dir == 'u_to' then
		p "Upwards there"
	elseif dir == 'd_to' then
		p "Downwards there"
	elseif dir == 'out_to' or dir == 'in_to' then
		p "In that direction there"
	else
		p "In the {#first} direction there"
	end
	if ob:hint'plural' then
		p "are"
	else
		p "is"
	end
	p (ob:the_noun(),".")
end

mp.msg.enter = "<Enter>"
mp.msg.EMPTY = 'Excuse me?'
mp.msg.UNKNOWN_VERB = "Unknown verb"
mp.msg.UNKNOWN_VERB_HINT = "Maybe you meant"
mp.msg.INCOMPLETE = "The sentence must be supplemented."
mp.msg.INCOMPLETE_NOUN = "What do you want to apply the command to?"
mp.msg.UNKNOWN_OBJ = "Here is no such thing"
mp.msg.UNKNOWN_WORD = "Phrase not recognized"
mp.msg.HINT_WORDS = "Maybe you meant"
mp.msg.HINT_OR = "or"
mp.msg.HINT_AND = "and"
mp.msg.AND = "and"
mp.msg.MULTIPLE = "Here are"
mp.msg.LIVE_ACTION = "{#Firstit} would not like it."
mp.msg.NOTINV = function(t)
	p (lang.cap(t:the_noun()) .. " must be taken first.")
end
mp.msg.WORN = function(w)
	local hint = w:gram().hint
	pr (" (worn)")
end
mp.msg.OPEN = function(w)
	local hint = w:gram().hint
	pr (" (opened)")
end

mp.msg.EXITBEFORE = "May be, {#me} should to {#if_has/#where,supporter,get off,get out of} {#the_noun/#where}."

mp.default_Event = "Exam"
mp.default_Verb = "examine"

mp.msg.ACCESS1 = "{#The_noun/#first} {#is/#first} not accessible from here."
mp.msg.ACCESS2 = "{#The_noun/#second} {#is/#second} not accessible from here."

mp.msg.Look.HEREIS = "Here is"
mp.msg.Look.HEREARE = "Here are"
mp.msg.Look.SUPPORTER = function(o)
	p ("On ",o:the_noun())
end

mp.msg.NOROOM = function(w)
	if w == std.me() then
		p ("{#Me} {#is/#me} {#have/#me} too many things.")
	elseif w:has'supporter' then
		p ("There is no space on ", w:the_noun(), ".")
	else
		p ("There is no space in ", w:the_noun(), ".")
	end
end

mp.msg.Exam.SWITCHSTATE = "{#The_noun/#first} {#is/#first} switched {#if_has/#first,on,on,off}."
mp.msg.Exam.NOTHING = "nothing."
mp.msg.Exam.IS = "there is"
mp.msg.Exam.ARE = "there are"
mp.msg.Exam.IN = "In {#the_noun/#first}"
mp.msg.Exam.ON = "On {#the_noun/#first}"

mp.msg.Exam.DEFAULT = "{#Me} {#does/#me} not see anything unusual in {#the_noun/#first}.";
mp.msg.Exam.SELF = "{#Me} {#does/#me} not see anything unusual in {#yourself/#me}.";

--"открыт"
mp.msg.Exam.OPENED = "{#First} {#word/открыт,нст,#first}."
--"закрыт"
mp.msg.Exam.CLOSED = "{#First} {#word/закрыт,нст,#first}."
--"находить"
mp.msg.LookUnder.NOTHING = "{#Me} не {#word/находить,нст,#me} под {#first/тв} ничего интересного."
--"могу"
--"закрыт"
--"держать"
--"залезать"
mp.msg.Enter.ALREADY = "{#Me} уже {#if_has/#first,supporter,на,в} {#first/пр,2}."
mp.msg.Enter.INV = "{#Me} не {#word/могу,#me,нст} зайти в то, что {#word/держать,#me,нст} в руках."
mp.msg.Enter.IMPOSSIBLE = "Но в/на {#first/вн} невозможно войти, встать, сесть или лечь."
mp.msg.Enter.CLOSED = "{#First} {#word/закрыт,#first}, и {#me} не {#word/мочь,#me,нст} зайти туда."
mp.msg.Enter.ENTERED = "{#Me} {#word/залезать,нст,#me} {#if_has/#first,supporter,на,в} {#first/вн}."
mp.msg.Enter.DOOR_NOWHERE = "{#First} никуда не ведёт."
--"закрыт"
mp.msg.Enter.DOOR_CLOSED = "{#First} {#word/закрыт,#first}."

mp.msg.Walk.ALREADY = mp.msg.Enter.ALREADY
mp.msg.Walk.WALK = "Но {#first} и так находится здесь."

mp.msg.Enter.EXITBEFORE = "Сначала нужно {#if_has/#where,supporter,слезть с {#where/рд}.,покинуть {#where/вн}.}"

mp.msg.Exit.NOTHERE = "Но {#me} сейчас не {#if_has/#first,supporter,на,в} {#first/пр,2}."
mp.msg.Exit.NOWHERE = "Но {#me/дт} некуда выходить."
mp.msg.Exit.CLOSED = "Но {#first} {#word/закрыт,#first}."


--"покидать"
--"слезать"
mp.msg.Exit.EXITED = "{#Me} {#if_has/#first,supporter,{#word/слезать с,#me,нст} {#first/рд},{#word/покидать,#me,нст} {#first/вн}}."

mp.msg.Inv.NOTHING = "У {#me/рд} с собой ничего нет."
mp.msg.Inv.INV = "У {#me/рд} с собой"

--"открывать"
mp.msg.Open.OPEN = "{#Me} {#word/открывать,нст,#me} {#first/вн}."
mp.msg.Open.NOTOPENABLE = "{#First/вн} невозможно открыть."
--"открыт"
mp.msg.Open.WHENOPEN = "{#First/} уже {#word/открыт,#first}."
--"заперт"
mp.msg.Open.WHENLOCKED = "Похоже, что {#first/} {#word/заперт,#first}."

--"закрывать"
mp.msg.Close.CLOSE = "{#Me} {#word/закрывать,нст,#me} {#first/вн}."
mp.msg.Close.NOTOPENABLE = "{#First/вн} невозможно закрыть."
--"закрыт"
mp.msg.Close.WHENCLOSED = "{#First/} уже {#word/закрыт,#first}."

mp.msg.Lock.IMPOSSIBLE = "{#First/вн} невозможно запереть."
--"заперт"
mp.msg.Lock.LOCKED = "{#First} уже {#word/заперт,#first}."
--"закрыть"
mp.msg.Lock.OPEN = "Сначала необходимо закрыть {#first/вн}."
--"подходит"
mp.msg.Lock.WRONGKEY = "{#Second} не {#word/подходит,#second} к замку."
--"запирать"
mp.msg.Lock.LOCK = "{#Me} {#word/запирать,#me,нст} {#first/вн}."

mp.msg.Unlock.IMPOSSIBLE = "{#First/вн} невозможно отпереть."
--"заперт"
mp.msg.Unlock.NOTLOCKED = "{#First} не {#word/заперт,#first}."
--"подходит"
mp.msg.Unlock.WRONGKEY = "{#Second} не {#word/подходит,нст,#second} к замку."
--"отпирать"
mp.msg.Unlock.UNLOCK = "{#Me} {#word/отпирать,#me,нст} {#first/вн}."

mp.msg.Take.HAVE = "У {#me/вн} и так {#firstit} уже есть."
mp.msg.Take.TAKE = "{#Me} {#verb/take} {#first/вн}."
mp.msg.Take.SELF = "{#Me} есть у {#me/рд}."
--"находиться"
mp.msg.Take.WHERE = "Нельзя взять то, в/на чём {#me} {#word/находиться,#me}."

mp.msg.Take.LIFE = "{#First/дт} это вряд ли понравится."
--"закреплён"
mp.msg.Take.STATIC = "{#First} жестко {#word/закреплён,#first}."
mp.msg.Take.SCENERY = "{#First/вн} невозможно взять."

--"надет"
mp.msg.Take.WORN = "{#First} {#word/надет,#first} на {#firstwhere/вн}."
mp.msg.Take.PARTOF = "{#First} является частью {#firstwhere/рд}."

mp.msg.Remove.WHERE = "{#First} не находится {#if_has/#second,supporter,на,в} {#second/пр,2}."
mp.msg.Remove.REMOVE = "{#First} {#if_has/#second,supporter,поднят,извлечён из} {#second/рд}."

mp.msg.Drop.SELF = "У {#me/рд} не хватит ловкости."
mp.msg.Drop.WORN = "{#First/вн} сначала нужно снять."
--"помещать"
mp.msg.Insert.INSERT = "{#Me} {#word/помещать,нст,#me} {#first/вн} в {#second/вн}."
mp.msg.Insert.CLOSED = "{#Second} {#word/закрыт,#second}."
mp.msg.Insert.NOTCONTAINER = "{#Second} не {#if_hint/#second,plural,могут,может} что-либо содержать."
mp.msg.Insert.WHERE = "Нельзя поместить {#first/вн} внутрь себя."
mp.msg.Insert.ALREADY = "Но {#first} уже и так {#word/находиться,#first} там."
mp.msg.PutOn.NOTSUPPORTER = "Класть что-либо на {#second} бессмысленно."
--"класть"
mp.msg.PutOn.PUTON = "{#Me} {#word/класть,нст,#me} {#first/вн} на {#second/вн}."
mp.msg.PutOn.WHERE = "Нельзя поместить {#first/вн} на себя."

--"брошен"
mp.msg.Drop.DROP = "{#First} {#word/брошен,#first}."

mp.msg.ThrowAt.NOTLIFE = "Бросать {#first/вн} в {#second/вн} бесполезно."
mp.msg.ThrowAt.THROW = "У {#me/рд} не хватает решимости бросить {#first/вн} в {#second/вн}."


mp.msg.Wear.NOTCLOTHES = "Надеть {#first/вн} невозможно."
mp.msg.Wear.WORN = "{#First} уже на {#me/дт}."
--"надевать"
mp.msg.Wear.WEAR = "{#Me} {#word/надевать,#me,нст} {#first/вн}."

mp.msg.Disrobe.NOTWORN = "{#First} не на {#me/дт}."
--"снимать"
mp.msg.Disrobe.DISROBE = "{#Me} {#word/снимать,#me,нст} {#first/вн}."

mp.msg.SwitchOn.NONSWITCHABLE = "{#First/вн} невозможно включить."
--"включён"
mp.msg.SwitchOn.ALREADY = "{#First} уже {#word/включён,#first}."
--"включать"
mp.msg.SwitchOn.SWITCHON = "{#Me} {#word/включать,#me,нст} {#first/вн}."

mp.msg.SwitchOff.NONSWITCHABLE = "{#First/вн} невозможно выключить."
--"выключён"
mp.msg.SwitchOff.ALREADY = "{#First} уже {#word/выключён,#first}."
--"выключать"
mp.msg.SwitchOff.SWITCHOFF = "{#Me} {#word/выключать,#me,нст} {#first/вн}."

--"годится"
mp.msg.Eat.NOTEDIBLE = "{#First} не {#word/годится,#first} в пищу."
mp.msg.Taste.TASTE = "Никакого необычного вкуса нет."

--"съедать"
mp.msg.Eat.EAT = "{#Me} {#word/съедать,нст,#me} {#first/вн}."
mp.msg.Drink.IMPOSSIBLE = "Выпить {#first/вн} невозможно."

mp.msg.Push.STATIC = "{#First/вн} трудно сдвинуть с места."
mp.msg.Push.SCENERY = "{#First/вн} двигать невозможно."
mp.msg.Push.PUSH = "Ничего не произошло."

mp.msg.Pull.STATIC = "{#First/вн} трудно сдвинуть с места."
mp.msg.Pull.SCENERY = "{#First/вн} двигать невозможно."
mp.msg.Pull.PULL = "Ничего не произошло."

mp.msg.Turn.STATIC = "{#First/вн} трудно сдвинуть с места."
mp.msg.Turn.SCENERY = "{#First/вн} двигать невозможно."
mp.msg.Turn.TURN = "Ничего не произошло."

mp.msg.Wait.WAIT = "Проходит немного времени."

mp.msg.Touch.LIVE = "Не стоит давать волю рукам."
mp.msg.Touch.TOUCH = "Никаких необычных ощущений нет."
mp.msg.Touch.MYSELF = "{#Me} на месте."

mp.msg.Rub.RUB = "Тереть {#first/вн} бессмысленно."
mp.msg.Sing.SING = "С таким слухом и голосом как у {#me/рд} этого лучше не делать."

mp.msg.Give.MYSELF = "{#First} и так у {#me/рд} есть."
mp.msg.Give.GIVE = "{#Second/вн} это не заинтересовало."
mp.msg.Show.SHOW = "{#Second/вн} это не впечатлило."

mp.msg.Burn.BURN = "Поджигать {#first/вн} бессмысленно."
mp.msg.Burn.BURN2 = "Поджигать {#first/вн} {#second/тв} бессмысленно."
--"поверь"
mp.msg.Wake.WAKE = "Это не сон, а явь."
mp.msg.WakeOther.WAKE = "Будить {#first/вн} не стоит."
mp.msg.WakeOther.NOTLIVE = "Бессмысленно будить {#first/вн}."

mp.msg.PushDir.PUSH = "Передвигать это нет смысла."

mp.msg.Kiss.NOTLIVE = "Странное желание."
mp.msg.Kiss.KISS = "{#Firstit/дт} это может не понравиться."
mp.msg.Kiss.MYSELF = "Ну уж нет."

mp.msg.Think.THINK = "Отличная идея!"
mp.msg.Smell.SMELL = "Никакого необычного запаха нет."
mp.msg.Smell.SMELL2 = "Пахнет как {#first}."

mp.msg.Listen.LISTEN = "Никаких необычных звуков нет."
--"прислушаться"
mp.msg.Listen.LISTEN2 = "{#Me} {#word/прислушаться,#me,прш} к {#first/дт}. Никаких необычных звуков нет."

--"выкопать"
mp.msg.Dig.DIG = "{#Me} ничего не {#word/выкопать,#me,прш}."
mp.msg.Dig.DIG2 = "Копать {#first/вн} бессмысленно."
mp.msg.Dig.DIG3 = "Копать {#first/вн} {#second/тв} бессмысленно."

mp.msg.Cut.CUT = "Резать {#first/вн} бессмысленно."
mp.msg.Cut.CUT2 = "Резать {#first/вн} {#second/тв} бессмысленно."

mp.msg.Tear.TEAR = "Рвать {#first/вн} бессмысленно."

mp.msg.Tie.TIE = "Привязывать {#first/вн} бессмысленно."
mp.msg.Tie.TIE2 = "Привязывать {#first/вн} к {#second/дт} бессмысленно."

mp.msg.Blow.BLOW = "Дуть на/в {#first/вн} бессмысленно."

mp.msg.Attack.LIFE = "Агрессия к {#first/дт} неоправданна."
mp.msg.Attack.ATTACK = "Сила есть -- ума не надо?"
--"хотеть"
mp.msg.Sleep.SLEEP = "{#Me} не {#word/хотеть,#me,нст} спать."
mp.msg.Swim.SWIM = "Для этого здесь недостаточно воды."
mp.msg.Fill.FILL = "Наполнять {#first/вн} бессмысленно."
--"подпрыгивать"
mp.msg.Jump.JUMP = "{#Me} глупо {#word/подпрыгивать,#me,нст}."
mp.msg.JumpOver.JUMPOVER = "Прыгать через {#first/вн} бессмысленно."

--"находить"
mp.msg.Consult.CONSULT = "{#Me} не {#word/находить,#me,нст} ничего подходящего."

--"помахать"
mp.msg.WaveHands.WAVE = "{#Me} глупо {#word/помахать,прш,#me} руками."
mp.msg.Wave.WAVE = "{#Me} глупо {#word/помахать,прш,#me} {#first/тв}."

mp.msg.Talk.SELF = "Беседы не получилось."
--"уметь"
mp.msg.Talk.NOTLIVE = "{#First} не {#word/уметь,#first,нст} разговаривать."
--"отреагировать"
mp.msg.Talk.LIVE = "{#First} никак не {#word/отреагировать,#first}."

mp.msg.Tell.SELF = "Беседы не получилось."

--"безмолвен"
mp.msg.Tell.NOTLIVE = "{#First} {#word/безмолвен,#first}."
--"отреагировать"
mp.msg.Tell.LIVE = "{#First} никак не {#word/отреагировать,#first}."
--"нашёл"
mp.msg.Tell.EMPTY = "{#Me} не {#word/нашёл,#me,прш} что сказать."

--"отвечать"
mp.msg.Ask.NOTLIVE = "Ответа не последовало."
--"ответить"
mp.msg.Ask.LIVE = "{#First} не {#word/ответить,прш,#first}."
--"придумать"
mp.msg.Ask.EMPTY = "{#Me} не {#word/придумать,#me,прш} что спросить."
mp.msg.Ask.SELF = "Хороший вопрос."

--"отвечать"
mp.msg.Answer.NOTLIVE = "Ответа не последовало."
--"ответить"
mp.msg.Answer.LIVE = "{#First} не {#word/ответить,прш,#first}."
--"придумать"
mp.msg.Answer.EMPTY = "{#Me} не {#word/придумать,#me,прш} что ответить."
mp.msg.Answer.SELF = "Хороший ответ."

mp.msg.Yes.YES = "Вопрос был риторическим."
--"продаваться"
mp.msg.Buy.BUY = "{#First} не {#word/продаваться,нст,#first}."
mp.hint.live = 'live'
mp.hint.nonlive = 'nonlive'
mp.hint.neuter = 'neutwe'
mp.hint.male = 'male'
mp.hint.female = 'female'
mp.hint.plural = 'plural'
mp.hint.first = 'first'
mp.hint.second = 'second'
mp.hint.third = 'third'

mp.keyboard_space = '<пробел>'
mp.keyboard_backspace = '<удалить>'

mp.msg.verbs.take = -"брать,#me,нст"

local function dict(t, hint)
	local g = std.split(hint, ",")
	for _, v in ipairs(g) do
		if t[v] then
			return t[v]
		end
	end
end

function mp:myself(ob, hint)
	if ob:hint'first' then
		return { "myself", "me" }
	end
	if ob:hint'second' then
		return { "yourself", "me", "myself" }
	end
	if ob:hint'plural' then
		return { "themselves", "our" }
	end
	if ob:hint'female' then
		return { "herself", "me" }
	end
	if ob:hint'male' then
		return { "himself", "me" }
	end
	return { "itself" }
end

function mp:it(w, hint)
	hint = hint or ''
	if w:hint'plural' then
		return "they"
	elseif w:hint'female' then
		return "she"
	elseif w:hint'male' then
		return "he"
	end
	return "it"
end

function mp:synonyms(w, hint)
	local t = self:it(w, hint)
	local w = { t }
	if t == 'его' or t == 'её' or t == 'ее' or t == 'ей' or t == 'им' then t = 'н'..t; w[2] = t end
	return w
end

mp.keyboard = {
	'А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й',
	'К','Л','М','Н','О','П','Р','О','С','Т','У','Ф',
	'Х','Ц','Ч','Ш','Щ','Ь','Ы','Ъ','Э','Ю','Я'
}

local function hints(w)
	local h = std.split(w, ",")
	local hints = {}
	for _, v in ipairs(h) do
		hints[v] = true
	end
	return hints
end

function mp:err_noun(noun)
	if noun == '*' then return "{$fmt em|<любое слово>}" end
	local hint = std.split(noun, "/")
	local rc = "{$fmt em|существительное в"
	if #hint == 2 then
		local h = hints(hint[2])
		local acc = 'именительном'
		if h["им"] then
			acc = 'именительном'
		elseif h["рд"] then
			acc = 'родительном'
		elseif h["дт"] then
			acc = 'дательном'
		elseif h["вн"] then
			acc = 'винительном'
		elseif h["тв"] then
			acc = 'творительном'
		elseif h["пр"] or h["пр2"] then
			acc = 'предложном'
		end
		rc = rc ..  " "..acc .. " падеже"
	else
		rc = rc .. " именительном падеже"
	end
	rc = rc .. "}"
	return rc
end

function mp.shortcut.vo(hint)
	return "в ".. hint
--	local w = std.split(hint)
--	w = w[#w]
--	if mp.utf.len(w) > 2 and
--		(lang.is_vowel(utf.char(w, 1)) or
--		lang.is_vowel(utf.char(w, 2))) then
--		return "в ".. hint
--	end
--	return "во ".. hint
end

function mp.shortcut.so(hint)
	return "с ".. hint
--	local w = std.split(hint)
--	w = w[#w]
--	if mp.utf.len(w) > 2 and
--		(lang.is_vowel(utf.char(w, 1)) or
--		lang.is_vowel(utf.char(w, 2))) then
--		return "с ".. hint
--	end
--	return "со ".. hint
end

function mp:before_Enter(w)
	if mp:compass_dir(w) then
		mp:xaction("Walk", w)
		return
	end
	return false
end

function mp:MetaHelp()

	pn("{$fmt b|КАК ИГРАТЬ?}")

	pn([[Вводите ваши действия в виде простых предложений вида: глагол -- существительное. Например:^
> открыть дверь^
> отпереть дверь ключом^
> идти на север^
> взять кепку^
^
Чтобы осмотреть предмет, введите "осмотреть книгу" или просто "книга".^
^
Чтобы осмотреть всю сцену, наберите "осмотреть" или нажмите "ввод".^
^
Для того чтобы узнать, что вы носите с собой, наберите "инвентарь".^
^
Для перемещений используйте стороны света, например: "идти на север" или "север" или просто "с".
^^
Вы можете воспользоваться клавишой "TAB" для автодополнения ввода.
]])
end

function mp.token.compass1(w)
	return "{noun_obj}/@n_to,compass|{noun_obj}/@ne_to,compass|{noun_obj}/@e_to,compass|{noun_obj}/@se_to,compass|{noun_obj}/@s_to,compass|{noun_obj}/@sw_to,compass|{noun_obj}/@w_to,compass|{noun_obj}/@nw_to,compass"
end

function mp.token.compass2(w)
	return "{noun_obj}/@u_to,compass|{noun_obj}/@d_to,compass|{noun_obj}/@in_to,compass|{noun_obj}/@out_to,compass"
end

std.mod_init(function(s)
Verb { "#Walk",
	"идти,иду,[по|подо|за|во]йти,[по|подо|за|во]йди,иди,[ |по|под]бежать,бег/и,влез/ть,[ |по]ехать,едь,поеду,сесть,сядь,сяду,лечь,ляг,вста/ть",
	"на {compass1} : Walk",
	"на|в|во {noun}/вн,scene,enterable : Enter",
	"к {noun}/дт,scene : Walk",
	"{compass2}: Walk" }

Verb { "#Exit",
	"выйти,выйд/и,уйти,уйд/и,вылез/ти,выхо/ди,обратно,назад,выбраться,выберись,выберусь,выбираться",
	"из|с|со {noun}/рд,scene : Exit",
	"?наружу : Exit" }

Verb { "#Exam",
	"examine,exam,check,describe,watch,look",
	"{noun} : Exam",
	"?all : Look",
	"inventory : Inv",
	"~ under {noun} : LookUnder",
	"~ in|inside|into|through|on {noun} : Search",
	"~ up * in {noun} : Consult reverse",
}

Verb { "#Search",
	"искать,обыскать,ищ/и,обыщ/и,изуч/ать,исслед/овать",
	"{noun}/вн : Search",
	"в|во|на {noun}/пр,2 : Search",
	"под {noun}/тв : LookUnder",
	"~ в|во {noun}/пр,2 * : Consult",
	"~ * в|во {noun}/пр,2 : Consult reverse",
}

Verb { "#Open",
	"откр/ыть,распах/нуть,раскр/ыть,отпереть,отвори/ть,отопр/и",
	"{noun}/вн : Open",
	"{noun}/вн {noun}/тв : Unlock",
	"~ {noun}/тв {noun}/вн : Unlock reverse",
}

Verb { "#Close",
	"закр/ыть,запереть",
	"{noun}/вн : Close",
	"{noun}/вн {noun}/тв : Lock",
	"~ {noun}/тв {noun}/вн : Lock reverse",
}

Verb { "#Inv",
	"инв/ентарь,с собой",
	"Inv" }

Verb { "#Take",
	"взять,возьм/и,[ |за|подо]брать,[ |за|под]бер/и,доста/ть,схват/ить,украсть,украд/и,извле/чь,вын/уть,вытащ/ить",
	"{noun}/вн,scene : Take",
	"{noun}/вн,scene из|с|со|у {noun}/рд,inside,holder: Remove",
	"~ из|с|со|у {noun}/рд,inside,holder {noun}/вн,scene: Remove reverse",
}

Verb { "#Drop",
	"полож/ить,постав/ить,посади/ть,класть,клади/,вставь/,помест/ить,сун/уть,засун/уть,воткн/уть,втык/ать,встав/ить,влож/ить",
	"{noun}/вн,held : Drop",
	"{noun}/вн,held в|во {noun}/вн,inside : Insert",
	"~ {noun}/вн,held внутрь {noun}/рд : Insert",
	"{noun}/вн,held на {noun}/вн : PutOn",
	"~ в|во {noun}/вн {noun}/вн : Insert reverse",
	"~ внутрь {noun}/рд {noun}/вн : Insert reverse",
	"~ на {noun}/вн {noun}/вн : PutOn reverse",
}

Verb {
	"#ThrowAt",
	"брос/ить,выбро/сить,кин/уть,кида/ть,швыр/нуть,метн/уть,метать",
	"{noun}/вн,held : Drop",
	"{noun}/вн,held в|во|на {noun}/вн : ThrowAt",
	"~ в|во|на {noun}/вн {noun}/вн : ThrowAt reverse",
	"~ {noun}/вн {noun}/дт : ThrowAt",
	"~ {noun}/дт {noun}/вн : ThrowAt reverse",

}

Verb {
	"#Wear",
	"наде/ть,оде/ть,облачи/ться",
	"{noun}/вн,held : Wear",
}

Verb {
	"#Disrobe",
	"снять,сним/ать",
	"{noun}/вн,worn : Disrobe",
	"~ {noun}/вн с|со {noun}/рд : Remove",
	"~ с|со {noun}/рд {noun}/вн : Remove reverse"
}

Verb {
	"#SwitchOn",
	"включ/ить,вруб/ить,активи/ровать",
	"{noun}/вн : SwitchOn",
}

Verb {
	"#SwitchOff",
	"выключ/ить,выруб/ить,деактиви/ровать",
	"{noun}/вн : SwitchOff",
}

Verb {
	"#Eat",
	"есть,съе/сть,куша/ть,скуша/ть,сожр/ать,жри,жрать,ешь",
	"{noun}/вн,held : Eat",
}

Verb {
	"#Taste",
	"лизать,лизн/уть,попроб/овать,полиз/ать,сосать,пососа/ть",
	"{noun}/вн : Taste"
}

Verb {
	"#Drink",
	"пить,выпить,выпей,выпью,пью",
	"{noun}/вн,held : Drink",
}

Verb {
	"#Push",
	"толк/ать,пих/ать,нажим/ать,нажм/и,нажать,сдвин/уть,подвин/уть,двига/ть,задви/нуть,запих/нуть,затолк/ать,[ |на]давить",
	"?на {noun}/вн : Push",
	"{noun}/вн на|в|во {noun}/вн : Transfer",
	"{noun}/вн {compass2} : Transfer",
	"~ на|в|во {noun}/вн {noun}/вн : Transfer reverse",
	"~ {compass2} {noun}/вн : Transfer reverse"
}

Verb {
	"#Pull",
	"[ |вы|по]тян/уть,[ |вы|по]тащ/ить,тягать,[ |по]волоч/ь,[ |по]волок/ти,дёрн/уть,дёрг/ать",
	"?за {noun}/вн : Pull",
	"{noun}/вн на|в|во {noun}/вн : Transfer",
	"{noun}/вн {compass2} : Transfer",
	"~ на|в|во {noun}/вн {noun}/вн : Transfer reverse",
	"~ {compass2} {noun}/вн : Transfer reverse"
}

Verb {
	"#Turn",
	"враща/ть,поверн/уть,верт/еть,поверт/еть,крути/ть",
	"{noun}/вн : Turn"
}

Verb {
	"#Wait",
	"ждать,жди,жду,подожд/ать,ожид/ать",
	"Wait"
}

Verb {
	"#Rub",
	"тереть,потр/и,потереть,тру,три",
	"{noun}/вн : Rub"
}

Verb {
	"#Sing",
	"петь,спеть,спою,спой/,пой",
	"Sing"
}

Verb {
	"#Touch",
	"[ |по]трога/ть,трон/уть,дотрон/уться,[ |при]косну/ться,касать/ся,[ |по|о]щупа/ть,[ |по]глад/ить",
	"{noun}/вн : Touch",
	"~ до {noun}/рд : Touch",
	"~ к {noun}/дт : Touch",
	"~ {noun}/рд : Touch",
}

Verb {
	"#Give",
	"дать,отда/ть,предло/жить,предла/гать,дам,даю,дадим",
	"{noun}/вн,held {noun}/дт,live : Give",
	"~ {noun}/дт,live {noun}/вн,held : Give reverse",
}

Verb {
	"#Show",
	"показ/ать,покаж/и",
	"{noun}/вн,held {noun}/дт,live : Show",
	"~ {noun}/дт,live {noun}/вн,held : Show reverse",
}

Verb {
	"#Burn",
	"[ |под]жечь,жг/и,подожги/,поджиг/ай,зажг/и,зажиг/ай,зажечь",
	"{noun}/вн : Burn",
	"{noun}/вн {noun}/тв,held : Burn",
	"~ {noun}/тв,held {noun}/вн reverse",
}

Verb {
	"#Wake",
	"будить,разбуд/ить,просн/уться,бужу",
	"{noun}/вн,live : WakeOther",
	"Wake",
}

Verb {
	"#Kiss",
	"целовать,поцел/овать,чмок/нуть,обним/ать,обнять,целуй",
	"{noun}/вн,live : Kiss"
}

Verb {
	"#Think",
	"дума/ть,мысл/ить,подум/ать,рассужд/ать",
	"Think"
}

Verb {
	"#Smell",
	"нюха/ть,понюха/ть,занюх/ать,нюхн/уть,принюх/аться",
	"Smell",
	"{noun}/вн : Smell"
}

Verb {
	"#Listen",
	"слуша/ть,послуша/ть,прислушать/ся,слыш/ать,слух/",
	"Listen",
	"{noun}/вн : Listen",
	"~ к {noun}/дт : Listen",
}

Verb {
	"#Dig",
	"копа/ть,выкопа/ть,выры/ть,рыть,рой,вырой",
	"Dig",
	"{noun}/вн,scene : Dig",
	"{noun}/вн,scene {noun}/тв,held : Dig",
	"~ {noun}/тв,held {noun}/вн,scene : Dig reverse",
}

Verb {
	"#Cut",
	"[ |раз|на|по]рез/ать,[ |раз|на|по]реж/ь",
	"{noun}/вн : Cut",
	"{noun}/вн {noun}/тв,held: Cut",
	"~ {noun}/тв,held {noun}/вн: Cut reverse"
}

Verb {
	"#Tear",
	"[ |по|разо|со]рвать,[ |по|разо|со]рви/,[ |по|разо|со]рву",
	"{noun}/вн : Tear",
}

Verb {
	"#Tie",
	"[при|с]вяз/ать,[при|с]вяж/и",
	"{noun}/вн : Tie",
	"{noun}/вн к {noun}/дт : Tie",
	"~ {noun}/вн с|со {noun}/тв : Tie",
	"~ к {noun}/дт {noun}/вн : Tie reverse",
	"~ с|со {noun}/тв {noun}/вн : Tie reverse",
}

Verb {
	"#Blow",
	"дуть,дуй/,дун/ь,задут/ь,задун/ь,задую,задуй/",
	"в|во|на {noun}/вн : Blow",
	"~ {noun}/вн : Blow", -- задуть
}

Verb {
	"#Attack",
	"атак/овать,бить,бей/,удар/ить,[ |с|раз|по|вы]лома/ть,уби/ть,[ |раз]разруш/ить,поби/ть,побей/,побь/,круш/ить,напасть,напад/ать",
	"?на {noun}/вн : Attack"
}

Verb {
	"#Sleep",
	"спать,усн/уть,засн/уть,дрем/ать",
	"Sleep",
}

Verb {
	"#Swim",
	"плыть,плав/ать,ныря/ть,уплы/ть,поплы/ть,нырн/уть,[ |ис]купа/ться",
	"Swim",
}

Verb {
	"#Consult",
	"[ |про|по]чита/ть,проч/есть",
	"в|во {noun}/пр,2 о|об|обо|про * : Consult",
	"~ о|об|обо|про * в|во {noun}/пр,2 : Consult reverse",
	"~ {noun}/вн : Exam",
}

Verb {
	"#Fill",
	"наполн/ить,нали/ть",
	"?в {noun}/вн : Fill",
	"~ внутрь {noun}/рд : Fill"
}

Verb {
	"#Jump",
	"[ |по]прыг/ать,скак/ать,[ |пере|под]прыг/нуть,переска/чить",
	"Jump",
	"через {noun}/вн,scene : JumpOver",
	"~ {noun}/вн,scene : JumpOver",
}

Verb {
	"#Wave",
	"мах/ать,помах/ать,помаш/и",
	"WaveHands",
	"~ руками : WaveHands",
	"{noun}/тв,held : Wave"
}

Verb {
	"#Climb",
	"[ |за|по|в]лез/ть,карабк/аться,взбир/ться,взобраться,взбери/сь",
	"на {noun}/вн,scene : Climb",
	"по {noun}/дт,scene : Climb",
	"~ в|во {noun}/вн,scene : Enter",
	"{compass2}: Walk",
}

Verb {
	"#GetOff",
	"слез/ть,спусти/ться,встать,встан/ь",
	"Exit",
	"{compass2}: Walk",
	"с|со {noun}/рд,scene : GetOff",
}

Verb {
	"#Buy",
	"купи/ть,покупать",
	"{noun}/вн,scene : Buy"
}

Verb {
	"#Talk",
	"[ |по]говор/ить,[ |по]бесед/овать,разговарива/ть",
	"с|со {noun}/тв,live : Talk"

}

Verb {
	"#Tell",
	"сказать,сообщ/ить,рассказать,расскаж/ите",
	"{noun}/дт,live о|об|обо|про * : Tell",
	"~ * {noun}/дт,live : Tell reverse",
	"~ {noun}/дт * : AskTo",
}

Verb {
	"#Ask",
	"спросит/ь,расспросит/ь",
	"?у {noun}/вн,live о|об|обо|про * : Ask",
	"~ о|об|обо|про * ?у {noun}/вн,live : Ask reverse",
}

Verb {
	"#AskFor",
	"попроси/ть,выпроси/ть,уговори/ть,проси/ть,попрош/у,выпрош/у",
	"у {noun}/вн,live * : AskFor",
	"~ * у {noun}/вн,live : AskFor reverse",
	"~ {noun}/вн,live * : AskTo",
}

Verb {
	"#Answer",
	"ответ/ить,отвеч/ать",
	"{noun}/дт,live * : Answer",
	"~ * {noun}/дт,live : Answer reverse",
}

Verb {
	"#Yes",
	"да",
	"Yes",
}

Verb {
	"#No",
	"нет",
	"No",
}

if DEBUG then
	MetaVerb {
		"#MetaWord",
		"~_слово",
		"* : MetaWord"
	}
	MetaVerb {
		"#MetaNoun",
		"~_сущ/ествительное",
		"* : MetaNoun"
	}
	MetaVerb {
		"#MetaTrace",
		"~_трассировка",
		"да : MetaTraceOn",
		"нет : MetaTraceOff",
	}
	MetaVerb {
		"#MetaDump",
		"~_дамп",
		"MetaDump"
	}
end
MetaVerb {
	"#MetaTranscript",
	"~транскрипт",
	"да : MetaTranscriptOn",
	"нет : MetaTranscriptOff",
	"MetaTranscript",
}

MetaVerb {
	"#MetaSave",
	"~сохрани/ть",
	"MetaSave"
}
MetaVerb {
	"#MetaLoad",
	"~загрузи/ть",
	"MetaLoad"
}

if DEBUG then
MetaVerb {
	"#MetaAutoplay",
	"~автоскрипт",
	"MetaAutoplay"
}
end

mp.msg.MetaRestart.RESTART = "Начать заново?";

MetaVerb {
	"#MetaRestart",
	"~заново,~рестарт",
	"MetaRestart"
}
MetaVerb {
	"#MetaHelp",
	"~помощь,помоги/те",
	"MetaHelp",
}
end, 1)

std.mod_start(function()
	if mp.undo > 0 then
		mp.msg.MetaUndo.EMPTY = "Отменять нечего."
		MetaVerb {
			"#MetaUndo",
			"~отмен/ить",
			"MetaUndo",
		}
	end
end)
-- Dialog
std.phr.default_Event = "Exam"

Verb ({"~ сказать", "{select} : Exam" }, std.dlg)
Verb ({'#Next', "дальше", "Next" }, mp.cutscene)
Verb ({'#Exam', "~ осмотреть", "Look" }, std.dlg)

mp.cutscene.default_Verb = "дальше"
mp.cutscene.help = fmt.em "<дальше>";

std.dlg.default_Verb = "осмотреть"

function content(...)
	return mp:content(...)
end
std.player.word = "you/plural,second"