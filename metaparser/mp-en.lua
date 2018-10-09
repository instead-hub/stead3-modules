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
	local t = s:noun(...)
	if s:hint'proper' or s:hint'surname' then
		return t
	end
	return "the "..t
end

std.obj.a_noun = function(s, ...)
	local t = s:noun(...)
	if s:hint'plural' then
		return t
	end
	if lang.is_vowel(utf.char(t, 1)) then
		return "an "..t
	else
		return "a "..t
	end
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

function mp.shortcut.thenoun(hint)
	local w = str_split(hint, ",")
	if #w ~= 2 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then
		return ""
	end
	return ob:the_noun()
end

function mp.shortcut.anoun(hint)
	local w = str_split(hint, ",")
	if #w ~= 2 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then
		return ""
	end
	return ob:a_noun()
end

function mp.shortcut.thefirst(hint)
	return mp.first:the_noun()
end

function mp.shortcut.thesecond(hint)
	return mp.second:the_noun()
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

function mp.shortcut.doesnt(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob:hint'plural' or ob:hint'first' or ob:hint'second' then
		return "don't"
	end
	return "doesn't"
end

function mp.shortcut.present(hint)
	local w = str_split(hint, ",")
	if #w ~= 2 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob:hint'plural' or ob:hint'first' or ob:hint'second' then
		return w[2]
	end
	return w[2]..'s'
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

function mp.shortcut.thats(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob == std.me() then
		if ob:hint'first' then return "i'm" end
		return ob:noun()..(ob:hint'plural' and "'re" or "'s")
	elseif ob:has'plural' then
		return "they're"
	elseif ob:has'female' then
		return "she's"
	elseif ob:has'male' then
		return "he's"
	end
	return "that's"
end

function mp.shortcut.his(hint)
	local w = str_split(hint, ",")
	local ob
	if #w ~= 1 then
		ob = std.me()
	else
		ob = mp:shortcut_obj(w[1])
	end
	if not ob then return "" end
	if ob == std.me() then
		if ob:hint'first' then
			return "my"
		end
		if ob:hint'second' then
			return ob:hint'plural' and "yours" or "your"
		end
	end
	if ob:has'plural' then
		return "their"
	elseif ob:has'female' then
		return "her"
	elseif ob:has'male' then
		return "his"
	end
	return "its"
end

function mp.shortcut.that(hint)
	local w = str_split(hint, ",")
	if #w ~= 1 then
		return ""
	end
	local ob = mp:shortcut_obj(w[1])
	if not ob then return "" end
	if ob == std.me() then
		if ob:hint'first' then return "i" end
		return ob:noun()
	end
	if ob:has'plural' then
		return "those"
	end
	return "that"
end

mp.msg.SCENE = "{#Me} {#is/#me} {#if_has/#here,supporter,on,in} {#thenoun/#here}.";
mp.msg.INSIDE_SCENE = "{#Me} {#is/#me} {#if_has/#where,supporter,on,in} {#thenoun/#where}.";
mp.msg.TITLE_INSIDE = "({#if_has/#where,supporter,on,in} {#thenoun/#where})";

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

mp.msg.EXITBEFORE = "May be, {#me} should to {#if_has/#where,supporter,get off,get out of} {#thenoun/#where}."

mp.default_Event = "Exam"
mp.default_Verb = "examine"

mp.msg.ACCESS1 = "{#Thefirst} {#is/#first} not accessible from here."
mp.msg.ACCESS2 = "{#Thesecond} {#is/#second} not accessible from here."

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

mp.msg.Exam.SWITCHSTATE = "{#Thefirst} {#is/#first} switched {#if_has/#first,on,on,off}."
mp.msg.Exam.NOTHING = "nothing."
mp.msg.Exam.IS = "there is"
mp.msg.Exam.ARE = "there are"
mp.msg.Exam.IN = "In {#thefirst}"
mp.msg.Exam.ON = "On {#thefirst}"

mp.msg.Exam.DEFAULT = "{#Me} {#does/#me} not see anything unusual in {#thefirst}.";
mp.msg.Exam.SELF = "{#Me} {#does/#me} not see anything unusual in {#yourself/#me}.";

mp.msg.Exam.OPENED = "{#Thefirst} {#is/#first} opened."
mp.msg.Exam.CLOSED = "{#Thefirst} {#is/#first} closed."
mp.msg.LookUnder.NOTHING = "{#Me} find nothing of interest under {#thefirst}."

mp.msg.Enter.ALREADY = "{#Me} {#is/#me} already {#if_has/#first,supporter,on,in} {#thefirst}."
mp.msg.Enter.INV = "{#Me} {#is/#me} unable to enter the thing {#me} {#is} holding."
mp.msg.Enter.IMPOSSIBLE = "But {#me} {#is/#me} unable to enter in/on {#thefirst}."
mp.msg.Enter.CLOSED = "{#Thefirst} {#is/#first} closed and {#me} can't enter there."
mp.msg.Enter.ENTERED = "{#Me} {#word/залезать,нст,#me} {#if_has/#first,supporter,на,в} {#first/вн}."
mp.msg.Enter.DOOR_NOWHERE = "{#Thefirst} {#present/#first,lead} nowhere."
mp.msg.Enter.DOOR_CLOSED = "{#Thefirst} {#is/#first} closed."

mp.msg.Walk.ALREADY = mp.msg.Enter.ALREADY
mp.msg.Walk.WALK = "But {#thefirst} {#is/#first} already here."

mp.msg.Enter.EXITBEFORE = "{#Me} {#present/#me,need} to {#if_has/#where,supporter,get off from,leave} {#thefirst} first."

mp.msg.Exit.NOTHERE = "But {#me} {#is/#me} not {#if_has/#first,supporter,on,in} {#thefirst}."
mp.msg.Exit.NOWHERE = "But {#me} {#have/#me} no way to exit."
mp.msg.Exit.CLOSED = "But {#thefirst} {#is/#first} closed."
mp.msg.Exit.EXITED = "{#Me} {#if_has/#first,supporter,{#present/#me,get} off,{#present/#me,leave}} {#thefirst}."

mp.msg.Inv.NOTHING = "{#Me} {#have/#me} nothing."
mp.msg.Inv.INV = "{#Me} {#have/#me}"

mp.msg.Open.OPEN = "{#Me} {#present/#me,open} {#thefirst}."
mp.msg.Open.NOTOPENABLE = "{#Thefirst} {#is/#first} not openable."
mp.msg.Open.WHENOPEN = "{#Thenoun/first/} {#is/#first} already opened."
mp.msg.Open.WHENLOCKED = "It's seems that {#thefirst} {#is/#first} locked."

mp.msg.Close.CLOSE = "{#Me} {#present/#me,close} {#thefirst}."
mp.msg.Close.NOTOPENABLE = "{#Thats/#first} not something {#me} can close."
mp.msg.Close.WHENCLOSED = "{#Thefirst} {#is/#first} already closed."

mp.msg.Lock.IMPOSSIBLE = "{#Firstit} {#doesnt/#first} seem to be something {#me} can lock."
mp.msg.Lock.LOCKED = "{#Thefirst} {#is/#first} already locked."
mp.msg.Lock.OPEN = "{#Me} should close {#thefirst} first."
mp.msg.Lock.WRONGKEY = "{#That/#second} {#doesnt/#second} seem to fit the lock."
mp.msg.Lock.LOCK = "{#Me} {#present/#me,lock} {#thefirst}."

mp.msg.Unlock.IMPOSSIBLE = "{#Firstit} {#doesnt/#first} seem to be something {#me} can unlock."
mp.msg.Unlock.NOTLOCKED = "{#Thefirst} {#is/#first} not locked."
mp.msg.Unlock.WRONGKEY = "{#That/#second} {#doesnt/#second} seem to fit the lock."
mp.msg.Unlock.UNLOCK = "{#Me} {#present/#me,unlock} {#thefirst}."

mp.msg.Take.HAVE = "{#Me} already {#have/#me} {#thefirst}."
mp.msg.Take.TAKE = "{#Me} {#present/#me,take} {#thefirst."
mp.msg.Take.SELF = "{#Me} always {#have/#me} {#yourself/#me}."

mp.msg.Take.WHERE = "It is impossible to take the thing {#me} {#is/#me} standing in/on."

mp.msg.Take.LIFE = "{#Firstit}'ll not like it."
mp.msg.Take.STATIC = "{#Thats/#first} fixed in place."
mp.msg.Take.SCENERY = "{#Thats/#first} hardly portable."

mp.msg.Take.WORN = "{#Thefirst} {#is/#first} worn on {#thenoun/#firstwhere}."
mp.msg.Take.PARTOF = "{#Thefirst} {#is/#first} a part of {#thenoun/#firstwhere}."

mp.msg.Remove.WHERE = "But {#firstit} {#is/#first} not there now."
mp.msg.Remove.REMOVE = "{#Thefirst} {#is/#first} {#if_has/#second,supporter,taken,removed} from {#thesecond}."

mp.msg.Drop.SELF = "{#Me} can't {#does/#me} that."
mp.msg.Drop.WORN = "{#Me}'ll to take off {#thefirst} first."

mp.msg.Insert.INSERT = "{#Me} {#present/#me,put} {#thefirst} into {#thesecond}."
mp.msg.Insert.CLOSED = "{#Thesecond} {#is/#second} closed."
mp.msg.Insert.NOTCONTAINER = "{#Thesecond} can't contain things."
mp.msg.Insert.WHERE = "{#Me} can't put something inside itself."
mp.msg.Insert.ALREADY = "But {#thefirst} {#is/#first} already there."

mp.msg.PutOn.NOTSUPPORTER = "Putting things on {#thesecond} would achieve nothing."
mp.msg.PutOn.PUTON = "{#Me} {#present/#me,put} {#thefirst} on {#thesecond}."
mp.msg.PutOn.WHERE = "{#Me} can't put something on top of itself."

mp.msg.Drop.DROP = "{#Thefirst} {#is/#first} dropped."

mp.msg.ThrowAt.NOTLIFE = "Futile."
mp.msg.ThrowAt.THROW = "You lack the nerve when it comes to the crucial moment."

mp.msg.Wear.NOTCLOTHES = "{#Me} can't wear {#thefirst}."
mp.msg.Wear.WORN = "{#Me} {#is/#me} already wearing {#thefirst}."
mp.msg.Wear.WEAR = "{#Me} {#present/#me,put} on {#thefirst}."

mp.msg.Disrobe.NOTWORN = "{#Me} {#is/#me} not wearing {#thefirst}."
mp.msg.Disrobe.DISROBE = "{#Me} {#present/#me,take} off {#thefirst}."

mp.msg.SwitchOn.NONSWITCHABLE = "{#Thats/#first} not something {#me} can switch."
mp.msg.SwitchOn.ALREADY = "{#Thefirst} {#is/#first} already on"
mp.msg.SwitchOn.SWITCHON = "{#Me} {#present/#me,switch} on {#thefirst}."

mp.msg.SwitchOff.NONSWITCHABLE = "{#Thats/#first} not something {#me} can switch."
mp.msg.SwitchOff.ALREADY = "{#Thefirst} {#is/#first} already off"
mp.msg.SwitchOff.SWITCHOFF = "{#Me} {#present/#me,switch} off {#thefirst}."

mp.msg.Eat.NOTEDIBLE = "{#Thefirst} {#is/#first} plainly inedible."
mp.msg.Eat.EAT = "{#Me} {#present/#me,eat} {#thefirst}. Not bad."

mp.msg.Taste.TASTE = "You taste nothing unexpected.";

mp.msg.Drink.IMPOSSIBLE = "There's nothing suitable to drink here.";

mp.msg.Push.STATIC = "{#Thefirst} {#is/#first} fixed in place."
mp.msg.Push.SCENERY = "{#Me} {#is/#first} unable to."
mp.msg.Push.PUSH = "Nothing obvious happens."

mp.msg.Pull.STATIC = "{#Thefirst} {#is/#first} fixed in place."
mp.msg.Pull.SCENERY = "{#Me} {#is/#first} unable to."
mp.msg.Pull.PULL = "Nothing obvious happens."

mp.msg.Turn.STATIC = "{#Thefirst} {#is/#first} fixed in place."
mp.msg.Turn.SCENERY = "{#Me} {#is/#first} unable to."
mp.msg.Turn.TURN = "Nothing obvious happens."

mp.msg.Wait.WAIT = "Time passes."

mp.msg.Touch.LIVE = "Keep your hands to yourself!"
mp.msg.Touch.TOUCH = "You feel nothing unexpected."
mp.msg.Touch.MYSELF = "{#Me} {#is/#me} here."

mp.msg.Rub.RUB = "{#Me} {#present/#me,achieve} nothing by this."
mp.msg.Sing.SING = "{#His/#me} singing is abominable.";

mp.msg.Give.MYSELF = "{#Me} already {#have/#me} {#firstit}."
mp.msg.Give.GIVE = "{#Thesecond} {#doesnt/#second} seem interested."

mp.msg.Show.SHOW = "{#Thesecond} {#is/#second} unimpressed."

mp.msg.Burn.BURN = "This dangerous act would achieve little."
mp.msg.Burn.BURN2 = "This dangerous act would achieve little."

mp.msg.Wake.WAKE = "The dreadful truth is, this is not a dream."

mp.msg.WakeOther.WAKE = "That seems unnecessary."
mp.msg.WakeOther.NOTLIVE = "{#Thefirst} {#is/#first} not sleeping."

mp.msg.PushDir.PUSH = "Is that the best {#me} can think of?"

mp.msg.Kiss.NOTLIVE = "Keep your mind on the game."
mp.msg.Kiss.KISS = "{#Firstit} would not like it."
mp.msg.Kiss.MYSELF = "Impossible."

mp.msg.Think.THINK = "What a good idea."

mp.msg.Smell.SMELL = "{#Me} {#present/#me,smell} nothing unexpected."
mp.msg.Smell.SMELL2 = "{#present/#first,Smell} as {#anoun/#first}."

mp.msg.Listen.LISTEN = "{#Me} {#present/#me,hear} nothing unexpected."
mp.msg.Listen.LISTEN2 = "{#Me} {#present/#me,hears} {#thefirst}. Nothing unexpected."

mp.msg.Dig.DIG = "Digging would achieve nothing here."
mp.msg.Dig.DIG2 = "Digging {#thefirst} would achieve nothing."
mp.msg.Dig.DIG3 = "Digging {#thefirst} with {#thesecond} would achieve nothing."

mp.msg.Cut.CUT = "Cutting {#that/#first} up would achieve little."
mp.msg.Cut.CUT2 = "Cutting {#that/#first} up with {#thesecond} would achieve little."

mp.msg.Tear.TEAR = "Tearing {#firstit} would achieve nothing."

mp.msg.Tie.TIE = "{#Me} would achieve nothing by this."
mp.msg.Tie.TIE2 = "{#Me} would achieve nothing by this."

mp.msg.Blow.BLOW = "{#Me} can't usefully blow {#that}."

mp.msg.Attack.LIFE = "Violence isn't the answer to {#thefirst}."
mp.msg.Attack.ATTACK = "Violence isn't the answer."

mp.msg.Sleep.SLEEP =  "{#Me} {#is/#me} not feeling especially drowsy."

mp.msg.Swim.SWIM = "There's not enough water to swim in."

mp.msg.Fill.FILL = "It's useless to fill {#thefirst}."

mp.msg.Jump.JUMP = "{#Me} {#present/#me,jump} on the spot, fruitlessly."

mp.msg.JumpOver.JUMPOVER = "{#Me} would achieve nothing by jumping over {#thefirst}."

mp.msg.Consult.CONSULT = "{#Me} {#present/#me,discover} nothing of interest."

mp.msg.WaveHands.WAVE = "{#Me} {#present/#me,wave}, feeling foolish."

mp.msg.Wave.WAVE = "{#Me} {#present/#me,wave} to {#thefirst}, feeling foolish."

mp.msg.Talk.SELF = "No dialog happens."
mp.msg.Talk.NOTLIVE = "{#Thefirst} can't speak."
mp.msg.Talk.LIVE = "No reaction from {#thefirst}."

mp.msg.Tell.SELF = "No dialog happens."

mp.msg.Tell.NOTLIVE = "Silence."
mp.msg.Tell.LIVE = "No reaction from {#thefirst}."
mp.msg.Tell.EMPTY = "{#Me} can't find words to tell."

mp.msg.Ask.NOTLIVE = "No answer."
mp.msg.Ask.LIVE = "{#Firstit} {#doesnt/#first} answer."
mp.msg.Ask.EMPTY = "{#Me} can't find anything to ask."
mp.msg.Ask.SELF = "Good question."

mp.msg.Answer.NOTLIVE = "No reaction."
mp.msg.Answer.LIVE = "{#Firstit} {#doesnt/#first} say anything."
mp.msg.Answer.EMPTY = "{#Me} can't find anything to answer."
mp.msg.Answer.SELF = "Good answer."

mp.msg.Yes.YES = "That was a rhetorical question."
mp.msg.Buy.BUY = "Nothing is on sale."

mp.hint.live = 'live'
mp.hint.nonlive = 'nonlive'
mp.hint.neuter = 'neutwe'
mp.hint.male = 'male'
mp.hint.female = 'female'
mp.hint.plural = 'plural'
mp.hint.proper = 'proper'
mp.hint.surname = 'surname'
mp.hint.first = 'first'
mp.hint.second = 'second'
mp.hint.third = 'third'

mp.keyboard_space = '<space>'
mp.keyboard_backspace = '<backspace>'

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
	if w == std.me() then
		if w:hint'first' then
			return "me"
		elseif w:hint'second' then
			return "you"
		end
	end
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
	if t == 'he' then
		w[2] = 'him'
	elseif t == 'she' then
		w[2] = 'her'
	elseif t == 'they' then
		w[2] = 'them'
	end
	return w
end

mp.keyboard = {
	'A','B','C','D','E','F','G','H','I','J','K',
	'L','M','N','O','P','Q','R','S','T','U','V',
	'W','X','Y','Z'
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
	if noun == '*' then return "{$fmt em|<word>}" end
	return "{$fmt em|noun}"
end

function mp:before_Enter(w)
	if mp:compass_dir(w) then
		mp:xaction("Walk", w)
		return
	end
	return false
end

function mp:MetaHelp()

	pn("{$fmt b|INSTRUCTIONS}")

	pn([[Enter your actions in verb noun form. For example:^
> open door^
> unlock door with key^
> go north^
> take cap^
^
To examine a thing, enter "exam book" or just "book".^
^
To examine whole scene, enter "exam" or press "Enter".^
^
To exam your inventory, enter "inv".^
^
Use compass directions to walk. For example: "go north" or "north" or just "n".
^^
You may use the "TAB" key for autocompletion.
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
	"go,walk,run,enter",
	"{compass1} : Walk",
	"in|into|inside {noun}/scene,enterable : Enter",
	"{noun}/scene : Walk",
	"{compass2}: Walk",
	"outside|out|away: Exit" }

Verb { "#Exit",
	"exit,out",
	"?from {noun}/scene : Exit",
	": Exit"}

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
	"search,investigate",
	"{noun} : Search",
	"in|into|inside|on|through {noun} : Search",
	"under {noun} : LookUnder",
}

Verb { "#Open",
	"open,unlock",
	"{noun} : Open",
	"{noun} with {noun}/held : Unlock"
}

Verb { "#Close",
	"close,lock",
	"{noun} : Close",
	"{noun} with {noun}/held : Lock",
}

Verb { "#Inv",
	"inv/entory",
	"Inv" }

Verb { "#Take",
	"take,get,pick,hold,carry,peel",
	"{noun}/scene : Take",
	"{noun}/scene from {noun}/inside,holder : Remove",
	"off {noun}/worn : Disrobe",
}

Verb { "#Drop",
	"drop,discard,throw",
	"{noun}/held : Drop",
	"{noun}/held in|into|down {noun}/inside : Insert",
	"{noun}/held on|onto {noun} : PutOn",
}

Verb { "#Put",
	"~put",
	"~ {noun}/held : Drop",
	"~ {noun}/held in|into|inside {noun}/inside : Insert",
	"~ {noun}/held on|onto {noun} : PutOn",
	"~ on {noun}/held : Wear",
	"~ down {noun}/held : Drop",
	"~ {noun}/held down: Drop",
}

Verb {
	"#ThrowAt",
	"throw",
	"~ {noun}/held : Drop",
	"~ {noun}/held in|into|down {noun}/inside : Insert",
	"~ {noun}/held on|onto {noun} : PutOn",
	"{noun}/held at|against|on|onto {noun} : ThrowAt",
}

Verb {
	"#Wear",
	"wear,don",
	"{noun}/held : Wear",
}

Verb {
	"#Disrobe",
	"disrobe,shed,doff",
	"{noun}/worn : Disrobe",
}

Verb {
	"#Remove",
	"~ {noun}/held : Disrobe",
	"{noun} from {noun} : Remove",
	"~ {noun}/scene : Take",
}

Verb {
	"#SwitchOn",
	"switch",
	"on {noun}: SwitchOn",
	"~ {noun} : SwitchOn",
	"~ {noun} on : SwitchOn",
}

Verb {
	"#SwitchOff",
	"off {noun}: SwitchOff",
	"~ {noun} off : SwitchOff",
}

Verb {
	"#Eat",
	"eat",
	"{noun}/held : Eat",
}

Verb {
	"#Taste",
	"taste,lick",
	"{noun} : Taste"
}

Verb {
	"#Drink",
	"drink,sip,swallow",
	"{noun}/held : Drink",
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
		"~_word",
		"* : MetaWord"
	}
	MetaVerb {
		"#MetaNoun",
		"~_noun",
		"* : MetaNoun"
	}
	MetaVerb {
		"#MetaTrace",
		"~_trace",
		"да : MetaTraceOn",
		"нет : MetaTraceOff",
	}
	MetaVerb {
		"#MetaDump",
		"~_dump",
		"MetaDump"
	}
end
MetaVerb {
	"#MetaTranscript",
	"~transcript",
	"да : MetaTranscriptOn",
	"нет : MetaTranscriptOff",
	"MetaTranscript",
}

MetaVerb {
	"#MetaSave",
	"~save",
	"MetaSave"
}
MetaVerb {
	"#MetaLoad",
	"~load",
	"MetaLoad"
}

if DEBUG then
MetaVerb {
	"#MetaAutoplay",
	"~autoplay",
	"MetaAutoplay"
}
end

mp.msg.MetaRestart.RESTART = "Начать заново?";

MetaVerb {
	"#MetaRestart",
	"~restart",
	"MetaRestart"
}
MetaVerb {
	"#MetaHelp",
	"~help,instructions",
	"MetaHelp",
}
end, 1)

std.mod_start(function()
	if mp.undo > 0 then
		mp.msg.MetaUndo.EMPTY = "Nothing to undo."
		MetaVerb {
			"#MetaUndo",
			"~undo",
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
