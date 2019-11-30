{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import W7W.MultiLang
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.EventFile

import Rainbow

import Tools.Utils

printEventFile :: Locale -> PF.ProjectFile -> IO ()
printEventFile l pf =
  case fromProjectFile l pf of
    Just eventF -> do
      TIO.putStrLn (toText eventF)
      exitWith ExitSuccess
    Nothing -> e'
  where
    e' = do
      logError "error generating event file"
      (exitWith $ ExitFailure 1)


main :: IO ()
main = do
  locale <- parseLocale =<< getArgs
  withProjectFileInput $ printEventFile locale

   where
    parseLocale [] = do
      logError "args are empty"
      exitWith $ ExitFailure 1

    parseLocale (l:[]) = do
      case fromLang l of
        UNKNOWN -> e'
        locale -> return locale
      where
        e' = do
          error $ "unknown locale: " ++ l
          exitWith $ ExitFailure 1

    parseLocale (_:_:xs) = do
      logError "too many args"
      exitWith $ ExitFailure 1
