{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
module Tools.Report where

import Control.Monad (when, unless)

import Rainbow

import Data.Attoparsec.Text
import Data.Text hiding (takeWhile, count)
import qualified Data.Text.IO as TIO
import qualified Data.Text as T
import Site.Schedule.ProjectFile.Parser

import Site.Schedule.Types

import qualified Site.Schedule.Types as Labeled

import qualified Site.Schedule.Types as Multilang

import Tools.Utils

import qualified W7W.MultiLang as ML
--
--
-- FIXME: deprecated?
--
--
class Report a where
  label :: a -> String
  hasRu :: a -> Bool
  hasEn :: a -> Bool

printHeader :: (HasAuthor a, HasTitle a) => a -> IO ()
printHeader x = do
  putChunk $ chunk (textOrMissing (getAuthor x) (ML.en)) & fore cyan
  putStr " - "
  putChunk $ chunk (textOrMissing (getTitle x) (ML.en)) & fore yellow
  putStr "\n"


report :: (ML.Multilang a, Labeled a, ToTextField (ML.MultilangValue a)) => a -> IO ()
report x = do
  putStr $ Labeled.label x ++ ": "

  when ((Multilang.hasRu x) && (Multilang.hasEn x)) (printOk "Both")
  unless (Multilang.hasRu x) (printNo "RU")
  unless (Multilang.hasEn x) (printNo "EN")
  putStr "\n"

  where
    printNo t = putChunk $ chunk ("No " ++ t ++ "\t") & fore red

    printOk t = putChunk $ chunk ("OK " ++ t ++ "\t") & fore green
