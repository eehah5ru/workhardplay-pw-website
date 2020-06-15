{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.FieldParser where

import Prelude hiding (takeWhile, unlines)

import Data.Text hiding (takeWhile, count, empty)
import Data.Char (isSpace)

import Data.Attoparsec.Text
import qualified Data.Attoparsec.Text as A
import Control.Applicative

import Site.Schedule.Types
import Site.Schedule.Parser

parseAuthorRu :: Parser TextField
parseAuthorRu = section "Имя:"

parseAuthorEn :: Parser TextField
parseAuthorEn = section "Name:"

parseAuthor :: Parser Author
parseAuthor = do
  ruA <- section "Имя:"
  enA <- section "Name:"
  return $ Author ruA enA

parseTitle :: Parser Title
parseTitle = do
  ruT <- section "Название:"
  enT <- section "Title:"
  return $ Title ruT enT

parseFormat :: Parser Format
parseFormat = do
  ruF <- ((section "Формат (например: лекция, онлайн-перформанс, двигательная практика и т.д.):") <|> (section "Формат:"))
  enF <- ((section "Format (for example: lecture, online-performance, moving practice, etc.)") <|> (section "Format:"))
  return $ Format ruF enF

parseDescription :: Parser Description
parseDescription = do
  ruD <- section "Описание для программы (макс. 200 слов):"
  enD <- section "Description for program (max. 200 words):"
  return $ Description ruD enD

parsePlaceTime :: Parser PlaceTime
parsePlaceTime = do
  ruP <- section "Место и время проведения (если это релевантно):"
  enP <- section "Place and time (if it is relevant)"
  return $ PlaceTime ruP enP

parseDuration :: Parser Duration
parseDuration = do
  ruD <- section "Продолжительность:" <|> section "Длительность исполнения (если это релевантно):"
  enD <- section "Duration:" <|> section "Duration of implementation (if relevant):"
  return $ Duration ruD enD

parseBio :: Parser Bio
parseBio = do
  ruB <- section "Краткая информация о себе:"
  enB <- section "Short Bio:"
  return $ Bio ruB enB

parseImageCaption :: Parser ImageCaption
parseImageCaption = do
  ruB <- section "Подпись к картинке:"
  enB <- section "Caption to this image:"
  return $ ImageCaption ruB enB

parseTechrider :: Parser Techrider
parseTechrider = do
  ruT <- section "Техрайдер (Какая техника / материалы / инструменты вам понадобятся?):" <|> section "Есть ли еще что-то, что вы бы хотели сообщить рабочей группе РБОБ?"
  enT <- section "Tech rider (Which equipment / materials / tools would you need?)" <|> section "Is there anything else you would like to tell the WHPH working group?"
  return $ Techrider ruT enT

parseInstruction :: Parser Instruction
parseInstruction = do
  ruI <- section "Инструкция/партитура/сценарий/упражнение/алгоритм:"
  enI <- section "Instruction/score/scenario/exercise/algorithm:"
  return $ Instruction ruI enI

parseParticipantNeeds :: Parser ParticipantNeeds
parseParticipantNeeds = do
  ruPN <- section "Что необходимо исполнитель_ницам для воплощения?"
  enPN <- section "What is necessary to performers for its realization?"
  return $ ParticipantNeeds ruPN enPN
