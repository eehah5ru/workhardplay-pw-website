{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ProjectFile.Parser where

import Prelude hiding (takeWhile, unlines)

import Data.Text hiding (takeWhile, count, empty)
import Data.Char (isSpace)

import Data.Attoparsec.Text
import qualified Data.Attoparsec.Text as A
import Control.Applicative

import Site.Schedule.ProjectFile
import Site.Schedule.Types
import Site.Schedule.Parser
import Site.Schedule.FieldParser



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
  imageCaption <- parseImageCaption <|> return NoImageCaption
  emptySpace
  techrider <- parseTechrider <|> return NoTechrider
  return $ ProjectFile author
                       title
                       format
                       descr
                       placeTime
                       dur
                       bio
                       imageCaption
                       techrider

-- parse everything or die
parseProjectFileStrict :: Parser ProjectFile
parseProjectFileStrict = do
  try emptySpace
  author <- parseAuthor
  emptySpace
  title <- parseTitle
  emptySpace
  format <- parseFormat
  emptySpace
  descr <- parseDescription
  emptySpace
  placeTime <- parsePlaceTime
  emptySpace
  dur <- parseDuration
  emptySpace
  bio <- parseBio
  emptySpace
  imageCaption <- parseImageCaption
  emptySpace
  techrider <- parseTechrider
  return $ ProjectFile author
                       title
                       format
                       descr
                       placeTime
                       dur
                       bio
                       imageCaption
                       techrider
