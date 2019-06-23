{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Control.Applicative (Alternative (..))

import Hakyll

import Data.Monoid ((<>), mempty)

import W7W.MultiLang
import W7W.Utils
import W7W.Context

import Site.CollectiveGlossary.Utils (glossaryName)
import Site.Participants (fieldParticipantBio, fieldParticipantRawBio, fieldParticipantName, fieldParticipantCity)

import qualified W7W.Cache as Cache
--
--
-- site specific context fields
--
--
fieldArchiveUrl =
  field "archiveUrl" getArchiveUrl
  where
    getArchiveUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (yearPart i) ++ "archive.html"
    yearPart = maybe (error "year is missing!") (\x -> x ++ "/") . itemYear


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

fieldHasYear = boolField "hasYear" $  hasYear'
  where
    hasYear' = maybe False (const True) . itemYear

fieldYear = field "year" fieldYear'
  where
    fieldYear' = maybe empty return . itemYear

fieldRootUrl =
  field "rootUrl" getRootUrl
  where
    getRootUrl i = return $ "/" ++ (itemLang i) ++ "/" ++ (yearPart i)
    yearPart = maybe "" (\x -> x ++ "/") . itemYear


fieldDummyFunction =
  functionField "dummy" f
  where
    f [] _ = return "empty args"
    f [x] _ = return x
    f _ _ = error "dummy: many args"


--
--
-- contexts
--
--

--
-- minimal
--
minimalSiteCtx :: Context String
minimalSiteCtx =
  fieldRuUrl
    <> fieldEnUrl
    <> fieldLang
    <> fieldOtherLang
    <> fieldOtherLangUrl
    <> fieldYear
    <> fieldHasYear
    <> fieldCanonicalName
    <> fieldRootUrl
    <> fieldArchiveUrl
    <> fieldArchiveName
    <> fieldAboutName
    <> fieldGlossaryName
    <> fieldDummyFunction
    <> defaultContext

--
-- site default
--
mkSiteCtx :: Cache.Caches -> Compiler (Context String)
mkSiteCtx caches  = do
  r <- mkFieldRevision caches
  return $ minimalSiteCtx
           <> fieldParticipantBio
           <> fieldParticipantRawBio
           <> fieldParticipantCity
           <> fieldParticipantName
           <> r
