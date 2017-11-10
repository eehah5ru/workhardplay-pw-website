{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Hakyll

import Data.Monoid ((<>), mempty)

import Site.MultiLang

import Site.Utils

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

fieldYear = field "year" $ return . itemYear

fieldCanonicalName = field "canonical_name" $ return . itemCanonicalName

--
--
-- contexts
--
--
siteCtx :: Context String
siteCtx = ruUrlField
          <> enUrlField
          <> fieldYear
          <> fieldCanonicalName
          <> fieldRootUrl
          <> fieldArchiveUrl
          <> fieldArchiveName
          <> defaultContext
