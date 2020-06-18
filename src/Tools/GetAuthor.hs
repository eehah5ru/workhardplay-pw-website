{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified W7W.MultiLang as ML
import W7W.MultiLang

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Site.Schedule.ProjectFile.Parser
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.EventFile

import Rainbow

import Site.Schedule.Types
import Site.Schedule.Utils

import Tools.Utils

printAuthor :: ML.Locale -> PF.ProjectFile -> IO ()
printAuthor l pf = TIO.putStrLn $ textOrMissing (PF.author $ pf) (translate l)
   where
    translate :: (ML.Multilang a, ToTextField (ML.MultilangValue a)) => ML.Locale -> a -> TextField
    translate l x = ML.chooseByLocale (toTextField $ ru x) (toTextField $ en x) l



main :: IO ()
main = do
  locale <- parseLocale =<< getArgs
  withParsedFileInput parseProjectFile $ printAuthor locale

   where
    parseLocale [] = do
      logError "args are empty"
      exitWith $ ExitFailure 1

    parseLocale (l:[]) = do
      case ML.fromLang l of
        ML.UNKNOWN -> e'
        locale -> return locale
      where
        e' = do
          error $ "unknown locale: " ++ l
          exitWith $ ExitFailure 1

    parseLocale (_:_:xs) = do
      logError "too many args"
      exitWith $ ExitFailure 1
