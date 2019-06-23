{-# LANGUAGE OverloadedStrings #-}

import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Site.Schedule.ProjectFile as PF
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.EventFile

import Rainbow

import Tools.Utils

printEventFile :: PF.ProjectFile -> IO ()
printEventFile pf =
  case fromProjectFile pf of
    Just eventF -> TIO.putStrLn (toText eventF)
    Nothing -> e'
  where
    e' = do
      logError "error generating event file"
      (exitWith $ ExitFailure 1)


main :: IO ()
main = do
  withProjectFileInput printEventFile
