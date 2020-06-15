{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ParticipantFile where

import qualified Data.Text as T

import qualified W7W.MultiLang as ML

import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.Utils

import Site.Schedule.Types hiding (toText)

import qualified Site.Schedule.Types as ST
import Site.Schedule.ToYaml


data ParticipantFile =
  ParticipantFile { title :: T.Text
                  , city :: Maybe T.Text
                  , bio :: T.Text } deriving (Show, Eq)


mkParticipantFile :: (HasAuthor a, HasBio a) => ML.Locale -> a -> Maybe ParticipantFile
mkParticipantFile l pf = do
  t <- return $ translateOrMissing l . getAuthor $ pf
  c <- return $ Nothing
  b <- return $ translateOrMissing l . getBio $ pf
  return $ ParticipantFile t c b

toText :: ParticipantFile -> T.Text
toText p = T.intercalate "\n"
                         [ "---"
                         , titleField p
                         , cityField p
                         , "---"
                         , ""
                         , bio p]
  where
    titleField = yamlField "title" . title
    cityField = yamlField "city" . maybe "!!!!" id . city
