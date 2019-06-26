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


loadParticipants :: Pattern -> Item a -> Compiler ([Item String])
loadParticipants v i = loadAll =<< return . ((.&&.) v) =<< participantPattern i

loadEvents :: Pattern -> Item a -> Compiler ([Item String])
loadEvents v i = do
  eP <- return . ((.&&.) v) =<< eventsPattern
  loadAllSnapshots eP "content"

  where
    eventsPattern :: Compiler Pattern
    eventsPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule" </> placeItemDay i </> placeItemPlace i </> "*.md"

    year' = maybe (error "no year in schedule context!") id . itemYear

loadDays :: Pattern -> Item a -> Compiler ([Item String])
loadDays v i = do
  dP <- return . ((.&&.) v) =<< daysPattern
  loadAllSnapshots dP "content"

  where
    daysPattern :: Compiler Pattern
    daysPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule/*.md"
    year' = maybe (error "no year in schedule context!") id . itemYear


loadPlaces :: Pattern -> Item a -> Compiler ([Item String])
loadPlaces v i = do
  pP <- return . ((.&&.) v) =<< placesPattern
  loadAllSnapshots pP "content"
  where
    placesPattern :: Compiler Pattern
    placesPattern = do
      return $ fromGlob $ itemLang i </> (year' i) </> "schedule" </> itemCanonicalName i </> "*.md"
    year' = maybe (error "no year in schedule context!") id . itemYear


mkFieldDays :: Cache.Caches -> Pattern -> Compiler (Context String)
mkFieldDays caches v = do
  ctx <- (mkDayContext caches v)
  return $ listFieldWith "days" ctx (loadDays v >=> sortByOrder)

mkFieldPlaces :: Cache.Caches -> Pattern -> Compiler (Context String)
mkFieldPlaces caches v = do
  ctx <- mkPlaceContext caches v
  return $ listFieldWith "places" ctx (loadPlaces v >=> sortByOrder)

mkFieldEvents :: Cache.Caches -> Pattern -> Compiler (Context String)
mkFieldEvents caches v = do
  ctx <- mkEventContext caches v
  return $ listFieldWith "events" ctx (loadEvents v >=> sortByOrder)

mkFieldParticipant :: Cache.Caches -> Pattern -> Compiler (Context String)
mkFieldParticipant caches v = do
  ctx <- mkParticipantContext caches
  return $ listFieldWith "participant" ctx (loadParticipants v)


fieldContent :: Context String
fieldContent = field "content" content'
  where
    content' i = loadSnapshotBody (itemIdentifier i) "content"


fieldHasPlaces :: Pattern -> Context String
fieldHasPlaces v = boolFieldM "hasPlaces" hasPlaces'
  where
    hasPlaces' i = do
      places <- loadPlaces v i
      return $ (length places) /= 0

fieldHasEvents :: Pattern -> Context String
fieldHasEvents v = boolFieldM "hasEvents" hasEvents'
  where
    hasEvents' i = do
      events <- loadEvents v i
      return $ (length events) /= 0

fieldHasParticipant :: Pattern -> Context String
fieldHasParticipant v = boolFieldM "hasParticipant" hasParticipant'
  where
    hasParticipant' i = do
      return . ((/=) 0) . length =<< loadParticipants v i

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
  return $ fieldContent <> siteCtx

mkEventContext :: Cache.Caches -> Pattern -> Compiler (Context String)
mkEventContext c v = do
  siteCtx <- mkSiteCtx c
  pF <- mkFieldParticipant c v
  return $ fieldParticipantName <> fieldHasParticipant v <> pF <> fieldContent <> siteCtx

mkPlaceContext :: Cache.Caches -> Pattern -> Compiler (Context String)
mkPlaceContext c v = do
  siteCtx <- mkSiteCtx c
  fEvents <- mkFieldEvents c v
  return $ fEvents <> fieldHasEvents v <> fieldContent <> siteCtx

mkDayContext :: Cache.Caches -> Pattern -> Compiler (Context String)
mkDayContext caches v = do
  siteCtx <- mkSiteCtx caches
  fPlaces <- mkFieldPlaces caches v
  return $ fPlaces <> fieldHasPlaces v <> fieldContent <> siteCtx

mkScheduleContext :: Cache.Caches -> Pattern -> Compiler (Context String)
mkScheduleContext caches v = do
  ctx <- (mkSiteCtx caches)
  fDays <- (mkFieldDays caches v)
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


hasTxtVersion = hasVersion "txt"
