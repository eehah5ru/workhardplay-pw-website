{-# LANGUAGE OverloadedStrings #-}

import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Site.Schedule.ProjectFile as PF
import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.ParticipantFile

import Rainbow

import Tools.Utils


printParticipantFile :: PF.ProjectFile -> IO ()
printParticipantFile pf =
  case fromProjectFile pf of
    Just partF -> TIO.putStrLn (toText partF)
    Nothing -> e'
  where
    e' = do
      logError "error generating participant file"
      (exitWith $ ExitFailure 1)


main :: IO ()
main = do
  withProjectFileInput printParticipantFile
