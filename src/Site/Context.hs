{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Control.Applicative (Alternative (..))

import Hakyll

import Data.Monoid ((<>), mempty)

import W7W.MultiLang

import W7W.Utils

boolFieldM :: String -> (Item a -> Compiler Bool) -> Context a
boolFieldM name f = field name $ \i -> do
                      b <- f i
                      if b
                        then pure $ error $ unwords $
                                 ["no string value for bool field:",name]
                        else empty
--
--
-- utils
--
--

hasMetadataField :: String -> Metadata -> Bool
hasMetadataField fName m =
  case lookupString fName m of
    Just _ -> True
    Nothing -> False

hasItemField :: MonadMetadata m => String -> Item a -> m Bool
hasItemField fName =
  withItemMetadata $ hasMetadataField fName


withItemMetadata :: MonadMetadata m => (Metadata -> b) -> Item a -> m b
withItemMetadata f item = do
  m <- getMetadata (itemIdentifier item)
  return $ f m

--
--
-- fields
--
--
fieldRootUrl =
  field "root_url" getRootUrl
  where
    getRootUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (itemYear i) ++ "/"

fieldArchiveUrl =
  field "archive_url" getArchiveUrl
  where
    getArchiveUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (itemYear i) ++ "/archive.html"


fieldArchiveName =
  field "archive_name" getName
  where
    getName i = return $ case (itemLang i) of
                           "ru" -> "Архив"
                           "en" -> "Archive"
                           _ -> "Noname Archive"

fieldGlossaryName =
  field "glossary_name" getName
  where
    getName = return . chooseByItemLang "Глоссарий" "Glossary"
fieldYear = field "year" $ return . itemYear

fieldCanonicalName = field "canonical_name" $ return . itemCanonicalName

fieldLang = field "lang" $ return . itemLang


--
--
-- contexts
--
--
siteCtx :: Context String
siteCtx = fieldRuUrl
          <> fieldEnUrl
          <> fieldLang
          <> fieldOtherLang
          <> fieldOtherLangUrl
          <> fieldYear
          <> fieldCanonicalName
          <> fieldRootUrl
          <> fieldArchiveUrl
          <> fieldArchiveName
          <> fieldGlossaryName
          <> defaultContext
