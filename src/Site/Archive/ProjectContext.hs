{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.ProjectContext where

import Data.ByteString.Lazy (ByteString)

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Control.Monad ((>=>))

import qualified Data.Text as T

import Data.Binary
import Data.Typeable

import Hakyll

import W7W.Utils
import W7W.Context
import W7W.Pictures.Context
import W7W.Pictures.Utils
import W7W.MultiLang
import qualified W7W.Cache as Cache

import W7W.Pictures.Context
import W7W.Pictures.Utils

import W7W.PictureColor
import W7W.PictureColor.Types
import W7W.PictureColor.Operations

import Site.Context

import Site.Archive.Utils

import Site.CollectiveGlossary.Context (fieldTermsList)
--
--
-- metadata predicates
--
--
hasYoutubeVideoId :: MonadMetadata m => Item a -> m Bool
hasYoutubeVideoId = hasItemField "youtubeVideoId"

hasYoutubeVideoNumId :: MonadMetadata m => Int -> Item a -> m Bool
hasYoutubeVideoNumId n i = hasItemField ("youtubeVideoId0" ++ (show n)) i

hasVimeoVideoId :: MonadMetadata m => Item a -> m Bool
hasVimeoVideoId = hasItemField "vimeoVideoId"

hasVimeoVideoNumId :: MonadMetadata m => Int -> Item a -> m Bool
hasVimeoVideoNumId n i = hasItemField ("vimeoVideoId0" ++ (show n)) i

hasSoundcloudTrackId :: MonadMetadata m => Item a -> m Bool
hasSoundcloudTrackId = hasItemField "soundcloudTrackId"

-- hasImages :: MonadMetadata m => Item a -> m Bool
-- hasImages i = sequence (map (\x -> hasItemField x i) imageFieldNames) >>= return . any id
--   where imageFieldNames = map mkImageField [1..100]
--         mkImageField ii = "image_" ++ (show ii)

-- hasImages ::  Item a -> Compiler Bool
-- hasImages i = do
--   is <- loadAll (imagesPattern i) :: Compiler [Item CopyFile]
--   return . not . null $ is


hasVideo :: MonadMetadata m => Item a -> m Bool
hasVideo i =  sequence videoPredicates >>= return . any id
  where
    videoPredicates = [ hasYoutubeVideoId i
                      , hasVimeoVideoId i ] ++
                      (map (\n -> hasYoutubeVideoNumId n i) [1..9]) ++
                      (map (\n -> hasVimeoVideoNumId n i)) [1..9]

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
    projectName m = fromMaybe "noname" (lookupString "projectTitle" m)
    authorName m = fromMaybe "noname" (lookupString "author" m)
    getTitleFromItem item = do
      m <- getMetadata (itemIdentifier item)
      return $ (authorName m) ++ " -> " ++ (projectName m)


fieldHasVideo = do
  boolFieldM "hasVideo" hasVideo

fieldHasAudio = do
  boolFieldM "hasAudio" hasAudio

-- fieldHasImages =
--   boolFieldM "hasImages" hasImages


fieldHasMedia =
  boolFieldM "hasMedia" hasMedia'
  where
    hasMedia' i = sequence ps >>= return  . any id
     where ps = [hasPictures picturesPattern i
                ,hasVideo i
                ,hasAudio i]

fieldProjectCover :: Context String
fieldProjectCover =
  field "projectCover" getCoverUrl
  where
    missingCoverUrl = "/images/not-found-cover.jpg"
    coverUrl i = do
      mR <- getRoute i
      case mR of
        Just r -> return $ toUrl r
        _ -> return missingCoverUrl
    getCoverUrl i = do
      covers <- loadAll (projectCoverPattern i) :: Compiler [Item ()]
      case (null covers) of
        True -> return missingCoverUrl
        False -> coverUrl . itemIdentifier . head $ covers

-- fieldImages :: Context String
-- fieldImages = listFieldWith "images" mkImageItem (\i -> loadPictures (imagesPattern i))
--   where
--     mkImageItem =
--       urlField "imageUrl"

fieldProjectColor :: Cache.Caches -> Context String
fieldProjectColor caches =
  fieldPictureColor caches
                    "projectColor"
                    projectCoverPath
                    (mkColor 255 0 0)
                    colorChange
  where
    colorChange = saturate . opposite
    projectCoverPath i = do
      -- covers <- -- loadAll (projectCoverPattern i) :: Compiler [Item ByteString]
      covers <- loadPictures (projectCoverPattern i)
      case (null covers) of
        True -> return Nothing
        False -> return . Just . itemIdentifier . head $ covers


fieldTermsLabel :: Context a
fieldTermsLabel = field "termsLabel" termsLabel
  where
    termsLabel i = do
      return $ case (fromLang (itemLang i)) of
                 RU -> "Термины"
                 EN -> "Terms"
                 _ -> "Terms"

fieldHasTerms :: Tags -> Context a
fieldHasTerms terms =
  boolField "hasTerms" hasTerms
  where
    hasTerms _ = not . null . tagsMap $ terms


-- functionPictureAltTitleAttr =
--   functionField "pictureAltTitleAttr" f
--   where
--     escapeQuotes = T.unpack . T.replace "\"" "&Prime;" . T.pack
--     makeAttr c t d
--       | (null d) = (escapeQuotes t) ++ " - " ++ (escapeQuotes c)
--       | otherwise = (escapeQuotes t) ++ " - " ++ (escapeQuotes c) ++ " - " ++ (escapeQuotes d)
--     f ("":"":"":[]) _ = return "empty"
--     f (creator:title:description:[]) _ = return $ makeAttr creator title description
--     f _ _ = error "pictureAltTitleAttr: malformed args. Usage pictureAltTitleAttr(creator, title, description)"

--
-- project page ctx
--

mkArchiveProjectCtx caches terms =
  do 
     siteCtx <- mkSiteCtx
     return $ fieldProjectTitle
       <> fieldProjectCover
       <> fieldHasMedia
       <> fieldHasVideo
       <> fieldHasAudio
       <> (fieldProjectColor caches)
       <> (fieldHasPictures picturesPattern)
       <> (fieldPictures caches picturesPattern)
       <> (fieldTermsList terms)
       <> (fieldHasTerms terms)
       <> (fieldTermsLabel)
       -- <> functionPictureAltTitleAttr
       <> siteCtx
