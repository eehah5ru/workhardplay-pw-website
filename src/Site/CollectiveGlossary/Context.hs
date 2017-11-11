{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary.Context where

import           Control.Monad                   (foldM, forM, forM_, mplus)
import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)

import Hakyll
import Site.Context



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

mkFieldTerms :: Tags -> Compiler (Context a)
mkFieldTerms terms = do
  tags' <- forM (tagsMap terms) $ \(tag, ids) -> do
        route' <- getRoute $ tagsMakeId terms tag
        return (tag, route')
  return $ listField "terms" tagCtx (sequence . map makeItem $ tags')
  where
    toUrl' u = toUrl $ fromMaybe "/" u
    tagCtx =
      (field "term_name" (return . fst . itemBody))
      <> (field "term_url" (return . toUrl' . snd . itemBody))
