{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.Parser where

import Prelude hiding (takeWhile, unlines)

import Data.Text hiding (takeWhile, count, empty)
import Data.Char (isSpace)

import Data.Attoparsec.Text
import qualified Data.Attoparsec.Text as A
import Control.Applicative

import Site.Schedule.Types

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
      endOfLine'
      skipMany endOfLine'
    atTheEnd = do
      skipMany endOfLine'
      endOfInput

section :: Text -> Parser TextField
section t = do
  try section' <|> fail ("unable to parse section \"" ++ (unpack t) ++ "\"")

  where
    section' = do
      fieldSectionName t
      return . Just . pack =<< manyTill anyChar sectionDelimiter
