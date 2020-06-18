{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.ProjectContext where


import Data.ByteString.Lazy (ByteString)

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Control.Monad ((>=>))
import Control.Applicative ((<|>))

import qualified Data.Text as T

import Data.Binary
import Data.Typeable

import Hakyll

import Site.Util

import W7W.HasVersion

import W7W.Utils
import W7W.Context
import W7W.Context.Media

import W7W.Pictures.Context
import W7W.Pictures.Utils
import W7W.MultiLang
import qualified W7W.Cache as Cache


import W7W.Pictures.Context
import W7W.Pictures.Utils

import W7W.PictureColor
import W7W.PictureColor.Types
import W7W.PictureColor.Operations

import Site.Pictures.Utils

import Site.Context

import Site.Archive.Utils

import Site.CollectiveGlossary.Context (fieldTermsList)
import qualified Site.Schedule.Context as SC
import qualified Site.ParticipantsNg.Context as PC
import qualified Site.ParticipantsNg.Types as PT

import W7W.Labels.Types


-- hasImages :: MonadMetadata m => Item a -> m Bool
-- hasImages i = sequence (map (\x -> hasItemField x i) imageFieldNames) >>= return . any id
--   where imageFieldNames = map mkImageField [1..100]
--         mkImageField ii = "image_" ++ (show ii)

-- hasImages ::  Item a -> Compiler Bool
-- hasImages i = do
--   is <- loadAll (imagesPattern i) :: Compiler [Item CopyFile]
--   return . not . null $ is



--
--
-- fields
--
--

fieldProjectTitle :: Context String
fieldProjectTitle =
  field "title" getTitleFromItem
  where
    format' m = fromMaybe "noname" m
    
    getTitleFromItem item = do
      a <- formattedAuthor
      p <- formattedProjectName
      
      return $ a ++ " -> " ++ p

      where
        meta = getMetadata (itemIdentifier item)

        authorFromMeta = meta >>= return . lookupString "author"

        authorFromParticipant = PC.maybeParticipantName item

        projectNameFromMeta = meta >>= return . lookupString "projectTitle"
        
        formattedAuthor = do
          a' <- authorFromParticipant
          a'' <- authorFromMeta
          return $ format' $  a' <|> a''

        formattedProjectName = return . format' =<< projectNameFromMeta


--
-- field Project Cover
--
fieldProjectCover = fieldCover "projectCover" coverPattern

--
--
-- FIXME: color using cached data in the file
--
-- 
fieldProjectColor :: (Cache.HasCache c) => c -> Context a
fieldProjectColor c = field "projectColor" f
  where
    f :: Item a -> Compiler String 
    f i = return . formatColor $ mkColor 255 0 0

-- fieldProjectColor :: Cache.Caches -> Context String
-- fieldProjectColor caches =
--   fieldPictureColor caches
--                     "projectColor"
--                     projectCoverPath
--                     (mkColor 255 0 0)
--                     colorChange
--   where
--     colorChange = saturate . opposite
--     projectCoverPath i = do
--       -- covers <- -- loadAll (projectCoverPattern i) :: Compiler [Item ByteString]
--       covers <- loadPictures (projectCoverPattern i)
--       case (null covers) of
--         True -> return Nothing
--         False -> return . Just . itemIdentifier . head $ covers



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

mkArchiveProjectCtx
  :: (Cache.HasCache c, HasLabels c) => c
     -> Tags -> Compiler (Context String)

mkArchiveProjectCtx cfg terms =
  do
    pCfg <- return $ PT.Config{PT.cache = (Cache.getCache cfg), PT.labels = (getLabels cfg), PT.version=DefaultVersion}
    
    siteCtx <- (mkSiteCtx (Cache.getCache cfg) (getLabels cfg))
    participantField <- PT.execParticipantsEnv pCfg PC.mkFieldParticipant
    return $ fieldProjectTitle
      <> fieldProjectCover
      <> fieldHasMedia picturesPattern
      <> fieldHasVideo
      -- <> fieldHasVideoText       
      <> fieldHasAudio
      <> (fieldProjectColor cfg)
      <> (fieldHasPictures picturesPattern)
      <> (fieldPictures cfg picturesPattern)
      <> (fieldTermsList terms)
      <> (fieldHasTerms terms)
      <> (fieldTermsLabel)
      <> PC.fieldParticipantName
      <> PC.fieldHasParticipant
      <> participantField
      -- <> functionPictureAltTitleAttr
      <> siteCtx
