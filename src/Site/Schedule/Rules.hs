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


  matchMultiLang participantRules'' participantRules'' participantsPattern

  matchMultiLang participantTxtRules'' participantTxtRules'' participantsPattern

  withDeps hasNoVersion [participantsDeps] $ matchMultiLang eventRules'' eventRules'' (eventsPattern)

  withDeps hasNoVersion [participantsDeps] $ matchMultiLang eventTxtRules'' eventTxtRules'' (eventsPattern)

  withDeps hasNoVersion [participantsDeps, eventsDeps] $ do
    matchMultiLang placeRules'' placeRules'' (placesPattern "all-days")
    matchMultiLang placeRules'' placeRules'' (placesPattern "monday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "tuesday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "wednesday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "thursday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "friday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "saturday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "sunday")

  withDeps hasTxtVersion [participantsDeps, eventsDeps] $ do
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "all-days")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "monday")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "tuesday")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "wednesday")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "thursday")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "friday")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "saturday")
    matchMultiLang placeTxtRules'' placeTxtRules'' (placesPattern "sunday")

  withDeps hasNoVersion [participantsDeps, eventsDeps, placesDeps] $ matchMultiLang daysRules'' daysRules'' daysPattern

  withDeps hasTxtVersion [participantsDeps, eventsDeps, placesDeps] $ matchMultiLang dayTxtRules'' dayTxtRules'' daysPattern

  withDeps hasNoVersion [participantsDeps, eventsDeps, placesDeps, daysDeps] $ matchMultiLang scheduleRules' scheduleRules' schedulePattern

  where

    hasTxtVersion = hasVersion "txt"

    days = [ "all-days"
           , "monday"
           , "tuesday"
           , "wednesday"
           , "thursday"
           , "friday"
           , "saturday"
           , "sunday" ]

    schedulePattern = year </> "schedule.md"

    daysPattern = year </> "schedule/*.md"

    placesPattern d = year </> "schedule" </> d </> "*.md"

    eventsPattern = year </> "schedule/*/*/*.md"

    participantsPattern = year </> "participants/*.md"

    -- rawContentCompiler l =
    --    getResourceBody >>= saveSnapshot "raw_content"

    depsPattern' p = f' RU .||. f' EN
      where
        f' l = fromGlob . localizePath l $ p

    participantsDeps = depsPattern' participantsPattern

    eventsDeps = depsPattern' eventsPattern

    placesDeps = (foldr (.||.) mempty $ map (depsPattern' . placesPattern) days)

    daysDeps = depsPattern' daysPattern

    withDeps verPattern dPatterns rules  = do
      deps <- mapM makePatternDependency $ map ((.&&.) verPattern) dPatterns
      rulesExtraDependencies deps rules

    -- if separate page is not needed
    contentRules l cTpl ctxF = do
      compile $ do
        ctx <- ctxF caches hasNoVersion
        pandocCompiler
         >>= beautifyTypography
         >>= applyAsTemplate ctx
         >>= loadAndApplyTemplate cTpl ctx
         >>= saveSnapshot "content"


    pageRules l cTpl pTpl ctxF =
      markdownPageRules $ \x -> do
        ctx <- ctxF caches hasNoVersion
        beautifyTypography x
          >>= applyAsTemplate ctx
          >>= loadAndApplyTemplate cTpl ctx
          >>= saveSnapshot "content"
          >>= loadAndApplyTemplate pTpl ctx
          >>= loadAndApplyTemplate rootPageTpl ctx
          >>= loadAndApplyTemplate rootTpl ctx

    pageTxtRules l cTpl ctxF = do
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


    eventRules'' locale = do
      pageRules locale contentTemplate pageTemplate mkEventContext

      where
        contentTemplate = "templates/schedule-event-item-2019.slim"
        pageTemplate = "templates/schedule-event-page-2019.slim"


    eventTxtRules'' locale = version "txt" $ do
      pageTxtRules locale "templates/schedule-event-item-2019-txt.html" mkEventContext


    placeRules'' locale = do
      -- without separate page
      contentRules locale contentTemplate mkPlaceContext
      --pageRules locale contentTemplate pageTemplate
      where
        contentTemplate = "templates/schedule-place-item-2019.slim"

    placeTxtRules'' locale = version "txt" $ do
      pageTxtRules locale "templates/schedule-place-item-2019-txt.html" mkPlaceContext

    daysRules'' locale = do
      pageRules locale contentTemplate pageTemplate mkDayContext

      where
        contentTemplate = "templates/schedule-day-item-2019.slim"
        pageTemplate = "templates/schedule-day-page-2019.slim"

    dayTxtRules'' locale = version "txt" $ do
      pageTxtRules locale "templates/schedule-day-item-2019-txt.html" mkDayContext

    scheduleRules' locale = markdownPageRules $ \x -> do
           ctx <- (mkScheduleContext caches hasNoVersion)
           beautifyTypography x
             >>= applyAsTemplate ctx
             >>= loadAndApplyTemplate "templates/schedule-2019.slim" ctx
             >>= loadAndApplyTemplate rootPageTpl ctx
             >>= loadAndApplyTemplate rootTpl ctx
