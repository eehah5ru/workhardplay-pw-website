{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.Rules where

import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))

import qualified W7W.Cache as Cache

import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography

import qualified W7W.Cache as Cache

import Site.Template
import Site.Context
import Site.Schedule.Context


scheduleRules :: Cache.Caches -> String -> Rules ()
scheduleRules caches year = do


  matchMultiLang participantRules'' participantRules'' (participantsPattern year)

  matchMultiLang participantTxtRules'' participantTxtRules'' (participantsPattern year)

  withDeps hasNoVersion [participantsDeps year] $ matchMultiLang (eventRules'' caches ) (eventRules'' caches) (eventsPattern year)

  withDeps hasNoVersion [participantsDeps year] $ matchMultiLang (eventTxtRules'' caches) (eventTxtRules'' caches) (eventsPattern year)

  withDeps hasNoVersion [participantsDeps year, eventsDeps year] $ do
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "all-days")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "monday")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "tuesday")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "wednesday")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "thursday")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "friday")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "saturday")
    matchMultiLang (placeRules'' caches) (placeRules'' caches) (placesPattern year "sunday")

  withDeps hasTxtVersion [participantsDeps year, eventsDeps year] $ do
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "all-days")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "monday")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "tuesday")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "wednesday")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "thursday")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "friday")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "saturday")
    matchMultiLang (placeTxtRules'' caches) (placeTxtRules'' caches) (placesPattern year "sunday")

  withDeps hasNoVersion [participantsDeps year, eventsDeps year, placesDeps year] $ matchMultiLang (daysRules'' caches) (daysRules'' caches) (daysPattern year)

  withDeps hasTxtVersion [(participantsDeps year), (eventsDeps year), (placesDeps year)] $ matchMultiLang (dayTxtRules'' caches) (dayTxtRules'' caches) (daysPattern year)

  withDeps hasNoVersion [(participantsDeps year), (eventsDeps year), (placesDeps year), (daysDeps year)] $ matchMultiLang (scheduleRules' caches) (scheduleRules' caches) (schedulePattern year)

hasTxtVersion = hasVersion "txt"

days = [ "all-days"
       , "monday"
       , "tuesday"
       , "wednesday"
       , "thursday"
       , "friday"
       , "saturday"
       , "sunday" ]

schedulePattern year = year </> "schedule.md"

daysPattern year = year </> "schedule/*.md"

placesPattern year d = year </> "schedule" </> d </> "*.md"

eventsPattern year = year </> "schedule/*/*/*.md"

participantsPattern year = year </> "participants/*.md"

-- rawContentCompiler l =
--    getResourceBody >>= saveSnapshot "raw_content"

depsPattern' p = f' RU .||. f' EN
  where
    f' l = fromGlob . localizePath l $ p

participantsDeps year = depsPattern' (participantsPattern year)

eventsDeps year = depsPattern' (eventsPattern year)

placesDeps year = (foldr (.||.) mempty $ map (depsPattern' . placesPattern year) days)

daysDeps year = depsPattern' (daysPattern year)

withDeps verPattern dPatterns rules  = do
  deps <- mapM makePatternDependency $ map ((.&&.) verPattern) dPatterns
  rulesExtraDependencies deps rules

-- if separate page is not needed
contentRules caches l cTpl ctxF = do
  compile $ do
    ctx <- ctxF caches hasNoVersion
    pandocCompiler
     >>= beautifyTypography
     >>= applyAsTemplate ctx
     >>= loadAndApplyTemplate cTpl ctx
     >>= saveSnapshot "content"


pageRules caches l cTpl pTpl ctxF =
  markdownPageRules $ \x -> do
    ctx <- ctxF caches hasNoVersion
    beautifyTypography x
      >>= applyAsTemplate ctx
      >>= loadAndApplyTemplate cTpl ctx
      >>= saveSnapshot "content"
      >>= loadAndApplyTemplate pTpl ctx
      >>= loadAndApplyTemplate rootPageTpl ctx
      >>= loadAndApplyTemplate rootTpl ctx

pageTxtRules caches l cTpl ctxF = do
  route $ setExtension "txt"
  compile $ do
    ctx <- ctxF caches (hasTxtVersion)
    getResourceBody
      >>= applyAsTemplate ctx
      >>= loadAndApplyTemplate cTpl ctx
      >>= saveSnapshot "content"

participantRules'' locale = do
  compile $ do
    pandocCompiler
      >>= beautifyTypography
      >>= saveSnapshot "content"


participantTxtRules'' locale = version "txt" $ participantRules'' locale


eventRules'' caches locale = do
  pageRules caches locale contentTemplate pageTemplate (mkEventContext)

  where
    contentTemplate = "templates/schedule-event-item-2019.slim"
    pageTemplate = "templates/schedule-event-page-2019.slim"


eventTxtRules'' caches locale = version "txt" $ do
  pageTxtRules caches locale "templates/schedule-event-item-2019-txt.html" mkEventContext


placeRules'' caches locale = do
  -- without separate page
  contentRules caches locale contentTemplate mkPlaceContext
  --pageRules locale contentTemplate pageTemplate
  where
    contentTemplate = "templates/schedule-place-item-2019.slim"

placeTxtRules'' caches locale = version "txt" $ do
  pageTxtRules caches locale "templates/schedule-place-item-2019-txt.html" mkPlaceContext

daysRules'' caches locale = do
  pageRules caches locale contentTemplate pageTemplate mkDayContext

  where
    contentTemplate = "templates/schedule-day-item-2019.slim"
    pageTemplate = "templates/schedule-day-page-2019.slim"

dayTxtRules'' caches locale = version "txt" $ do
  pageTxtRules caches locale "templates/schedule-day-item-2019-txt.html" mkDayContext

scheduleRules' caches locale =
   pageRules caches locale contentTemplate pageTemplate mkScheduleContext
   where
     contentTemplate = "templates/schedule-item-2019.slim"
     pageTemplate = "templates/schedule-2019.slim"
