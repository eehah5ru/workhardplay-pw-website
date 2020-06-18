{-# LANGUAGE OverloadedStrings #-}

module Site.ParticipantsNg.Context where

import Hakyll

import Control.Monad.Error.Class (throwError)

import Control.Monad.Trans.Class
import Control.Monad.Reader

import W7W.MonadCompiler

import qualified W7W.Cache as Cache
import W7W.Context
import W7W.MultiLang
import W7W.Utils
import W7W.HasVersion
import W7W.Labels.Types

import Site.ParticipantsNg.Types
import Site.Context
import Site.Util

participantPattern :: (MonadCompiler m) => Item a -> m (Maybe Pattern)
participantPattern i = do
  pId <- maybeParticipantId i
  return $ pId >>= formatPattern
  where
    formatPattern pId = return $ fromGlob . localizePath (itemLocale i) $ ((year' i) ++ "/participants/" ++ pId ++ ".md")
    -- FIXME: replace with non-errror logic creating for example non-existing participant. undisclosed or so
    -- e' i = error $ "unresolved participantID for " ++ (itemCanonicalName i)
    year' = maybe "3000" id . itemYear

    maybeParticipantId i = do
      liftCompiler $ getMetadataField (itemIdentifier i) "participantId"

participantIdentifier i = do
  pP <- participantPattern i

  return (return . flip fromCapture "" =<< pP)

hasParticipant i = do
  return . ((/=) 0) . length =<< loadParticipants DefaultVersion i


maybeParticipantName i = do
  pId <- participantIdentifier i
  case pId of
    Just anId -> getMetadataField  anId "title"
    Nothing -> return Nothing

participantName i = do
  pId <- participantIdentifier i
  return . maybe (e' i) id =<< maybeParticipantName i

  where
    e' i = error $ "error getting participant name for " ++ (itemCanonicalName i)


loadParticipant :: (MonadCompiler m) => Item a -> m (Item String)
loadParticipant i = do
  mPI <- participantIdentifier i
  case mPI of
    Just pI -> liftCompiler $ load pI
    Nothing -> liftCompiler $ throwError $ ["error loading participant for " ++ (itemCanonicalName i)]

loadParticipants :: (MonadCompiler m) => Version -> Item a -> m ([Item String])
loadParticipants v i = do
  mPP <- participantPattern i
  case mPP of
    Just pP -> liftCompiler $ loadAll =<< return . ((.&&.) (toVersionPattern v)) =<< return pP
    Nothing -> return []

--
--
-- fields
--
--

--
-- field hasParticipant predicate
--
fieldHasParticipant ::  Context String
fieldHasParticipant = boolFieldM "hasParticipant" hasParticipant

--
-- field participant's name
--
fieldParticipantName :: Context String
fieldParticipantName = field "participantName" participantName

--
-- participant field
--
mkFieldParticipant :: (MonadReader r m, MonadCompiler m, Cache.HasCache r, HasVersion r, HasLabels r) => m (Context String)
mkFieldParticipant  = do
  ctx <- mkParticipantContext
  v <- asks getVersion
  return $ listFieldWith "participant" ctx (loadParticipants v)

--
-- context
--
mkParticipantContext :: (MonadReader r m, MonadCompiler m, Cache.HasCache r, HasLabels r) => m (Context String)
mkParticipantContext = do
  sCtx <- siteCtx
  return $ fieldContent <> sCtx
