{-# LANGUAGE OverloadedStrings #-}

module Site.StaticPages.Rules where

import           Data.Monoid (mappend, (<>))

import Hakyll

import W7W.MultiLang

import W7W.Rules.StaticPages

import Site.Template
import Site.Context

import qualified W7W.Cache as Cache

staticPagesRules :: Cache.Caches -> Rules ()
staticPagesRules caches = do
  rulesIndex "index.md"
  rulesAbout "about.md"
  with2018deps (rulesSlim "2018/index.slim")

    --
  -- 2019
  --
  rulesMd "2019/invitation.md"
  rulesMd "2019/index.md"

  rulesSlim "2017/index.slim"
  rulesSlim "2017/404.slim"
  rulesSlim "2016/index.slim"
  where
    rulesMd = staticPandocPageRulesM rootTpl (Just rootPageTpl) Nothing (mkSiteCtx caches)
    rulesSlim = staticSlimPageRulesM rootTpl (Just rootPageTpl) Nothing (mkSiteCtx caches)
    rulesAbout = staticPandocPageRulesM rootTpl (Just rootPageTpl) (Just "templates/about.slim") (mkSiteCtx caches)
    rulesIndex = staticPandocPageRulesM rootTpl (Just rootPageTpl) (Just "templates/index.slim") (mkSiteCtx caches)
    with2018deps rules = do
      let lDeps = \l -> (fromGlob (localizePath l "2018/shared/_*.slim"))
      deps <- makePatternDependency $ ("ru/**/_*.slim" .||. "en/**/_*.slim")
      rulesExtraDependencies [deps] rules
