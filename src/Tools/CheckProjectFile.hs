{-# LANGUAGE OverloadedStrings #-}
-- module Tools.CheckProjectFile where

import Control.Monad (when, unless)

import Rainbow

import Data.Attoparsec.Text
import Data.Text hiding (takeWhile, count)
import qualified Data.Text.IO as TIO
import qualified Data.Text as T
import Site.Schedule.ProjectFile.Parser

import Site.Schedule.ProjectFile
import qualified Site.Schedule.ProjectFile as PF

import Tools.Utils

class Report a where
  label :: a -> String
  hasRu :: a -> Bool
  hasEn :: a -> Bool

instance Report Author where
  label x = "Author"

  hasRu NoAuthor = False
  hasRu (Author Nothing _) = False
  hasRu _ = True

  hasEn NoAuthor = False
  hasEn (Author _ Nothing) = False
  hasEn _ = True

instance Report Title where
  label _ = "Title"

  hasRu NoTitle = False
  hasRu (Title Nothing _) = False
  hasRu _ = True

  hasEn NoTitle = False
  hasEn (Title _ Nothing) = False
  hasEn _ = True





printProjectReport :: ProjectFile -> IO ()
printProjectReport pf = do
  putChunk $ chunk (textOrMissing (author pf) en) & fore cyan
  putStr " - "
  putChunk $ chunk (textOrMissing (title pf) en) & fore yellow
  putStr "\n"

  report $ author pf
  report $ title pf
  report $ format pf
  report $ description pf
  report $ placeTime pf
  report $ bio pf
  report $ techrider pf
  putStr "\n\n"
  where
    report :: (Multilang a, Labeled a) => a -> IO ()
    report x = do
      putStr $ PF.label x ++ ": "

      when ((PF.hasRu x) && (PF.hasEn x)) (printOk "Both")
      unless (PF.hasRu x) (printNo "RU")
      unless (PF.hasEn x) (printNo "EN")
      putStr "\n"
    printNo t = putChunk $ chunk ("No " ++ t ++ "\t") & fore red
    printOk t = putChunk $ chunk ("OK " ++ t ++ "\t") & fore green



main :: IO ()
main = do
  withProjectFileInput printProjectReport
