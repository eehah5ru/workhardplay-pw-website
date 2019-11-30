{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.EventFile where

import qualified Data.Text as T

import qualified W7W.MultiLang as ML

import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.Utils


data EventFile =
  EventFile { time :: Maybe T.Text
            , title :: T.Text
            , shortDescription :: T.Text
            , participantId :: T.Text
            , description :: T.Text} deriving (Show, Eq)

fromProjectFile :: ML.Locale -> PF.ProjectFile -> Maybe EventFile
fromProjectFile l pf = do
  aTime <- return $ Nothing
  aTitle <- return $ PF.textOrMissing (PF.title pf) (translate l)
  shortDescr <- return $ PF.textOrMissing (PF.format pf) (translate l)
  partId <- PF.participantId pf
  descr <- return $ PF.textOrMissing (PF.description pf) (translate l)
  return $ EventFile aTime aTitle shortDescr partId descr
  where
    translate :: (PF.Multilang a) => ML.Locale -> a -> PF.TextField
    translate l x = ML.chooseByLocale (PF.ru x) (PF.en x) l


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
    quote t = "\"" `T.append` t `T.append` "\""
    timeField e = "time: " `T.append` (quote . escapeForYaml $ (time' e))
      where
        time' = maybe "!!!!" id . time

    titleField e = "title: " `T.append` (quote . escapeForYaml $ (title e))

    shortdescrField e = "shortDescription: " `T.append` (quote . escapeForYaml $ (shortDescription e))

    partIdField e = "participantId: " `T.append` (participantId  e)
