{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ProjectFile.Parser where

import Prelude hiding (takeWhile, unlines)

import Data.Text hiding (takeWhile, count, empty)
import Data.Char (isSpace)

import Data.Attoparsec.Text
import qualified Data.Attoparsec.Text as A
import Control.Applicative

import Site.Schedule.ProjectFile

endOfLine' = (string "\n") <|> (string "\r\n")

spaces = do
  --A.takeWhile isSpace
  return . pack =<< many' space

emptySpace :: Parser ()
emptySpace = do
  skipSpace
  skipWhile isEndOfLine
  skipSpace
  -- where endOfLine = inClass "\r\n"

fieldSectionName :: Text -> Parser Text
fieldSectionName t = do
  r <- string t  <* spaces
  -- skipWhile isSpace
  -- endOfLine'
  return r

sectionDelimiter :: Parser ()
sectionDelimiter = do
  inMiddle <|> atTheEnd
  where
    inMiddle = do
      endOfLine'
      endOfLine'
      endOfLine'
      skipMany endOfLine'
    atTheEnd = do
      skipMany endOfLine'
      endOfInput

section :: Text -> Parser TextField
section t = do
  try section' <|> return Nothing

  where
    section' = do
      fieldSectionName t
      return . Just . pack =<< manyTill anyChar sectionDelimiter


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
  ruF <- section "Формат (например: лекция, онлайн-перформанс, двигательная практика и т.д.):"
  enF <- section "Format (for example: lecture, online-performance, moving practice, etc.)"
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
  ruD <- section "Продолжительность:"
  enD <- section "Duration:"
  return $ Duration ruD enD

parseBio :: Parser Bio
parseBio = do
  ruB <- section "Краткая информация о себе:"
  enB <- section "Short Bio:"
  return $ Bio ruB enB

parseTechrider :: Parser Techrider
parseTechrider = do
  ruT <- section "Техрайдер (Какая техника / материалы / инструменты вам понадобятся?):"
  enT <- section "Tech rider (Which equipment / materials / tools would you need?)"
  return $ Techrider ruT enT



parseProjectFile :: Parser ProjectFile
parseProjectFile = do
  try emptySpace
  author <- parseAuthor <|> return NoAuthor
  emptySpace
  title <- parseTitle <|> return NoTitle
  emptySpace
  format <- parseFormat <|> return NoFormat
  emptySpace
  descr <- parseDescription <|> return NoDescription
  emptySpace
  placeTime <- parsePlaceTime <|> return NoPlaceTime
  emptySpace
  dur <- parseDuration <|> return NoDuration
  emptySpace
  bio <- parseBio <|> return NoBio
  emptySpace
  techrider <- parseTechrider <|> return NoTechrider
  return $ ProjectFile author
                       title
                       format
                       descr
                       placeTime
                       dur
                       bio
                       techrider
