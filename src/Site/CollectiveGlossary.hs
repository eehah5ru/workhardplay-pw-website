{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary where


import           Data.Monoid (mappend, (<>))

import           Control.Monad                   (foldM, forM, forM_, mplus)
import qualified Data.Set                        as S
import qualified Data.Map                        as M
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


-- buildTags' :: MonadMetadata m => Pattern -> (Identifier -> String -> Identifier) -> m Tags
-- buildTags' pattern makeId = do
--     ids    <- getMatches pattern
--     tagMap <- foldM addTags M.empty ids
--     let set' = S.fromList ids
--     return $ Tags (M.toList tagMap) makeId (PatternDependency pattern set')
--   where
--     -- Create a tag map for one page
--     addTags tagMap id' = do
--         tags <- getTags id'
--         let tagMap' = M.fromList $ zip tags $ repeat [id']
--         return $ M.unionWith (++) tagMap tagMap'

checkTags :: Locale -> [(Identifier, Metadata)] -> Tags -> Rules ()
checkTags l termsMetadata tags = do
  mapM_ checkTag' (tagsMap tags)

  where
    checkDocTag' :: String -> Identifier -> Rules ()
    checkDocTag' tagName docId = do
      let e = error  $ (show docId) ++ ": there is no defenition for '" ++ tagName ++ "'"
          mi = termToIdentifierMaybe l termsMetadata tagName
        in return (fromMaybe e mi) >> return ()


    checkTag' :: (String, [Identifier]) -> Rules ()
    checkTag' (tagName, docIds) = do
      mapM_ (checkDocTag' tagName) docIds


buildTerms :: Rules Terms
buildTerms = do
  mRu <- getAllMetadata "ru/collective-glossary/*.md"
  mEn <- getAllMetadata "en/collective-glossary/*.md"

  ruTags <- buildTags'' mRu RU
  enTags <- buildTags'' mEn EN

  checkTags RU mRu ruTags
  checkTags EN mEn enTags

  return $ mkTerms ruTags enTags
  where
    buildTags'' m l = buildTags
                       termsSources
                       (termToIdentifier l m)
      where
        l' = fromGlob . localizePath l
        byYear year p = l' (year ++ "/" ++ p)
        projectsPattern year =
          let byYear' = byYear year
          in ((byYear' "*.slim") .||. (byYear' "*.md"))
             .&&. (complement . byYear' $ "_*.slim")
             .&&. (complement . byYear' $ ".*.slim")
             .&&. (complement . byYear' $ ".*.md")
        -- FIXME: remove dependency on projects pattern!!!
        termsSources = (projectsPattern "2016/archive") .||. (projectsPattern "2017/projects") .||. (projectsPattern "2018/projects") .||. (projectsPattern "2019/projects")




termToIdentifier :: Locale -> [(Identifier, Metadata)] -> String -> Identifier
termToIdentifier l ms term =
  let e = error  $ "there is no defenition for '" ++ term ++ "'"
      mi = termToIdentifierMaybe l ms term
  in fromMaybe e mi


termToIdentifierMaybe :: Locale -> [(Identifier, Metadata)] -> String -> Maybe Identifier
termToIdentifierMaybe l ms term =
 findTermCanonicalName ms term >>= return . fromCapture (fromGlob $ localizePath l "collective-glossary/*.md")

 where

    testF :: String -> (Identifier, Metadata) -> Bool
    testF term (i, m) =
      fromMaybe False $ lookupString "term" m >>= return . (==) term

    findTermCanonicalName :: [(Identifier, Metadata)] -> String -> Maybe String
    findTermCanonicalName ms term =
      find (testF term) ms >>= return . fst >>= return . identifierCanonicalName
