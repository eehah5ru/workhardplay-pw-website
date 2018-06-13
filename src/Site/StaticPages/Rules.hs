{-# LANGUAGE OverloadedStrings #-}

module Site.StaticPages.Rules where

import W7W.Rules.StaticPages

import Site.Template
import Site.Context

staticPagesRules = do
  rulesIndex "index.md"
  rulesAbout "about.md"
  rulesSlim "2018/index.slim"
  rulesSlim "2017/index.slim"
  rulesSlim "2017/404.slim"
  rulesSlim "2016/index.slim"
  where
    rulesSlim = staticSlimPageRules rootTpl (Just rootPageTpl) Nothing siteCtx
    rulesAbout = staticPandocPageRules rootTpl (Just rootPageTpl) (Just "templates/about.slim") siteCtx
    rulesIndex = staticPandocPageRules rootTpl (Just rootPageTpl) (Just "templates/index.slim") siteCtx
