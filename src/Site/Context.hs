{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Control.Applicative (Alternative (..))

import Hakyll

import Data.Monoid ((<>), mempty)

import W7W.MultiLang
import W7W.Utils
import W7W.Context


--
--
-- site specific context fields
--
--
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

fieldRootUrl =
  field "root_url" getRootUrl
  where
    getRootUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (itemYear i) ++ "/"



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
