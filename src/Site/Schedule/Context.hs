{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
module Site.Schedule.Context where

import           Control.Monad                   (foldM, forM, forM_, mplus, guard, when, (>=>))
import Control.Applicative ((<|>))
import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Data.Tuple.Utils
import           Control.Monad               (liftM)
import           Data.List                   (intersperse, sortBy)
import           Data.Ord                    (comparing)

import System.FilePath.Posix ((</>))

import Hakyll

import qualified W7W.Cache as Cache

import Site.Context
import W7W.Context
import W7W.MultiLang
import W7W.Utils

placeItemPlace :: Item a -> String
placeItemPlace = itemCanonicalName

placeItemDay :: Item a -> String
placeItemDay = head . tail . reverse . itemPathParts


participantPattern :: Item a -> Compiler (Pattern)
participantPattern i = do
  pId <- getParticipantId i
  return $ fromGlob . localizePath (itemLocale i) $ ((year' i) ++ "/participants/" ++ pId ++ ".md")
  where
    -- FIXME: replace with non-errror logic creating for example non-existing participant. undisclosed or so
    e' i = error $ "unresolved participantID fo event " ++ (itemCanonicalName i)
    year' = maybe "3000" id . itemYear
    getParticipantId i = do
      return . maybe (e' i) id =<< getMetadataField (itemIdentifier i) "participantId"

participantIdentifier i = do
  return . flip fromCapture "" =<< participantPattern i

loadParticipant :: Item a -> Compiler (Item String)
loadParticipant i = load =<< participantIdentifier i


loadParticipants :: Item a -> Compiler ([Item String])
loadParticipants i = loadAll =<< participantPattern i

loadEvents :: Item a -> Compiler ([Item String])
loadEvents i = do
  eventsPattern >>= loadAll
  where
    eventsPattern :: Compiler Pattern
    eventsPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule" </> placeItemDay i </> placeItemPlace i </> "*.md"

    year' = maybe (error "no year in schedule context!") id . itemYear

loadDays :: Item a -> Compiler ([Item String])
loadDays i = do
  daysPattern >>= loadAll
  where
    daysPattern :: Compiler Pattern
    daysPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule/*.md"
    year' = maybe (error "no year in schedule context!") id . itemYear

loadPlaces :: Item a -> Compiler ([Item String])
loadPlaces i = do
  placesPattern >>= loadAll
  where
    placesPattern :: Compiler Pattern
    placesPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule" </> itemCanonicalName i </> "*.md"
    year' = maybe (error "no year in schedule context!") id . itemYear

mkFieldDays :: Cache.Caches -> Compiler (Context String)
mkFieldDays caches = do
  ctx <- (mkDayContext caches)
  return $ listFieldWith "days" ctx (loadDays >=> sortByOrder)

mkFieldPlaces :: Cache.Caches -> Compiler (Context String)
mkFieldPlaces caches = do
  ctx <- mkPlaceContext caches
  return $ listFieldWith "places" ctx loadPlaces

mkFieldEvents :: Cache.Caches -> Compiler (Context String)
mkFieldEvents caches = do
  ctx <- mkEventContext caches
  return $ listFieldWith "events" ctx loadEvents

mkFieldParticipant :: Cache.Caches -> Compiler (Context String)
mkFieldParticipant caches = do
  ctx <- mkParticipantContext caches
  return $ listFieldWith "participant" ctx loadParticipants

fieldHasPlaces :: Context String
fieldHasPlaces = boolFieldM "hasPlaces" hasPlaces'
  where
    hasPlaces' i = do
      places <- loadPlaces i
      return $ (length places) /= 0

fieldHasEvents :: Context String
fieldHasEvents = boolFieldM "hasEvents" hasEvents'
  where
    hasEvents' i = do
      events <- loadEvents i
      return $ (length events) /= 0

fieldHasParticipant :: Context String
fieldHasParticipant = boolFieldM "hasParticipant" hasParticipant'
  where
    hasParticipant' i = do
      return . ((/=) 0) . length =<< loadParticipants i

fieldParticipantName :: Context String
fieldParticipantName = field "participantName" participantName'
  where
    e' i = error $ "error getting participant name for " ++ (itemCanonicalName i)
    participantName' i = do
      pId <- participantIdentifier i
      return . maybe (e' i) id =<< getMetadataField pId "title"

mkParticipantContext :: Cache.Caches -> Compiler (Context String)
mkParticipantContext c = do
  siteCtx <- mkSiteCtx c
  return $ siteCtx

mkEventContext :: Cache.Caches -> Compiler (Context String)
mkEventContext c = do
  siteCtx <- mkSiteCtx c
  pF <- mkFieldParticipant c
  return $ fieldParticipantName <> fieldHasParticipant <> pF <> siteCtx

mkPlaceContext :: Cache.Caches -> Compiler (Context String)
mkPlaceContext c = do
  siteCtx <- mkSiteCtx c
  fEvents <- mkFieldEvents c
  return $ fEvents <> fieldHasEvents <> siteCtx

mkDayContext :: Cache.Caches -> Compiler (Context String)
mkDayContext caches = do
  siteCtx <- mkSiteCtx caches
  fPlaces <- mkFieldPlaces caches
  return $ fPlaces <> fieldHasPlaces <> siteCtx

mkScheduleContext :: Cache.Caches -> Compiler (Context String)
mkScheduleContext caches = do
  ctx <- (mkSiteCtx caches)
  fDays <- (mkFieldDays caches)
  return $ fDays
    <> ctx


sortByOrder :: MonadMetadata m => [Item a] -> m [Item a]
sortByOrder =
  sortByM $ order'

  where
    order' = withItemMetadata $ getOrder

    getOrder :: Metadata -> String
    getOrder m =
      maybe "9999" id (lookupString "order" m)

    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = liftM (map fst . sortBy (comparing snd)) $
                   mapM (\x -> liftM (x,) (f x)) xs
