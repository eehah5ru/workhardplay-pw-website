{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.EventFile where

import qualified Data.Text as T

import qualified W7W.MultiLang as ML

import qualified Site.Schedule.ProjectFile as PF

import Site.Schedule.Utils hiding (participantId)

import qualified Site.Schedule.Utils as SU

import Site.Schedule.Types

import qualified Site.Schedule.Types as ST
import Site.Schedule.ToYaml

data EventFile =
  EventFile { time :: Maybe T.Text
            , title :: T.Text
            , shortDescription :: T.Text
            , participantId :: T.Text
            , description :: T.Text} deriving (Show, Eq)

fromProjectFile :: ML.Locale -> PF.ProjectFile -> Maybe EventFile
fromProjectFile l pf = do
  aTime <- return $ Nothing
  aTitle <- return . translateOrMissing l . PF.title $ pf
  shortDescr <- return . translateOrMissing l . PF.format $ pf
  partId <- SU.participantId pf
  descr <- return . translateOrMissing l . PF.description $ pf
  return $ EventFile aTime aTitle shortDescr partId descr
  where


toText :: EventFile -> T.Text
toText e = T.intercalate "\n"
                         [ "---"
                         , "order: 1"
                         , timeField e
                         , titleField e
                         , shortdescrField e
                         , partIdField e
                         , "projectIdSuffix: \"-one\""
                         , "---"
                         , ""
                         , description e]
  where
    timeField = yamlField "time" . maybe "!!!!" id . time

    titleField = yamlField "title" . title

    shortdescrField = yamlField "shortDescription" . shortDescription

    partIdField = yamlField "participantId" . participantId
