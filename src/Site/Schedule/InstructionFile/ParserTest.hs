{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module Site.Schedule.InstructionFile.ParserTest where
import Text.RawString.QQ
import Data.Attoparsec.Text

import qualified Data.Attoparsec.Text as A
import Data.Text hiding (takeWhile, count)
import Data.Char (isSpace)
import qualified Data.Text as T
import Site.Schedule.InstructionFile.Parser

import Site.Schedule.InstructionFile

testData1 = T.pack [r|Имя:
Глеб Напреенко




Name:
Gleb Napreenko




Название:
Припомнилось




Title:
Flash-back




Инструкция/партитура/сценарий/упражнение/алгоритм:
Сделайте что-то, что вы перестали делать на карантине, но что раньше более или менее регулярно делали.




Instruction/score/scenario/exercise/algorithm:
Do something that you've stopped doing during the quarantine but that you've done more or less regularly before.




Длительность исполнения (если это релевантно):
No




Duration of implementation (if relevant):
No




Что необходимо исполнитель_ницам для воплощения?
No




What is necessary to performers for its realization?
No




Место и время проведения (если это релевантно):
В комнате






Place and time (if it is relevant):
In the room




Краткая информация о себе:
Психоаналитик, искусствовед




Short Bio:
Psychoanalyst, art historian




Подпись к картинке:
Макс Эрнст. При первом ясном слове




Caption to this image:
Max Ernst. At the first clear word
|]

parseData :: Text -> IO ()
parseData t =
  print $ parseOnly parseInstructionFileStrict t
