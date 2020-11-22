local ex = require "extlib"

function ex.shortcut.vo(hint)
	return "в ".. hint
end

std.player.word = -"ты/мр,2л"

--"помещать"
ex.msg.INSERT = "{#Me} {#word/помещать,нст,#me} {#first/вн} в {#second/вн}."

--"класть"
ex.msg.PUTON = "{#Me} {#word/класть,нст,#me} {#first/вн} на {#second/вн}."

--"закрыт"
ex.msg.PUTCLOSED = "Но {#second} {#word/закрыт,#second}."

--"открывать"
ex.msg.OPEN = "{#Me} {#word/открывать,нст,#me} {#first/вн}."

--"закрывать"
ex.msg.CLOSE = "{#Me} {#word/закрывать,нст,#me} {#first/вн}."

--"видеть"
ex.msg.EXAM = "{#Me} не {#word/видеть,#me,нст} {#vo/{#first/пр}} ничего необычного.";

--"брать"
ex.msg.TAKE = "{#Me} {#word/брать,#me,нст} {#first/вн}."

ex.msg.IS = "находится"
ex.msg.ARE = "находятся"
ex.msg.HERE = "здесь"
ex.msg.IN = "В {#first/пр,2}"
ex.msg.ON = "На {#first/пр,2}"
ex.msg.AND = "и"
--"открыт"
ex.msg.IS_OPENED = "{#word/открыт,нст,#first}"
--"закрыт"
ex.msg.IS_CLOSED = "{#word/закрыт,нст,#first}"

--"включать"
ex.msg.SWITCHON = "{#Me} {#word/включать,#me,нст} {#first/вн}."
--"выключать"
ex.msg.SWITCHOFF = "{#Me} {#word/выключать,#me,нст} {#first/вн}."
