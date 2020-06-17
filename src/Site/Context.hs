{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Control.Applicative (Alternative (..))

import System.Random

import Hakyll
import Hakyll.Core.Compiler.Internal (compilerUnsafeIO)

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

--
-- snapshot "conten" of the item
--
fieldContent :: Context String
fieldContent = field "content" content'
  where
    content' i = loadSnapshotBody (itemIdentifier i) "content"


fieldDummyFunction =
  functionField "dummy" f
  where
    f [] _ = return "empty args"
    f [x] _ = return x
    f _ _ = error "dummy: many args"


fieldRandomFunction =
  functionField "random" f
  where
    usage = "usage: random(min, max)"
    f [] _ =  error $ "random: empty args. " ++ usage
    f ([_]) _ = error $ "too few args. " ++ usage
    f [minS, maxS] _ = return . show =<< compilerUnsafeIO getRandomInt
      where
        getRandomInt = do
          g <- newStdGen
          (i, g') <- return $ randomR (min, max) g
          return i
        min :: Int
        min = read minS

        max :: Int
        max = read maxS

    f _ _ = error $ "too many args. " ++ usage
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
    <> fieldRandomFunction
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
