{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ProjectFile where

import qualified Data.Text as T

import Site.Schedule.Types

import Site.Schedule.Utils


data ProjectFile = ProjectFile { author :: Author
                               , title :: Title
                               , format :: Format
                               , description :: Description
                               , placeTime :: PlaceTime
                               , duration :: Duration
                               , bio :: Bio
                               , imageCaption :: ImageCaption
                               , techrider :: Techrider }

                 | EmptyFile
                 | BrokenFile deriving (Show, Eq)


instance HasAuthor ProjectFile where
  getAuthor = author

instance HasTitle ProjectFile where
  getTitle = title

instance HasBio ProjectFile where
  getBio = bio

-- type Locale a = ProjectFile -> (ProjectFile -> a) -> TextField

-- withEn :: (Multilang a) => ProjectFile -> (ProjectFile -> a) -> TextField
-- withEn pf f = en . f $ pf
