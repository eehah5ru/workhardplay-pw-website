{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.EventFile where

import qualified Data.Text as T

import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.Utils


data EventFile =
  EventFile { time :: Maybe T.Text
            , title :: T.Text
            , shortDescription :: T.Text
            , participantId :: T.Text
            , description :: T.Text} deriving (Show, Eq)

fromProjectFile :: PF.ProjectFile -> Maybe EventFile
fromProjectFile pf = do
  aTime <- return $ Nothing
  aTitle <- PF.en (PF.title $ pf)
  shortDescr <- PF.en . PF.format $ pf
  partId <- PF.participantId pf
  descr <- PF.en . PF.description $ pf
  return $ EventFile aTime aTitle shortDescr partId descr

toText :: EventFile -> T.Text
toText e = T.intercalate "\n"
                         [ "---"
                         , timeField e
                         , titleField e
                         , shortdescrField e
                         , partIdField e
                         , "#projectIdSuffix: \"-one\""
                         , "---"
                         , ""
                         , description e]
  where
    quote t = "\"" `T.append` t `T.append` "\""
    timeField e = "time: " `T.append` quote (time' e)
      where
        time' = maybe "!!!!" id . time

    titleField e = "title: " `T.append` quote (title e)

    shortdescrField e = "shortDescription: " `T.append` quote (shortDescription e)

    partIdField e = "participantId: " `T.append` (participantId  e)
