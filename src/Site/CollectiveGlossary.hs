{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary where



import Data.Maybe (fromMaybe)
import Data.List (find)
import Hakyll

import Site.Archive.Utils
import Site.MultiLang

import Site.Utils

data Terms = Terms {ruTerms :: Tags
                   ,enTerms :: Tags}

mkTerms :: Tags -> Tags -> Terms
mkTerms = Terms

terms :: Locale -> Terms -> Tags
terms RU = ruTerms
terms EN = enTerms
terms _ = error "unknown locale"

buildTerms :: Rules Terms
buildTerms = do
  m <- getAllMetadata "collective-glossary/*.md"
  ru <- buildTags' m RU
  en <- buildTags' m EN
  return $ mkTerms ru en
  where
    buildTags' m l = buildTags
                       (((l' "**/*.slim") .||. (l' "**/*.md"))
                        .&&. (complement (l' "**/_*.slim")))
                       (termToIdentifier l m)
      where l' = fromGlob . localizePath l


termToIdentifier :: Locale -> [(Identifier, Metadata)] -> String -> Identifier
termToIdentifier l ms term =
  let e = error . unwords $ ["there is no defenition for ", term]
      mi =  findTermCanonicalName ms term >>= return . fromCapture (fromGlob $ localizePath l "collective-glossary/*.html")
  in fromMaybe e mi

  where

    testF :: String -> (Identifier, Metadata) -> Bool
    testF term (i, m) =
      fromMaybe False $ lookupString (localizeField l "title") m >>= return . (==) term

    findTermCanonicalName :: [(Identifier, Metadata)] -> String -> Maybe String
    findTermCanonicalName ms term =
      find (testF term) ms >>= return . fst >>= return . identifierCanonicalName
