{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.Utils where

import System.FilePath.Posix ((</>), takeBaseName)

import Hakyll

import Site.Utils

--
--
-- project item
--
--
imagesPattern :: String -> String -> Pattern
imagesPattern year canonicalUrl =
  basicPath "*"
  where
    basicPath p = fromGlob $ "/images" ++ year ++ "/" ++ canonicalUrl ++ "/" ++ p


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
