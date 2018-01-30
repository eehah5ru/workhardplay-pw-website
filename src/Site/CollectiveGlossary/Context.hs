{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary.Context where

import           Control.Monad                   (foldM, forM, forM_, mplus)
import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Data.Tuple.Utils

import Hakyll
import Site.Context
import W7W.MultiLang
import W7W.Utils

import Site.CollectiveGlossary.Utils


-- fieldTags :: (String -> String) -> Pattern -> Context a
-- fieldTags localize tagsPattern = do
--   tags <- buildTags tagsPattern (fromCapture (fromGlob (localize "/tags/*.html")))
--   undefined
--   where
--     getTags

fieldTermsList :: Tags -> Context a
fieldTermsList terms =
  tagsField "terms_list" terms


fieldTermName :: String -> Context a
fieldTermName term =
  constField "term_name" term

fieldTermTitle :: Context a
fieldTermTitle =
  field "title" termTitle
  where
    termName m = fromMaybe "noname" (lookupString "term" m)
    termTitle item = do
      m <- getMetadata (itemIdentifier item)
      return $ glossaryName item ++ " -> " ++ (termName m)

--
-- utils for terms and many terms context fields
--
tagsInfo terms = do
  forM (tagsMap terms) $ \(tag, ids) -> do
    route' <- getRoute $ tagsMakeId terms tag
    termBody <- loadSnapshotBody (tagsMakeId terms tag) "content"
    return (tag, route', termBody)

tagCtx =
  (field "term_name" (return . fst3 . itemBody))
  <> (field "term_url" (return . toUrl' . snd3 . itemBody))
  <> (field "term_definition" (return . thd3 . itemBody))
  where
    toUrl' u = toUrl $ fromMaybe "/" u


mkFieldTerms :: Tags -> Compiler (Context a)
mkFieldTerms terms = do
  tags' <- tagsInfo terms
  return $ listField "terms" tagCtx (sequence . map makeItem $ tags')




mkFieldManyTerms :: Int -> Tags -> Compiler (Context a)
mkFieldManyTerms n terms = do
  tags' <- (return . take n . cycle) =<< tagsInfo terms
  return $ listField "many_terms" tagCtx (sequence . map makeItem $ tags')
