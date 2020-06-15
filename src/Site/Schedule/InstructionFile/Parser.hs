{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.InstructionFile.Parser where

import Prelude hiding (takeWhile, unlines)

import Data.Text hiding (takeWhile, count, empty)
import Data.Char (isSpace)

import Data.Attoparsec.Text
import qualified Data.Attoparsec.Text as A
import Control.Applicative

import Site.Schedule.InstructionFile
import Site.Schedule.Types
import Site.Schedule.Parser
import Site.Schedule.FieldParser

parseInstructionFile :: Parser InstructionFile
parseInstructionFile = do
  try emptySpace
  author <- parseAuthor <|> return NoAuthor
  emptySpace
  title <- parseTitle <|> return NoTitle
  emptySpace
  instruction <- parseInstruction <|> return NoInstruction
  emptySpace
  dur <- parseDuration <|> return NoDuration
  emptySpace
  participantNeeds <- parseParticipantNeeds <|> return NoParticipantNeeds
  emptySpace
  placeTime <- parsePlaceTime <|> return NoPlaceTime
  emptySpace
  bio <- parseBio <|> return NoBio
  emptySpace
  imageCaption <- parseImageCaption <|> return NoImageCaption
  return $ InstructionFile author title instruction dur participantNeeds placeTime bio imageCaption

parseInstructionFileStrict :: Parser InstructionFile
parseInstructionFileStrict = do
  try emptySpace
  author <- parseAuthor
  emptySpace
  title <- parseTitle
  emptySpace
  instruction <- parseInstruction
  emptySpace
  dur <- parseDuration
  emptySpace
  participantNeeds <- parseParticipantNeeds
  emptySpace
  placeTime <- parsePlaceTime
  emptySpace
  bio <- parseBio
  emptySpace
  imageCaption <- parseImageCaption
  return $ InstructionFile author title instruction dur participantNeeds placeTime bio imageCaption
