{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module Site.Schedule.ProjectFile.ParserTest where
import Text.RawString.QQ
import Data.Attoparsec.Text

import qualified Data.Attoparsec.Text as A
import Data.Text hiding (takeWhile, count)
import Data.Char (isSpace)
import qualified Data.Text as T
import Site.Schedule.ProjectFile.Parser

import Site.Schedule.ProjectFile


testAuthorData = T.pack [r|Имя:
Алиса Олева\r
\r
\r
Name:\r
Alisa Oleva\r
\r
\r\n|]


testAuthorRuData = T.pack [r|Имя:
Алиса Олева


|]

testAuthorEnData = T.pack [r|Name:
Alisa Oleva


|]

testIncompleTitle = T.pack [r|Имя:
Алиса Олева


Name:
Alisa Oleva


Title:
lozhechka


Формат (например: лекция, онлайн-перформанс, двигательная практика и т.д.):
один-на-один действие


|]


testData = T.pack [r|Имя:
Алиса Олева


Name:
Alisa Oleva


Название:
ложечка


Title:       
lozhechka


Формат (например: лекция, онлайн-перформанс, двигательная практика и т.д.):
один-на-один действие


Format (for example: lecture, online-performance, moving practice, etc.)
one-to-one action


Описание для программы (макс. 200 слов):
сегодня тебе не надо будет подносить ложку ко рту, вытирать рот, дуть на горячий чай. я сделаю это за тебя. сядь поудобнее, расслабься и приятного аппетита.


Description for program (max. 200 words):
today you won’t need to put the spoon into your mouth, blow at the hot tea, clean your mouth with a napkin. i will do it all for you. seat comfortably, relax and enjoy your meal.


Место и время проведения (если это релевантно):
во время каждого приема пищи в санатории (завтрак-ужин) думаю, возможно 2 сессии за раз


Place and time (if it is relevant)
during breakfast and dinner in the sanatorium canteen


Продолжительность:
около 15 минут


Duration:
about 15 minutes


Краткая информация о себе:
Алиса Олева работает в жанре психогеографии и аудио-прогулок. Город — это ее студия, а городская среда — материал. Алиса изучает пределы личного и общественного, видимого и невидимого, городскую хореографию и археологию, следы и границы, пустоты и тишины.


Short Bio:
born 1989 in Moscow. based in London. alisa oleva holds an MA in Performance from Goldsmiths. her practice aims to offer an alternative way to experience and engage with the everyday urban life around us by shifting the sense of real and imaginary within the cityscape. she treats the city as her studio and urban life as material, to consider issues of private and public, visible and invisible, urban choreography and urban archeology, traces and surfaces, borders and inventories, voids and silences.


Техрайдер (Какая техника / материалы / инструменты вам понадобятся?):
ничего


Tech rider (Which equipment / materials / tools would you need?)
nothing
|]

testData2 = T.pack [r|Имя:
Алиса Олева


Name:
Alisa Oleva


Название:
ложечка


Title:
lozhechka
Формат (например: лекция, онлайн-перформанс, двигательная практика и т.д.):
один-на-один действие


Format (for example: lecture, online-performance, moving practice, etc.)
one-to-one action
Описание для программы (макс. 200 слов):
сегодня тебе не надо будет подносить ложку ко рту, вытирать рот, дуть на горячий чай. я сделаю это за тебя. сядь поудобнее, расслабься и приятного аппетита.
Description for program (max. 200 words):
today you won’t need to put the spoon into your mouth, blow at the hot tea, clean your mouth with a napkin. i will do it all for you. seat comfortably, relax and enjoy your meal.
Место и время проведения (если это релевантно):
во время каждого приема пищи в санатории (завтрак-ужин) думаю, возможно 2 сессии за раз
Place and time (if it is relevant)
during breakfast and dinner in the sanatorium canteen


Продолжительность:
около 15 минут


Duration:
about 15 minutes
Краткая информация о себе:
Алиса Олева работает в жанре психогеографии и аудио-прогулок. Город — это ее студия, а городская среда — материал. Алиса изучает пределы личного и общественного, видимого и невидимого, городскую хореографию и археологию, следы и границы, пустоты и тишины.


Short Bio:
born 1989 in Moscow. based in London. alisa oleva holds an MA in Performance from Goldsmiths. her practice aims to offer an alternative way to experience and engage with the everyday urban life around us by shifting the sense of real and imaginary within the cityscape. she treats the city as her studio and urban life as material, to consider issues of private and public, visible and invisible, urban choreography and urban archeology, traces and surfaces, borders and inventories, voids and silences.

     
Техрайдер (Какая техника / материалы / инструменты вам понадобятся?):
ничего


Tech rider (Which equipment / materials / tools would you need?)
nothing
|]


testData2020 = T.pack [r|
Имя:
Санна Самуэльсон 




Name:
Sanna Samuelsson




Название: 
Нет времени 




Title:
No Time 




Формат:
видео




Format:
video




Описание для программы (макс. 200 слов):


XXX




Description for program (max. 200 words):
Xxx




Место и время проведения (если это релевантно):
No




Place and time (if it is relevant):
No




Продолжительность:
‘20




Duration:
'20




Краткая информация о себе:
XXX




Short Bio:
Sanna Samuelsson is a recently examined master student at Literary Composition at Valand, Gothenburg. She is a writer who works with different mediums, mainly text and sound. She is also one of the organizers of the LGBTQ-focused reading night Lavendelläsningar in Gothenburg. 




Подпись к картинке:
XXX




Caption to this image:
XXX




Есть ли еще что-то, что вы бы хотели сообщить рабочей группе РБОБ?
No


Is there anything else you would like to tell the WHPH working group?
No
|]

testData2020WithPars = T.pack [r|Имя:
н и и ч е г о д е л а т ь




Name:
n i i c h e g o d e l a t (eng. “Research Institute for Doing Nothing”)




Название: 
АлиСтопкран




Title:
AliStopkran




Формат:
игрушечный интернет-магазин / видео-связь




Format:
unreal imaginary fictional internet shop / video conference




Описание для программы (макс. 200 слов):
“н и и ч е г о д е л а т ь для слота «хоровод неопределенности»:   


Интернет-магазин АлиСтопкран, с ускользающими объектами желания, дикими описаниями и захлопывающимся навсегда возможностями.  
Во время сессии/работы магазина будет предложены (с)лоты, один из которых будет выбран контингентным способом (бросок костей) и представлен зрителю/потребителю контента:  
Интернет-магазин AliStopkran полон неуловимых желаний, сумасшедших описаний и вечных возможностей ударов кулаком. 
Во время сессии / работы магазина будут предоставлены рекламные места, одно из которых будет выбрано временным методом (игральные кости) и представлено зрителю / потребителю контента:  


Интернет-магазин AliStopkran полон интенсивных страстей, сумасшедших описаний и, возможно, ребер verwelkomd. 
Во время операции сеанса / магазина будет предоставлено место для рекламы, одно из которых будет выбрано в предварительном формате (игральные кости) и представлено на конкурс:  


Репозиторий AliStopkran полон похоти, сумасшедших идей и, возможно, ребер verwelkomd. 
Во время курса / магазина будет предоставлено место для рекламы, одно из которых будет выбрано за короткий промежуток времени (игра в кости) и показано на joo:   


Хранилище данных AliStopkran полно страстей, шуток и, возможно, нервных шуток. 
Во время чтения / демонстрационного зала будет создано пространство, в котором оно будет выбрано в течение короткого времени (игра в кости) и отображено в зоопарке:  Слоты:  


(С)лот темпоральной синхронизации (дедлайны, аппараты регуляции коллективности). Темпоральное насилие н (работа “на дядю”) и темпоральная эмансипация (общее дело). Квир-темпоральность.  
(С)лот режимы внимания, о рассеивании и концентрации (сканер, достижение успеха, с побочным эффектом выгорания/сгорания машин мышления),  о пост внимании (телесном внимании, внимании в потоке, сёрфинг).  
(С)лот неопределенности («я просто смотрю»; неопределенность сразу после сдачи экзамена/работы и до получения результата) о среде возможностей и фрустрации, формирующей субъективность.  
(С)лот ворота бинарности. 
(С)лот упущенных желаний и ожиданий/слот упущенных возможностей. 
(С)лот суперпозиции (дало ли действие результат и является ли он результатом действия, которое могло произойти или нет, я/мы кот/кошка Шредингера/Гейзенберга). 
(C) лот "Терминатор - ни рыба, ни мясо". Слот свободы от выбора. 
(с) лот навязчивых состояний  


Дополнительные возможности среды магазина:  
Пустой/битый (с)лот 
Фейковые (с)лоты >  
(С)лот не соответствующий ожиданиям  


Во время подготовки слоты могут измениться или исчезнуть.”




Description for program (max. 200 words):
“n i i c h e g o d e l a t for slot “round dance of uncertainty”:  


AliStopcran online shop, with elusive objects of desire, wild descriptions and forever slamming opportunities. 
During the session / operation of the store, (c) lots will be offered, one of which will be selected in a contingent way (roll of dice) and presented to the viewer / consumer of the content:  


The AliStopkran online store is full of elusive desires, crazy descriptions and eternal possibilities of punching. 
During the store’s session / work, advertising spots will be provided, one of which will be selected by a temporary method (dice) and presented to the viewer / consumer of the content:  


The AliStopkran online store is full of intense passions, crazy descriptions and, possibly, verwelkomd ribs. 
During the session / store operation, a place for advertising will be provided, one of which will be selected in a preliminary format (dice) and submitted to the competition:  


AliStopkran's repository is full of lust, crazy ideas, and possibly verwelkomd ribs. 
During the course / store, a place for advertising will be provided, one of which will be selected in a short period of time (dice) and shown on joo:  


AliStopkran's data warehouse is full of passions, jokes, and possibly nervous jokes. 
During the reading / showroom, a space will be created in which it will be selected for a short time (dice) and displayed in the zoo:  


Slots: 
(s) lot of temporal synchronization (deadlines, apparatus for regulating collectivity). Temporal violence n (work “for uncle”) and temporal emancipation (common cause). Queer temporality. 
(s) lot of attention modes, about dispersion and concentration (scanner, achieving success, with the side effect of burnout / combustion of thinking machines), about post attention (bodily attention, attention in the stream, surfing). 
(s) lot of uncertainty (“I just look”; the uncertainty immediately after passing the exam / work and until the result is obtained) about the environment of opportunities and frustration that forms subjectivity. 
(s) lot  gate of binarity. 
(s) lot of missed desires and expectations / slot of missed opportunities. 
(s) lot of superposition (whether the action gave a result and whether it is the result of an action that could have occurred or not, I/we are the Schrödinger/Heisenberg cat). 
(s) lot "Terminator - neither fish nor meat". Slot of freedom from choice. 
(s) lot of obsessive conditions   


Additional features of the store environment: 
Empty / beaten (s) lot 
Fake (s) lots> 
(s) lot does not meet expectations  


During preparation, the slots may change or disappear.”




Место и время проведения (если это релевантно):
Онлайн
Две сессии по 40 минут в один день.




Place and time (if it is relevant):
Online
Two sessions of 40 minutes in one day.




Продолжительность:
20 минут




Duration:
20 minutes




Краткая информация о себе:
Мы честно признаемся себе, что наше настоящее желание - ничего не делать. Мы честно признаемся себе, что сомневаемся. И мы видим, что нас много.  
н и и ч е г о д е л а т ь - это сеть мерцающих лабораторий, исследующих возможности преодоления существующих стандартов трудового поведения. В то время как он поднимает вопросы об освобождении рабочих от отчужденного труда, а безработных - от социальной стигматизации, он занимается проблемой неоплачиваемого невидимого труда и возрождает утопическую традицию стремления к будущему миру без работы. Основная цель Научно-исследовательского института - рассматривать «бездействие» и другие его разновидности (прокрастинация, пассивность, апатия, безделье и т. Д.) Как публичное явление, требующее всестороннего изучения, как теоретического, так и практического.




Short Bio:
We honestly admit to ourselves that our present desire is to do nothing. We honestly admit to ourselves that we doubt. And we see that we are many. 
n i i c h e g o d e l a t (eng. “Research Institute for Doing Nothing”) is a network of flickering laboratories, researching opportunities for overcoming present standards of labour behaviour. n i i c h e g o d e l a t raises questions of emancipation of workers from alienated labour, and the unemployed from social stigmatization, it deals with the problem of unpaid invisible labour, and resurrects the utopian tradition of striving for the future world without work. The main goal of the Research Institute is to consider "doing nothing" and its other varieties (procrastination, passivity, apathy, idleness, etc.) as a public phenomenon requiring comprehensive study, both theoretical and practical.




Подпись к картинке:
Будь умным, живи счастливо




Caption to this image:
Be smart, live happily




Есть ли еще что-то, что вы бы хотели сообщить рабочей группе РБОБ?
No




Is there anything else you would like to tell the WHPH working group?
No
|]
  
-- testParseAuthor :: IO ()
-- testParseAuthor = do
--   print $ parseOnly parseAuthor testAuthorData

testParseProjectFile :: IO ()
testParseProjectFile = do
  print $ parseOnly parseProjectFile testData
