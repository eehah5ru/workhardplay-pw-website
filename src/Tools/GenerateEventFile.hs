{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import W7W.MultiLang
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Site.Schedule.ProjectFile.Parser
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.EventFile

import qualified Site.Schedule.EventFile as EF

import Rainbow

import Site.Schedule.Types

import Tools.Utils

printEventFile :: Locale -> PF.ProjectFile -> IO ()
printEventFile l pf =
  case fromProjectFile l pf of
    Just eventF -> do
      TIO.putStrLn (EF.toText eventF)
      exitWith ExitSuccess
    Nothing -> e'
  where
    e' = do
      logError "error generating event file"
      (exitWith $ ExitFailure 1)



main :: IO ()
main = do
  locale <- parseOneArg
  withParsedFileInput parseProjectFile $ printEventFile locale
