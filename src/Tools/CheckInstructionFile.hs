{-# LANGUAGE OverloadedStrings #-}
-- module Tools.CheckProjectFile where

import Control.Monad (when, unless)

import Rainbow

import Data.Attoparsec.Text
import Data.Text hiding (takeWhile, count)
import qualified Data.Text.IO as TIO
import qualified Data.Text as T
import Site.Schedule.ProjectFile.Parser

import Site.Schedule.Types

import qualified Site.Schedule.Types as Labeled

import qualified Site.Schedule.Types as Multilang

import Site.Schedule.InstructionFile
import qualified Site.Schedule.InstructionFile.Parser as Parser



import Tools.Utils
import Tools.Report

printReport :: InstructionFile -> IO ()
printReport pf = do
  printHeader pf

  report $ author pf
  report $ title pf
  report $ instruction pf
  report $ duration pf
  report $ participantNeeds pf
  report $ placeTime pf
  report $ bio pf
  report $ imageCaption pf
  putStr "\n\n"



main :: IO ()
main = do
  withParsedFileInput Parser.parseInstructionFile printReport
