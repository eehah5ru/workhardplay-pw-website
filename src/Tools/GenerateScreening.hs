{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import W7W.MultiLang
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Site.Schedule.ScreeningFile.Parser
import qualified Site.Schedule.ScreeningFile as F

import Rainbow

import Site.Schedule.Types

import Tools.Utils

printScreening :: Locale -> F.ScreeningFile -> IO ()
printScreening l i = do
  TIO.putStrLn (F.formatScreening l i)
  exitWith ExitSuccess

main :: IO ()
main = do
  locale <- parseOneArg
  withParsedFileInput parseScreeningFile $ printScreening locale
