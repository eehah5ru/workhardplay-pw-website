{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule2019.Rules
  (
    schedule2019Rules
  , config
  ) where

import W7W.HasVersion

import Site.Schedule.Rules
import Site.Schedule.Config hiding (days)
import qualified Site.Schedule.Config as Cfg

import Site.Util

days =
       [ "all-days"
       , "monday"
       , "tuesday"
       , "wednesday"
       , "thursday"
       , "friday"
       , "saturday"
       , "sunday" ]

config cfg =
  Config { cache = fst cfg
         , year = "2019"
         , version = DefaultVersion
         , Cfg.days = days
         , labels = snd cfg
         , scheduleCtxFields = return mempty}

schedule2019Rules cfg =
  scheduleRules $ config cfg
