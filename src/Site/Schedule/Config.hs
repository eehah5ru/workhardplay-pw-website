{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Site.Schedule.Config where

import Data.String
import Control.Monad.Reader

import Hakyll hiding (version)

import W7W.MonadCompiler
import qualified W7W.Cache as Cache

import Site.Util

newtype Day = Day {unDay :: String} deriving (IsString)

data Config =
  Config { year :: Year
         , cache :: Cache.Caches
         , version :: Version
         , days :: [Day]
         }

instance Cache.HasCache Config where
  getCache = cache

instance HasVersion Config where
  getVersion = version

newtype ScheduleEnv m a = ScheduleEnv {unwrapScheduleEnv :: ReaderT Config m a} deriving (Functor, Applicative, Monad, MonadReader Config, MonadTrans)

execScheduleEnv c = flip runReaderT c . unwrapScheduleEnv

instance MonadCompiler (ScheduleEnv Compiler) where
  liftCompiler = lift . liftCompiler
