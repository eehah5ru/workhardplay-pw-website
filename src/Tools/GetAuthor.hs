{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified W7W.MultiLang as ML
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.EventFile

import Rainbow

import Tools.Utils

printAuthor :: ML.Locale -> PF.ProjectFile -> IO ()
printAuthor l pf = TIO.putStrLn $ PF.textOrMissing (PF.author $ pf) (translate l)
   where
    translate :: (PF.Multilang a) => ML.Locale -> a -> PF.TextField
    translate l x = ML.chooseByLocale (PF.ru x) (PF.en x) l



main :: IO ()
main = do
  locale <- parseLocale =<< getArgs
  withProjectFileInput $ printAuthor locale

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
