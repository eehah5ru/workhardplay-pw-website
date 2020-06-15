{-# LANGUAGE OverloadedStrings #-}

import System.Environment
import System.Exit
import System.IO
import Control.Monad (when, unless)

import qualified Data.Attoparsec.Text as A

import W7W.MultiLang

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.ProjectFile.Parser
import Site.Schedule.InstructionFile.Parser

import Site.Schedule.ParticipantFile

import Site.Schedule.Types hiding (toText)

import Rainbow

import Tools.Utils


printParticipantFile :: (HasAuthor a, HasBio a) => Locale -> a -> IO ()
printParticipantFile l pf =
  case mkParticipantFile l pf of
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
  (locale, pSource) <- parseTwoArgs

  f  locale pSource

  where
    f l FromProject = withParsedFileInput parseProjectFile (printParticipantFile l)
    f l FromInstruction = withParsedFileInput parseInstructionFile (printParticipantFile l)
