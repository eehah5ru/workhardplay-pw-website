{-# LANGUAGE OverloadedStrings #-}

module Site.StaticPages.Rules where

import W7W.Rules.StaticPages

import Site.Template
import Site.Context

staticPagesRules = do
  rules' "2017/index.slim"
  rules' "2017/404.slim"
  rules' "2016/index.slim"
  where
    rules' = staticSlimPageRules rootTpl pageTpl siteCtx
