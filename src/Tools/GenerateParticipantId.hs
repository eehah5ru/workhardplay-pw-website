{-# LANGUAGE OverloadedStrings #-}

import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Site.Schedule.ProjectFile.Parser
import Site.Schedule.ProjectFile
import qualified Site.Schedule.ProjectFile as PF

import Site.Schedule.Utils

import Tools.Utils

printParticipantId :: ProjectFile -> IO ()
printParticipantId pf =
  case participantId pf of
    Just pId -> TIO.putStrLn pId
    Nothing -> e'
  where
    e' = do
      logError "error generating participant id"
      (exitWith $ ExitFailure 1)


main :: IO ()
main = do
  withParsedFileInput parseProjectFile printParticipantId
