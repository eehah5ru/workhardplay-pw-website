{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Control.Applicative (Alternative (..))

import Hakyll

import Data.Monoid ((<>), mempty)

import W7W.MultiLang
import W7W.Utils
import W7W.Context

import Site.CollectiveGlossary.Utils (glossaryName)

--
--
-- site specific context fields
--
--
fieldArchiveUrl =
  field "archiveUrl" getArchiveUrl
  where
    getArchiveUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (itemYear i) ++ "/archive.html"


fieldArchiveName =
  field "archiveName" getName
  where
    getName i = return $ case (itemLang i) of
                           "ru" -> "Архив"
                           "en" -> "Archive"
                           _ -> "Noname Archive"

fieldAboutName =
  field "aboutName" getName
  where
    getName = return . chooseByItemLang "Что это" "About"

fieldGlossaryName =
  field "glossaryName" getName
  where
    getName = return . glossaryName

fieldYear = field "year" $ return . itemYear

fieldRootUrl =
  field "rootUrl" getRootUrl
  where
    getRootUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (itemYear i) ++ "/"


fieldDummyFunction =
  functionField "dummy" f
  where
    f [] _ = return "empty args"
    f [x] _ = return x
    f _ _ = error "dummy: manay args"


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
          <> fieldAboutName
          <> fieldGlossaryName
          <> fieldDummyFunction
          <> defaultContext
