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

  withDeps [participantsDeps] $ matchMultiLang eventRules'' eventRules'' (eventsPattern)

  withDeps [participantsDeps, eventsDeps] $ do
    matchMultiLang placeRules'' placeRules'' (placesPattern "all-days")
    matchMultiLang placeRules'' placeRules'' (placesPattern "monday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "tuesday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "wednesday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "thursday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "friday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "saturday")
    matchMultiLang placeRules'' placeRules'' (placesPattern "sunday")

  withDeps [participantsDeps, eventsDeps, placesDeps] $ matchMultiLang daysRules'' daysRules'' daysPattern

  withDeps [participantsDeps, eventsDeps, placesDeps, daysDeps] $ matchMultiLang scheduleRules' scheduleRules' schedulePattern

  where

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

    withDeps dPatterns rules  = do
      deps <- mapM makePatternDependency dPatterns
      rulesExtraDependencies deps rules

    -- if separate page is not needed
    contentRules l cTpl ctxF = do
      compile $ do
        ctx <- ctxF caches
        pandocCompiler
         >>= beautifyTypography
         >>= applyAsTemplate ctx
         >>= loadAndApplyTemplate cTpl ctx
         >>= saveSnapshot "content"


    pageRules l cTpl pTpl ctxF =
      markdownPageRules $ \x -> do
        ctx <- ctxF caches
        beautifyTypography x
          >>= applyAsTemplate ctx
          >>= loadAndApplyTemplate cTpl ctx
          >>= saveSnapshot "content"
          >>= loadAndApplyTemplate pTpl ctx
          >>= loadAndApplyTemplate rootPageTpl ctx
          >>= loadAndApplyTemplate rootTpl ctx

    participantRules'' locale = do
      compile $ do
        pandocCompiler
          >>= beautifyTypography
          >>= saveSnapshot "content"

    eventRules'' locale = do
      pageRules locale contentTemplate pageTemplate mkEventContext

      where
        contentTemplate = "templates/schedule-event-item-2019.slim"
        pageTemplate = "templates/schedule-event-page-2019.slim"

    placeRules'' locale = do
      -- without separate page
      contentRules locale contentTemplate mkPlaceContext
      --pageRules locale contentTemplate pageTemplate
      where
        contentTemplate = "templates/schedule-place-item-2019.slim"

    daysRules'' locale = do
      pageRules locale contentTemplate pageTemplate mkDayContext

      where
        contentTemplate = "templates/schedule-day-item-2019.slim"
        pageTemplate = "templates/schedule-day-page-2019.slim"


    scheduleRules' locale = markdownPageRules $ \x -> do
           ctx <- (mkScheduleContext caches)
           beautifyTypography x
             >>= applyAsTemplate ctx
             >>= loadAndApplyTemplate "templates/schedule-2019.slim" ctx
             >>= loadAndApplyTemplate rootPageTpl ctx
             >>= loadAndApplyTemplate rootTpl ctx
