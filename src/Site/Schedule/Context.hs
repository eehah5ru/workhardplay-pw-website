{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
module Site.Schedule.Context where

import           Control.Monad                   (foldM, forM, forM_, mplus, guard, when, (>=>))
import Control.Applicative ((<|>))
import Control.Monad.Error.Class (throwError)
import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Data.Tuple.Utils
import           Control.Monad               (liftM)
import           Data.List                   (intersperse, sortBy)
import           Data.Ord                    (comparing)

import Control.Monad.Trans.Class
import Control.Monad.Reader


import System.FilePath.Posix ((</>))

import Hakyll

import W7W.MonadCompiler
import W7W.HasVersion

import qualified W7W.Cache as Cache


import Site.Context
import W7W.Context
import W7W.MultiLang
import W7W.Utils
import Site.Util

import Site.Schedule.Config hiding (version)
import qualified Site.Schedule.Config as Cfg

import Site.ParticipantsNg.Context

placeItemPlace :: Item a -> String
placeItemPlace = itemCanonicalName

placeItemDay :: Item a -> String
placeItemDay = head . tail . reverse . itemPathParts


loadEvents :: Version -> Item a -> Compiler ([Item String])
loadEvents v i = do
  eP <- return . ((.&&.) (toVersionPattern v)) =<< eventsPattern
  loadAllSnapshots eP "content"

  where
    eventsPattern :: Compiler Pattern
    eventsPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule" </> placeItemDay i </> placeItemPlace i </> "*.md"

    year' = maybe (error "no year in schedule context!") id . itemYear

loadDays :: Version -> Item a -> Compiler ([Item String])
loadDays v i = do
  dP <- return . ((.&&.) (toVersionPattern v)) =<< daysPattern
  loadAllSnapshots dP "content"

  where
    daysPattern :: Compiler Pattern
    daysPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule/*.md"
    year' = maybe (error "no year in schedule context!") id . itemYear


loadPlaces :: Version -> Item a -> Compiler ([Item String])
loadPlaces v i = do
  pP <- return . ((.&&.) (toVersionPattern v)) =<< placesPattern
  loadAllSnapshots pP "content"
  where
    placesPattern :: Compiler Pattern
    placesPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule" </> itemCanonicalName i </> "*.md"
    year' = maybe (error "no year in schedule context!") id . itemYear

loadSchedules :: Version -> Item a -> Compiler ([Item String])
loadSchedules v i = do
  sP <- return . ((.&&.) (toVersionPattern v)) =<< schedulePattern
  loadAllSnapshots sP "content"

  where
    year' = maybe (error "no year in schedule context!") id . itemYear

    schedulePattern :: Compiler Pattern
    schedulePattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule.md"


mkFieldDays :: ScheduleEnv Compiler (Context String)
mkFieldDays = do
  ctx <- mkDayContext
  v <- asks Cfg.version
  return $ listFieldWith "days" ctx (loadDays v >=> sortByOrder)

mkFieldPlaces :: ScheduleEnv Compiler (Context String)
mkFieldPlaces  = do
  ctx <- mkPlaceContext
  v <- asks Cfg.version

  return $ listFieldWith "places" ctx (loadPlaces v >=> sortByOrder)

mkFieldEvents :: ScheduleEnv Compiler (Context String)
mkFieldEvents = do
  ctx <- mkEventContext
  v <- asks Cfg.version
  return $ listFieldWith "events" ctx (loadEvents v >=> sortByOrder)

mkFieldSchedule :: ScheduleEnv Compiler (Context String)
mkFieldSchedule = do
  ctx <- mkScheduleContext
  v <- asks Cfg.version
  return $ listFieldWith "schedule" ctx (loadSchedules v)

fieldHasPlaces :: Version -> Context String
fieldHasPlaces v = boolFieldM "hasPlaces" hasPlaces'
  where
    hasPlaces' i = do
      places <- loadPlaces v i
      return $ (length places) /= 0

fieldHasEvents :: Version -> Context String
fieldHasEvents v = boolFieldM "hasEvents" hasEvents'
  where
    hasEvents' i = do
      events <- loadEvents v i
      return $ (length events) /= 0

--
--
-- contexts
--
--


mkEventContext :: ScheduleEnv Compiler (Context String)
mkEventContext = do
  sCtx <- siteCtx
  pF <- mkFieldParticipant
  return $ fieldParticipantName <> fieldHasParticipant <> pF <> fieldContent <> sCtx

mkPlaceContext :: ScheduleEnv Compiler (Context String)
mkPlaceContext = do
  ctx <- siteCtx
  v <- asks Cfg.version
  fEvents <- mkFieldEvents
  return $ fEvents <> fieldHasEvents v <> fieldContent <> ctx

mkDayContext :: ScheduleEnv Compiler (Context String)
mkDayContext = do
  ctx <- siteCtx
  v <- asks Cfg.version
  fPlaces <- mkFieldPlaces
  return $ fPlaces <> fieldHasPlaces v <> fieldContent <> ctx

mkScheduleContext :: ScheduleEnv Compiler (Context String)
mkScheduleContext = do
  ctx <- siteCtx
  fDays <- mkFieldDays
  return $ fDays
    <> ctx
