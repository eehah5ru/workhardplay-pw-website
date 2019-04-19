{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.Utils where

import System.FilePath.Posix ((</>), takeBaseName)

import Hakyll

import W7W.Utils

--
--
-- project item
--
--
picturesPattern :: Item a -> Pattern
picturesPattern i =
  (basicPicturePattern i "*") .||. (basicPicturePattern i ((itemLang i) ++ "/*"))

archiveProjectsPattern :: FilePath -> Pattern
archiveProjectsPattern base =
  (archiveProjectsSlimPattern base) .||. (archiveProjectsMdPattern base)

archiveProjectsTypedPattern :: String -> FilePath -> Pattern
archiveProjectsTypedPattern capture base =
  pattern' capture
  where
    pattern' p = toPattern' $ base </> p
    toPattern' :: FilePath -> Pattern
    toPattern' = fromGlob

archiveProjectsSlimPattern :: FilePath -> Pattern
archiveProjectsSlimPattern = archiveProjectsTypedPattern "*.slim"

archiveProjectsMdPattern :: FilePath -> Pattern
archiveProjectsMdPattern = archiveProjectsTypedPattern "*.md"


projectCoverPattern :: Item a -> Pattern
projectCoverPattern i =
  (basicPicturePattern i ((itemCanonicalName i) ++ "-cover.*")) .||. (picturesPattern i)

basicPicturePattern :: Item a -> String -> Pattern
basicPicturePattern i p =
  fromGlob $ "pictures/" ++ (yearPart i) ++ (itemCanonicalName i) ++ "/" ++ p
  where
    yearPart = maybe "" (\x -> x ++ "/") . itemYear

basicPictureUrl :: Item a -> String
basicPictureUrl i = "/pictures/" ++ (yearPart i) ++ (itemCanonicalName i) ++ "/"
  where
    yearPart = maybe "" (\x -> x ++ "/") . itemYear

--
--
-- archive index item
--
--
-- itemIndexYear :: Item a -> String
-- itemIndexYear = getYear . itemPathParts'
--   where
--     getYear = flip (!!) 1

--
--
-- utils
--
--
itemPathParts' = reverse . itemPathParts
