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
imagesPattern :: Item a -> Pattern
imagesPattern i =
  basicImagePattern i "*"

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
  basicImagePattern i $ (itemCanonicalName i) ++ "-cover.*"

basicImagePattern :: Item a -> String -> Pattern
basicImagePattern i p =
  fromGlob $ "images/" ++ (itemYear i) ++ "/" ++ (itemCanonicalName i) ++ "/" ++ p

basicImageUrl :: Item a -> String
basicImageUrl i = "/images/" ++ (itemYear i) ++ "/" ++ (itemCanonicalName i) ++ "/"

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
