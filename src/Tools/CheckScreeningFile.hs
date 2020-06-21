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

import Site.Schedule.ScreeningFile
import Site.Schedule.ScreeningFile.Parser as Parser
import qualified Site.Schedule.ScreeningFile as PF


import Tools.Utils
import Tools.Report

printScreeingReport :: ScreeningFile -> IO ()
printScreeingReport pf = do
  printHeader pf

  report $ author pf
  report $ title pf
  report $ format pf
  report $ description pf
  report $ placeTime pf
  report $ bio pf
  report $ techrider pf
  putStr "\n\n"



main :: IO ()
main = do
  withParsedFileInput Parser.parseScreeningFile printScreeingReport
