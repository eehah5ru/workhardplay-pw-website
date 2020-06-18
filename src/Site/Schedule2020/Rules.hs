{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule2020.Rules
  (
    schedule2020Rules
  , config
  ) where

import Site.Schedule.Rules
import Site.Schedule.Config hiding (days)
import qualified Site.Schedule.Config as Cfg

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

config caches =
  Config { cache = caches
         , year = "2020"
         , version = DefaultVersion
         , Cfg.days = days}

schedule2020Rules caches =
  scheduleRules $ config caches
