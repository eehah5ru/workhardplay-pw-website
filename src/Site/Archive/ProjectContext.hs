{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.ProjectContext where

import Data.ByteString.Lazy (ByteString)

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Control.Monad ((>=>))

import Data.Binary
import Data.Typeable

import Hakyll
import Site.Context


import Site.Utils
import Site.Archive.Utils

import Site.CollectiveGlossary.Context (fieldTermsList)
--
--
-- metadata predicates
--
--
hasYoutubeVideoId :: MonadMetadata m => Item a -> m Bool
hasYoutubeVideoId = hasItemField "youtube_video_id"

hasSoundcloudTrackId :: MonadMetadata m => Item a -> m Bool
hasSoundcloudTrackId = hasItemField "soundcloud_track_id"

-- hasImages :: MonadMetadata m => Item a -> m Bool
-- hasImages i = sequence (map (\x -> hasItemField x i) imageFieldNames) >>= return . any id
--   where imageFieldNames = map mkImageField [1..100]
--         mkImageField ii = "image_" ++ (show ii)

hasImages ::  Item a -> Compiler Bool
hasImages i = do
  is <- loadAll (imagesPattern i) :: Compiler [Item CopyFile]
  return . not . null $ is


hasVideo :: MonadMetadata m => Item a -> m Bool
hasVideo i =  sequence [hasYoutubeVideoId i] >>= return . any id

hasAudio :: MonadMetadata m => Item a -> m Bool
hasAudio i = sequence [hasSoundcloudTrackId i] >>= return . any id

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


fieldHasVideo = do
  boolFieldM "has_video" hasVideo

fieldHasAudio = do
  boolFieldM "has_audio" hasAudio

fieldHasImages =
  boolFieldM "has_images" hasImages


fieldHasMedia =
  boolFieldM "has_media" hasMedia'
  where
    hasMedia' i = sequence ps >>= return  . any id
     where ps = [hasImages i
                ,hasVideo i
                ,hasAudio i]

fieldProjectCover :: Context String
fieldProjectCover =
  field "project_cover" getCoverUrl
  where
    getCoverUrl i = do
      covers <- loadAll (projectCoverPattern i) :: Compiler [Item CopyFile]
      case (null covers) of
        True -> return "/images/not-found-cover.jpg"
        False -> return . toUrl . toFilePath . itemIdentifier . head $ covers

fieldImages :: Context String
fieldImages = listFieldWith "images" mkImageItem (\i -> loadImages (imagesPattern i))
  where
    mkImageItem =
      urlField "image_url"

--
-- project page ctx
--
archiveProjectCtx terms =
  fieldProjectTitle
  <> fieldProjectCover
  <> fieldHasMedia
  <> fieldHasVideo
  <> fieldHasImages
  <> fieldImages
  <> (fieldTermsList terms)
  <> siteCtx
