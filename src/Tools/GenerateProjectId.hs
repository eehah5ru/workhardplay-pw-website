{-# LANGUAGE OverloadedStrings #-}

import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Site.Schedule.ProjectFile
import Site.Schedule.ProjectFile.Parser
import qualified Site.Schedule.ProjectFile as PF

import Rainbow

import Site.Schedule.Utils

import Tools.Utils

printProjectId :: ProjectFile -> IO ()
printProjectId pf =
  case projectId pf of
    Just pId -> TIO.putStrLn pId
    Nothing -> e'
  where
    e' = do
      logError "error generating project id"
      (exitWith $ ExitFailure 1)


main :: IO ()
main = do
  withParsedFileInput parseProjectFile printProjectId
