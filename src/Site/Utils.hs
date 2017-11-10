{-# LANGUAGE OverloadedStrings #-}
module Site.Utils where

import System.FilePath.Posix ((</>), takeBaseName)


import Hakyll

itemYear :: Item a -> String
itemYear = flip (!!) 1 . itemPathParts

itemLang :: Item a -> String
itemLang = head . itemPathParts

itemCanonicalName :: Item a -> String
itemCanonicalName = getCanonicalName . reverse . itemPathParts
  where
    getCanonicalName =  takeBaseName . head


itemPathParts :: Item a -> [String]
itemPathParts i = splitAll "/" (toFilePath . itemIdentifier $ i)


loadImages :: Pattern -> Compiler [Item CopyFile]
loadImages = loadAll
