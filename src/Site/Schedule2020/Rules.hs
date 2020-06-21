{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule2020.Rules
  (
    schedule2020Rules
  , config
  ) where

import Control.Monad.Reader

import W7W.HasVersion
import W7W.MonadCompiler

import Site.Schedule.Rules
import Site.Schedule.Config hiding (days)
import qualified Site.Schedule.Config as Cfg

import Site.Invitation2020.Rules (invitationsConfig)
import W7W.ManyPages.Context (mkPagesField)
import W7W.ManyPages.Config (execManyPages)

import Site.Util

days =
       [ "all-days"
       , "monday-06-22"
       , "tuesday-06-23"
       , "wednesday-06-24"
       , "thursday-06-25"
       , "friday-06-26"
       , "saturday-06-27"
       , "sunday-06-28"
       , "monday-06-29"
       , "tuesday-06-30"
       , "wednesday-07-01"]

mkScheduleCtxFields :: CtxFields
mkScheduleCtxFields = do
  iCfg <- return . invitationsConfig =<< ask
  liftCompiler . execManyPages iCfg $ mkPagesField

config cfg =
  Config { cache = fst cfg
         , year = "2020"
         , version = DefaultVersion
         , Cfg.days = days
         , labels = snd cfg
         , scheduleCtxFields = mkScheduleCtxFields}

schedule2020Rules cfg =
  scheduleRules $ config cfg
