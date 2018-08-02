# Парсер в 2018 году: Другой Марс

Привет всем! И снова, превозмогая лень и комплексы интроверта, выхожу
к людям и пишу о своей новой игре. И раз вы это читаете, то усилия не
пропали зря. :)

## Что такое парсер

После выпуска прошлой игры ["Вахта"](https://gamin.me/posts/19471) я получил довольно много (учитывая
нишевость жанра) отзывов. В том числе -- очень тёплых. Спасибо! Это
дало заряд на новое творчество, и весь отпуск я писал движок для
парсерных игр. В этой статье я хотел представить то, что у меня
получилось, и вообще написать как я дошёл до жизни такой.

Я уже писал, что мне не нравится формат мейнстрима текстовых игр, где
доминируют CYOA игры. Поэтому я постоянно искал способ сделать
игровой процесс более глубоким, при этом не превращая его в
кликодром. В "Вахте" было применено (спорное) решение -- сделать все
ссылки невидимыми, но компенсировать это тем, что _все_ слова в
игровом тексте -- кликабельны. Многим это понравилось, многим нет, а
многим было всё-равно, но я остался доволен результатом. Но все-таки и
в "Вахте" можно просто лихорадочно кликать на слова в тексте, а потом
смотреть -- что из этого вышло...

Существует формат текстовых игр, который для меня кажется идеалом --
это парсерные игры. Возможно, кто-то из вас даже не знает, что это
такое. Парсерная игра, это такая игра, где все действия игрока
вводятся с клавиатуры. Это очень древняя штука, да. Про нее помнит
только горстка маргинальных игроков (особенно, если рассматривать
территорию exUSSR). Но это и есть те самые _настоящие_ текстовые
приключения. Когда у тебя перед глазами фрагмент текста и строка
ввода, тебе приходится читать и думать. Ведь действие (ввод текста) --
это дорогая операция. Это тебе не ткнуть пальцем в кнопку на экране
гаджета. В общем, я всегда был очарован парсерными играми.

## Новый движок -- зачем?

Так вот, существуют две основные системы разработки таких игр: TADS и
Inform6 (7 для русских игр не подходит). Но как и авторы Cypher, я
написал свой движок. Зачем?

1) Я хотел сделать игру, которая выглядит как игра, с кое-каким
графическим и звуковым оформлением.

2) Я хотел движок, в котором мне не придётся возиться с словоформами.

3) Я хотел движок, который был бы более дружественным к неопытным
игрокам и имел более низкий порог вхождения.

4) Я уже написал свой движок для текстографических игр (INSTEAD) и
хотел расширить его функции. ;)

На самом деле, я занимался парсером еще в 2015 году. Правда там была
гибридная система ссылок и ввода текста. На том движке было выпущено
несколько игр (не только моих). Одна из них --
["Материк"](https://store.steampowered.com/app/366800/Mainland/) от
Василия Воронкова -- была неплохо встречена на Стиме. Но главное, у меня уже
был словарь и система склонений. В общем, за полтора месяца новый
движок, с учётом старого опыта, удалось сделать. В качестве
стандартной библиотеки я взял код библиотеки [RInform 6](https://rinform.org/) и просто
перенёс его на свой движок.

Мой движок оформлен в виде модуля [INSTEAD3](http://instead.syscall.ru) и доступен в составе пакета
модулей. Если кому интересно, то вот [документация](https://github.com/instead-hub/stead3-modules/blob/master/metaparser/manual.md).

## Парсер в 2018? Серьёзно?

Я отдаю себе отчёт в том, что выпускать игры с парсерным
вводом в 2018 году -- выглядит безумием. Особенно, если ты озабочен
финансовой стороной вопроса. В моём случае это не играет никакой роли,
что даёт мне определённое приемущество в оправдании своего творчества.

Я понимаю, что мир меняется и сегодня большинство приключенческих игр
не встретит отклика у современных игроков. Например, в старых
текстовых играх частенько учитывался вес предметов или имелось
ограничение на число носимых предметов. В наши дни это обычно выглядит
как анахронизм, примерно как если бы сегодня была выпущена аркада на
полтора часа геймплея, но без точек сохранения. Большинство людей
такого не поймёт.

Но главный скепсис вызывает, конечно, сама необходимость ввода с
клавиатуры. Здесь я попробовал упростить жизнь игрокам следующим
образом:

1) Если игра запускается на мобильном устройстве, то она включает
особый режим, когда игру можно пройти нажимая на ссылки с глаголами и
предметами сцены. При этом игра разворачивается в портретный режим.

2) Парсер использует функции нечёткого сравнения строк ([расстояние
Левенштейна](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D1%81%D1%81%D1%82%D0%BE%D1%8F%D0%BD%D0%B8%D0%B5_%D0%9B%D0%B5%D0%B2%D0%B5%D0%BD%D1%88%D1%82%D0%B5%D0%B9%D0%BD%D0%B0))
и подсказывает игроку возможные варианты ввода.

3) Автор игры, при желании, может включить режим авто-подсказок. Когда
все возможные варианты ввода появляются в виде "облака" под строкой
ввода.

А что в плане сюжетов? В 2018-ом году публику сложно удивить игрой про
поиск кладов в подземелье с педантичным учётом очков и внезапными
смертями (а именно такой была первая текстовая игра: Adventure).

В общем, я решил сделать упор на:

1) Простоту (Сверхцель: игрок, который _никогда_ не играл в парсер, должен пройти
мою игру!).

