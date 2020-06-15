{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.InstructionFile where

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
--
--
-- format instruction to hakyll file
--
--
formatInstruction :: ML.Locale -> InstructionFile -> T.Text
formatInstruction l x =
  T.intercalate "\n"
                [ "---"
                , "order: 1"
                , titleField x
                , partIdField x
                , performerNeedsField x
                , placeTimeField x
                , durationField x
                , coverCaptionField x
                , "---"
                , ""
                , translateOrMissing l (instruction x)
                ]
  where
    titleField = yamlField "title" . translateOrMissing l . title
    performerNeedsField = yamlField "performerNeeds" . translateOrMissing l . participantNeeds
    placeTimeField = yamlField "placeAndTime" . translateOrMissing l . placeTime
    durationField = yamlField "duration" . translateOrMissing l . duration
    coverCaptionField = yamlField "coverCaption" . translateOrMissing l . imageCaption
    partIdField = yamlField "participantId" . maybe "UNKNOWN_PARTICIPANT_ID" id . participantId
