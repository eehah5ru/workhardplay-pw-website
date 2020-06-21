{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule.ScreeningFile where

import Data.Maybe
import qualified Data.Text as T

import qualified W7W.MultiLang as ML

import Site.Schedule.Utils

import Site.Schedule.Types
import Site.Schedule.ToYaml


data ScreeningFile =
  ScreeningFile { author :: Author
                , title :: Title
                , format :: Format
                , description :: Description
                , placeTime :: PlaceTime
                , duration :: Duration
                , bio :: Bio
                , imageCaption :: ImageCaption
                , techrider :: Techrider }
  | EmprtyFile
  | BrokenFile deriving (Show, Eq)

instance HasAuthor ScreeningFile where
  getAuthor = author

instance HasTitle ScreeningFile where
  getTitle = title

instance HasBio ScreeningFile where
  getBio = bio


formatScreening :: ML.Locale -> ScreeningFile -> T.Text
formatScreening l x =
  T.intercalate "\n" $ map (maybe "" id) . filter isJust $
                [ Just "---"
                , Just "order: 1"
                , titleField x
                , partIdField x
                , shortDescriptionField x
                , placeTimeField x
                , durationField x
                , coverCaptionField x
                , techriderField x
                , Just "---"
                , Just ""
                , Just . fixMarkdown . translateOrMissing l . description $ x
                ]
  where
    titleField = Just . yamlField "title" . translateOrMissing l . title
    partIdField = Just . yamlField "participantId" . maybe "UNKNOWN_PARTICIPANT_ID" id . participantId
    shortDescriptionField = yamlFieldMaybe "shortDescription" (not . isNo) . translateOrMissing l . format

    placeTimeField = yamlFieldMaybe "placeAndTime" (not . isNo) . translateOrMissing l . placeTime
    durationField = yamlFieldMaybe "duration" (not . isNo) . translateOrMissing l . duration
    coverCaptionField = yamlFieldMaybe "coverCaption" (not . isNo) . translateOrMissing l . imageCaption
    techriderField = yamlFieldMaybe "techrider" (not . isNo) . translateOrMissing l . techrider
