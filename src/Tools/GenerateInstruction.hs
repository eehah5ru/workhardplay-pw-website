{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import W7W.MultiLang
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Site.Schedule.InstructionFile.Parser
import qualified Site.Schedule.InstructionFile as F

import Rainbow

import Site.Schedule.Types

import Tools.Utils

printInstruction :: Locale -> F.InstructionFile -> IO ()
printInstruction l i = do
  TIO.putStrLn (F.formatInstruction l i)
  exitWith ExitSuccess

main :: IO ()
main = do
  locale <- parseOneArg
  withParsedFileInput parseInstructionFile $ printInstruction locale
