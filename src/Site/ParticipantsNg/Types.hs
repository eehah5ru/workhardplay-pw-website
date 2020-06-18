{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Site.ParticipantsNg.Types where

import Data.String
import Control.Monad.Reader

import Hakyll hiding (version)

import qualified W7W.Cache as Cache
import W7W.MonadCompiler

import W7W.HasVersion
import W7W.Labels.Types

import Site.Util


data Config =
  Config { cache :: Cache.Caches
         , version :: Version
         , labels :: Labels
         }


newtype ParticipantsEnv m a = ParticipantsEnv {unwrapParticipantsEnv :: ReaderT Config m a} deriving (Functor, Applicative, Monad, MonadReader Config, MonadTrans)

execParticipantsEnv c = flip runReaderT c . unwrapParticipantsEnv


instance MonadCompiler (ParticipantsEnv Compiler) where
  liftCompiler = lift . liftCompiler

instance Cache.HasCache Config where
  getCache = cache

instance HasVersion Config where
  getVersion = version

instance HasLabels Config where
  getLabels = labels
