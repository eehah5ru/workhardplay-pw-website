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

testParseAuthor :: IO ()
testParseAuthor = do
  print $ parseOnly parseAuthor testAuthorData

testParseProjectFile :: IO ()
testParseProjectFile = do
  print $ parseOnly parseProjectFile testData
