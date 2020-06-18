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
