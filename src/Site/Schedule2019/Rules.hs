{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule2019.Rules
  (
    schedule2019Rules
  , config
  ) where

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

config caches =
  Config { cache = caches
         , year = "2019"
         , version = DefaultVersion
         , Cfg.days = days}

schedule2019Rules caches =
  scheduleRules $ config caches
