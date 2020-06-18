{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.InstructionFile where

import Data.Maybe
import qualified Data.Text as T

import qualified W7W.MultiLang as ML

import Site.Schedule.Utils

import Site.Schedule.Types
import Site.Schedule.ToYaml


data InstructionFile = InstructionFile { author :: Author
                                       , title :: Title
                                       , instruction :: Instruction
                                       , duration :: Duration
                                       , participantNeeds :: ParticipantNeeds
                                       , placeTime :: PlaceTime
                                       , bio :: Bio
                                       , imageCaption :: ImageCaption }
                     | EmptyFile
                     | BrokenFile deriving (Show, Eq)

instance HasAuthor InstructionFile where
  getAuthor = author

instance HasTitle InstructionFile where
  getTitle = title

instance HasBio InstructionFile where
  getBio = bio


isNo :: T.Text -> Bool
isNo t = and . map (\f -> f (T.strip t)) $ preds
  where
    noString = "No"
    preds = [T.isPrefixOf noString, T.isSuffixOf noString]

--
--
-- format instruction to hakyll file
--
--
formatInstruction :: ML.Locale -> InstructionFile -> T.Text
formatInstruction l x =
  T.intercalate "\n" $ map (maybe "" id) . filter isJust $
                [ Just "---"
                , Just "order: 1"
                , titleField x
                , partIdField x
                , performerNeedsField x
                , placeTimeField x
                , durationField x
                , coverCaptionField x
                , Just "---"
                , Just ""
                , Just . fixMarkdown . translateOrMissing l . instruction $ x
                ]
  where
    titleField = Just . yamlField "title" . translateOrMissing l . title
    performerNeedsField = yamlFieldMaybe "performerNeeds" (not . isNo)  . translateOrMissing l . participantNeeds
    placeTimeField = yamlFieldMaybe "placeAndTime" (not . isNo) . translateOrMissing l . placeTime
    durationField = yamlFieldMaybe "duration" (not . isNo) . translateOrMissing l . duration
    coverCaptionField = yamlFieldMaybe "coverCaption" (not . isNo) . translateOrMissing l . imageCaption
    partIdField = Just . yamlField "participantId" . maybe "UNKNOWN_PARTICIPANT_ID" id . participantId
