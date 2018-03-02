{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary where



import Data.Maybe (fromMaybe)
import Data.List (find)
import Hakyll

import W7W.MultiLang
import W7W.Utils

import Site.Archive.Utils


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
  mRu <- getAllMetadata "ru/collective-glossary/*.md"
  mEn <- getAllMetadata "en/collective-glossary/*.md"

  ru <- buildTags' mRu RU
  en <- buildTags' mEn EN
  return $ mkTerms ru en
  where
    buildTags' m l = buildTags
                       (((l' "**/*.slim") .||. (l' "**/*.md"))
                        .&&. (complement (l' "**/_*.slim")))
                       (termToIdentifier l m)
      where l' = fromGlob . localizePath l


termToIdentifier :: Locale -> [(Identifier, Metadata)] -> String -> Identifier
termToIdentifier l ms term =
  let e = error  $ "there is no defenition for '" ++ term ++ "'"
      mi =  findTermCanonicalName ms term >>= return . fromCapture (fromGlob $ localizePath l "collective-glossary/*.md")
  in fromMaybe e mi

  where

    testF :: String -> (Identifier, Metadata) -> Bool
    testF term (i, m) =
      fromMaybe False $ lookupString "term" m >>= return . (==) term

    findTermCanonicalName :: [(Identifier, Metadata)] -> String -> Maybe String
    findTermCanonicalName ms term =
      find (testF term) ms >>= return . fst >>= return . identifierCanonicalName
