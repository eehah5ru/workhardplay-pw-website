{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleContexts #-}
module Site.Schedule.Rules where
import Data.String
import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))
import Control.Monad.Trans.Class
import Control.Monad.Reader

import qualified W7W.Cache as Cache

import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography
import W7W.HasVersion

import qualified W7W.Cache as Cache

import Site.Template
import Site.Context
import Site.Schedule.Context
import Site.Schedule.Config hiding (version)
import qualified Site.Schedule.Config as Cfg
import Site.Util
import Site.ParticipantsNg


scheduleRules :: Config -> Rules ()
scheduleRules cfg = do
  execScheduleEnv (cfg{Cfg.version = DefaultVersion}) wholeScheduleRules
  execScheduleEnv (cfg{Cfg.version = TxtVersion}) wholeScheduleRules

wholeScheduleRules :: ScheduleEnv Rules ()
wholeScheduleRules = do
  cfg <- ask
  year <- asks year
  v <- asks Cfg.version
  days <- asks Cfg.days

  placesDeps' <- placesDeps

  --
  -- event html rules
  --
  lift $ withVersionedDeps v [participantsDeps year] $ matchMultiLang (eventRules' cfg) (eventRules' cfg) (eventsPattern year)

  --
  -- places html rules
  --
  lift $ flip mapM_ days $ \d -> withVersionedDeps v [participantsDeps year, eventsDeps year] $ matchMultiLang (placeRules' cfg) (placeRules' cfg) (placesPattern year d)

  --
  -- days html rules
  --
  lift $ withVersionedDeps v [participantsDeps year, eventsDeps year, placesDeps'] $ matchMultiLang (dayRules' cfg) (dayRules' cfg) (daysPattern year)

  --
  -- schedule html rules
  --
  when (v == DefaultVersion) $
    lift $ withVersionedDeps v [(participantsDeps year), (eventsDeps year), (placesDeps'), (daysDeps year)] $ matchMultiLang (scheduleRules' cfg) (scheduleRules' cfg) (schedulePattern year)

  where
    execRules :: (Locale -> ScheduleEnv Rules ()) -> (Locale -> ScheduleEnv Rules ()) -> Config -> (Locale -> Rules ())
    execRules htmlRules _ c@(Config{Cfg.version=DefaultVersion}) = execScheduleEnv c . htmlRules
    execRules _ txtRules c  = execScheduleEnv c . txtRules

    eventRules' :: Config -> (Locale -> Rules ())
    eventRules' = execRules eventHtmlRules eventTxtRules

    placeRules' = execRules placeHtmlRules placeTxtRules

    dayRules' = execRules dayHtmlRules dayTxtRules

    scheduleRules' = execRules scheduleHtmlRules (error "there is no txt rules for shcedule")


-- txtWholeScheduleRules :: ScheduleEnv Rules ()
-- txtWholeScheduleRules = do
--   cfg <- ask
--   year <- asks year
--   days <- asks Cfg.days
--   v <- asks Cfg.version

--   --
--   -- event txt rules
--   --
--   lift $ withVersionedDeps v [participantsDeps year] $ matchMultiLang (execScheduleEnv cfg . eventTxtRules'') (execScheduleEnv cfg . eventTxtRules'') (eventsPattern year)

--   --
--   -- places txt rules
--   --
--   lift $ flip mapM_ days $ \(Day d) -> withVersionedDeps v [participantsDeps year, eventsDeps year] $ matchMultiLang (execScheduleEnv cfg . placeTxtRules'') (execScheduleEnv cfg . placeTxtRules'') (placesPattern year d)

--   --
--   -- days txt rules
--   --
--   lift $ withVersionedDeps v [(participantsDeps year), (eventsDeps year), (placesDeps year)] $ matchMultiLang (execScheduleEnv cfg . dayTxtRules) (execScheduleEnv cfg . dayTxtRules) (daysPattern year)

-- wholeScheduleRules :: ScheduleEnv Rules ()
-- wholeScheduleRules = do
--   cfg <- ask
--   year <- asks year

-- days = [ "all-days"
--        , "monday"
--        , "tuesday"
--        , "wednesday"
--        , "thursday"
--        , "friday"
--        , "saturday"
--        , "sunday" ]

schedulePattern year = (unYear year) </> "schedule.md"

daysPattern year = (unYear year) </> "schedule/*.md"

placesPattern year d = (unYear year) </> "schedule" </> (unDay d) </> "*.md"

eventsPattern year = (unYear year) </> "schedule/*/*/*.md"

-- rawContentCompiler l =
--    getResourceBody >>= saveSnapshot "raw_content"



eventsDeps year = multilangDepsPattern (eventsPattern year)

placesDeps :: (MonadReader Config m) => m Pattern
placesDeps = do
  year <- asks year
  days <- asks days
  return $ (foldr (.||.) mempty $ map (multilangDepsPattern . placesPattern year) days)

daysDeps year = multilangDepsPattern (daysPattern year)

-- if separate page is not needed
contentRules:: Locale -> Identifier -> ScheduleEnv Compiler (Context String) -> ScheduleEnv Rules ()
contentRules l cTpl ctxF = do
  cfg <- ask
  lift $ compile $ execScheduleEnv cfg $ do
    ctx <- ctxF
    lift $ getResourceBody
     >>= applyAsTemplate ctx
     >>= customRenderPandoc
     >>= beautifyTypography
     >>= loadAndApplyTemplate cTpl ctx
     >>= saveSnapshot "content"

pageHtmlRules :: Locale -> Identifier -> Identifier -> ScheduleEnv Compiler (Context String) -> ScheduleEnv Rules ()
pageHtmlRules l cTpl pTpl ctxF = do
  cfg <- ask
  lift $ markdownPageRules $ \x -> execScheduleEnv cfg $ do
    ctx <- ctxF
    lift $ beautifyTypography x
      >>= applyAsTemplate ctx
      >>= loadAndApplyTemplate cTpl ctx
      >>= saveSnapshot "content"
      >>= loadAndApplyTemplate pTpl ctx
      >>= loadAndApplyTemplate rootPageTpl ctx
      >>= loadAndApplyTemplate rootTpl ctx

pageTxtRules :: Locale -> Identifier -> ScheduleEnv Compiler (Context String) -> ScheduleEnv Rules ()
pageTxtRules l cTpl ctxF = do
  cfg <- ask

  lift . route . setExtension $ "txt"
  lift $ compile . execScheduleEnv cfg $ do
    ctx <- ctxF
    lift $ getResourceBody
      >>= applyAsTemplate ctx
      >>= loadAndApplyTemplate cTpl ctx
      >>= saveSnapshot "content"


eventHtmlRules :: Locale -> ScheduleEnv Rules ()
eventHtmlRules locale = do
  year <- asks year
  cfg <- ask
  pageHtmlRules locale (contentTemplate year) (pageTemplate year) (mkEventContext)

  where
    contentTemplate (Year y) = fromFilePath $ "templates/schedule-event-item-" ++ y ++ ".slim"
    pageTemplate (Year y) = fromFilePath $ "templates/schedule-event-page-" ++ y ++ ".slim"


eventTxtRules :: Locale -> ScheduleEnv Rules ()
eventTxtRules locale = do
  v <- asks Cfg.version
  cfg <- ask
  year <- asks year
  lift . rulesWithVersion v . execScheduleEnv cfg $ do
    pageTxtRules locale (contentTemplate year) mkEventContext

  where
    contentTemplate (Year y) = fromFilePath $ "templates/schedule-event-item-" ++ y ++ "-txt.html"

placeHtmlRules :: Locale -> ScheduleEnv Rules ()
placeHtmlRules locale = do
  year <- asks year
  -- without separate page
  contentRules locale (contentTemplate year) mkPlaceContext
  --pageRules locale contentTemplate pageTemplate
  where
    contentTemplate (Year y) = fromFilePath $ "templates/schedule-place-item-" ++ y ++ ".slim"

placeTxtRules :: Locale -> ScheduleEnv Rules ()
placeTxtRules locale = do
  v <- asks Cfg.version
  cfg <- ask
  lift . rulesWithVersion v . execScheduleEnv cfg $ do
    year <- asks year
    pageTxtRules locale (contectTemplate year) mkPlaceContext
  where
    contectTemplate (Year y) = fromFilePath $ "templates/schedule-place-item-" ++ y ++ "-txt.html"

dayHtmlRules :: Locale -> ScheduleEnv Rules ()
dayHtmlRules locale = do
  year <- asks year
  pageHtmlRules locale (contentTemplate year) (pageTemplate year) mkDayContext

  where
    contentTemplate (Year y) = fromFilePath $ "templates/schedule-day-item-" ++ y ++ ".slim"
    pageTemplate (Year y) = fromFilePath $ "templates/schedule-day-page-" ++ y ++".slim"

dayTxtRules :: Locale -> ScheduleEnv Rules ()
dayTxtRules locale = do
  v <- asks Cfg.version
  cfg <- ask
  lift . rulesWithVersion v . execScheduleEnv cfg $ do
    year <- asks year
    pageTxtRules locale (contentTemplate year) mkDayContext

  where
    contentTemplate (Year y) = fromFilePath $ "templates/schedule-day-item-" ++ y ++ "-txt.html"

scheduleHtmlRules :: Locale -> ScheduleEnv Rules ()
scheduleHtmlRules locale = do
  year <- asks year
  pageHtmlRules locale (contentTemplate year) (pageTemplate year) mkScheduleContext
  where
    contentTemplate (Year y) = fromFilePath $ "templates/schedule-item-" ++ y ++ ".slim"
    pageTemplate (Year y) = fromFilePath $ "templates/schedule-" ++ y ++ ".slim"
