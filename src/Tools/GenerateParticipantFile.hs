{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import W7W.MultiLang

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.ParticipantFile

import Rainbow

import Tools.Utils


printParticipantFile :: Locale -> PF.ProjectFile -> IO ()
printParticipantFile l pf =
  case fromProjectFile l pf of
    Just partF -> do
      TIO.putStrLn (toText partF)
      exitWith ExitSuccess
    Nothing -> e'
  where
    e' = do
      logError "error generating participant file"
      (exitWith $ ExitFailure 1)


main :: IO ()
main = do
  locale <- parseLocale =<< getArgs
  withProjectFileInput $ printParticipantFile locale
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
