{-# LANGUAGE OverloadedStrings #-}
module Site.Context where

import Hakyll

import Site.MultiLang

siteCtx :: Context String
siteCtx = ruUrlField `mappend`
          enUrlField `mappend`
          defaultContext