2) Рассказ или повесть. (Игра должна восприниматься не как адвенчура,
а как интерактивная повесть).

3) Оформление. (Просто, но со вкусом)

4) Небольшой размер. (Для первой игры я выбрал формат рассказа на
40-50 минут. Во первых -- как проба сил и движка. Во вторых --
современному игроку легче пройти короткую игру, чем длиную).

## Сюжет

С сюжетом получилось интересно. В отпуске я начал читать полное
собрание рассказов Р. Шекли и получил из него просто тонну
идей. Решено было писать игру по одному из рассказов.

Но когда я начал это делать, то постепенно сюжет видоизменился до
такой степени, что от Р. Шекли почти ничего не осталось. А в мотивы
игры были вплетены идеи из ещё одного рассказа. Сюжет, не смотря на
некоторую бредовость, мне понравился и дальше оставалось только
написать игру...

## Альфа версия

Писать код вообще просто, особенно, если ты -- программист. Так что
80кб кода были написаны влёт. Игра была представлена знакомым и
коллегам и вот тут началось:

> В твоей игре нельзя влезть в скафандр! А можно только одеть!

Исправлено.

> В твоей игре написано: "воспользуйтесь визором". Я пишу
> воспользоваться -- такого глагола нет!

Исправлено.

> Мне лень вводить с клавиатуры предлоги. Почему игра не понимает:
> смотреть север? Почему надо писать: смотреть на север?

Есть кнопка tab, можно написать осмотреть север.

> Почему игра не понимает: осмотреть девушка.

Надо писать грамотно.

В общем, такие (или примерно такие) репорты лились непрерывным
потоком. Благодаря им удалось многие шероховатости исправить и, я
надеюсь, улучшить игру. Но я осознал, что при написании парсера ты
всегда сталкиваешься с интересной проблемой. Широта возможностей
помноженная на широту восприятия и богатство русского
языка приводит к комбинаторному взрыву. Только уже не в коде, а в вариантах
восприятия игры.

К примеру, мне действительно пришлось внести в движок исправление. Если
игрок пытается войти или выйти в/из одежды -- то это означает надеть
или снять. И таких нюансов можно привести массу!

Если говорить об общем восприятии игры, то за первый день тестирования
я получил несколько тёплых отзывов и несколько -- критических. Нашлись
люди, которые действительно восприняли мою игру как интерактивную
повесть и с удовольствием погрузились в неё. Парсерный ввод, при этом,
не воспринимался помехой.

Критические отзывы в основном указывали на следующие недостатки:

1) Несколько мест в игре оказались неочевидными и привели к жёсткому
клинчу (люди застревали на прохождении моей игры).

2) Отсутствие свободы и рельсовость сюжета, или просто не близок сюжет (с этим я не мог ничего
поделать, так как замысел игры был именно в этом).

Пункт 1 удалось отработать. После десятка правок застревать
в моей игре перестали. :) Спасибо альфа тестерам!

## Вердикт?

Что в итоге? Сегодня я сделал сборку для Windows пользователей. Есть
веб версия -- если она у вас работает -- можно поиграть в неё. Unix
пользователи могут запустить интерпретатор INSTEAD и поиграть. Если
игровой процесс покажется вам утомительным, попробуйте нажать клавишу
"F1" и поиграть с авто-подсказками, В общем, я предлагаю вам
попробовать поиграть в парсерную игру. Я уверен, найдутся люди,
которым это придётся по душе.

Я верю, что и сегодня парсерная игра может "взлететь". Что даёт мне
основания для надежды?

1) Тёплая реакция (и живой интерес) на игру
["Материк"](https://store.steampowered.com/app/366800/Mainland/) в
Стиме, которая сделана на предыдущем поколении движка.

2) Попытка (в принципе, удачная) разработчиков игры
[Cypher](https://store.steampowered.com/app/746710/Cypher/) сделать
парсер на Unity.

3) Игра с Алисой "Фантастический квест" от Yandex -- это практически
парсерный квест с голосовым управлением.

4) Мою игру проходят люди, никогда не игравшие в парсер!

Возможно, писать парсеры в 2018 -- это действительно безумие.

Но, если честно, я так не думаю.

А вы?