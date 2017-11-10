{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.ProjectContext where

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Control.Monad ((>=>))

import Hakyll
import Site.Context


import Site.Utils
import Site.Archive.Utils

--
--
-- metadata predicates
--
--
hasYoutubeVideoId :: MonadMetadata m => Item a -> m Bool
hasYoutubeVideoId = hasItemField "youtube_video_id"

-- hasImages :: MonadMetadata m => Item a -> m Bool
-- hasImages i = sequence (map (\x -> hasItemField x i) imageFieldNames) >>= return . any id
--   where imageFieldNames = map mkImageField [1..100]
--         mkImageField ii = "image_" ++ (show ii)

hasImages :: MonadMetadata m => Item a -> m Bool
hasImages = return . const True


hasVideo :: MonadMetadata m => Item a -> m Bool
hasVideo i =  sequence [hasYoutubeVideoId i] >>= return . any id

--
--
-- fields
--
--

fieldProjectTitle :: Context String
fieldProjectTitle =
  field "title" getTitleFromItem
  where
    projectName m = fromMaybe "noname" (lookupString "project_title" m)
    authorName m = fromMaybe "noname" (lookupString "author" m)
    getTitleFromItem item = do
      m <- getMetadata (itemIdentifier item)
      return $ (authorName m) ++ " -> " ++ (projectName m)


fieldHasVideo =
  field "has_video" hasVideo'
  where
    hasVideo' :: Item a -> Compiler String
    hasVideo' = hasVideo >=> return . show

fieldHasImages =
  field "has_images" (hasImages >=> return . show)


fieldHasMedia =
  field "has_media" hasMedia'
  where
    hasMedia' i = sequence ps >>= return . show . any id
     where ps = [hasImages i
                ,hasVideo i]

--
-- project page ctx
--
archiveProjectCtx =
  fieldProjectTitle
  <> fieldHasMedia
  <> fieldHasVideo
  <> fieldHasImages
  <> siteCtx
