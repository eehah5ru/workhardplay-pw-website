{-# LANGUAGE OverloadedStrings #-}

module Site.StaticPages.Rules where

import           Data.Monoid (mappend, (<>))

import Hakyll
import System.FilePath.Posix ((</>))

import W7W.Rules.StaticPages

import Site.Template
import Site.Context
import qualified Site.Schedule.Context as SC
import qualified Site.Schedule.Rules as SR

import qualified W7W.Cache as Cache
import W7W.MultiLang
import W7W.Utils

staticPagesRules :: Cache.Caches -> Rules ()
staticPagesRules caches = do
  rulesIndex "index.md"
  rulesAbout "about.md"
  

  --
  -- 2020
  --
  -- rulesMd "2020/invitation.md"
  rulesMd "2020/working-group.md"

  SR.withDeps hasNoVersion [(SR.participantsDeps "2020"), (SR.eventsDeps "2020"), (SR.placesDeps "2020"), (SR.daysDeps "2020")] $ rulesMd2019 "2020/index.md"

  --
  -- 2019
  --
  rulesMd "2019/invitation.md"
  rulesMd "2019/working-group.md"

  SR.withDeps hasNoVersion [(SR.participantsDeps "2019"), (SR.eventsDeps "2019"), (SR.placesDeps "2019"), (SR.daysDeps "2019")] $ rulesMd2019 "2019/index.md"

  with2018deps (rulesSlim "2018/index.slim")

  rulesSlim "2017/index.slim"
  rulesSlim "2017/404.slim"
  rulesSlim "2016/index.slim"

  where
    rulesMd = staticPandocPageRulesM rootTpl (Just rootPageTpl) Nothing (mkSiteCtx caches)
    rulesMd2019 p = do
      staticPandocPageRulesM rootTpl (Just rootPageTpl) Nothing mkCtx p
      where
        year' = maybe (error "no year in schedule context!") id . itemYear

        workingGroupPattern :: Item a -> Compiler Pattern
        workingGroupPattern i = do
          return $ fromGlob $ itemLang i </> (year' i) </> "working-group.md"

        loadWorkingGroup :: Item a -> Compiler ([Item String])
        loadWorkingGroup i = do
          wgP <- workingGroupPattern i
          loadAllSnapshots wgP "content"

        mkFieldWorkingGroup caches = do
          ctx <- mkSiteCtx caches
          return $ listFieldWith "workingGroup" ctx (loadWorkingGroup)

        mkCtx = do
          ctx <- mkSiteCtx caches
          fS <- SC.mkFieldSchedule caches hasNoVersion
          fWG <- mkFieldWorkingGroup caches
          return $ fS <> fWG <> ctx

    rulesSlim = staticSlimPageRulesM rootTpl (Just rootPageTpl) Nothing (mkSiteCtx caches)
    rulesAbout = staticPandocPageRulesM rootTpl (Just rootPageTpl) (Just "templates/about.slim") (mkSiteCtx caches)
    rulesIndex = staticPandocPageRulesM rootTpl (Just rootPageTpl) (Just "templates/index.slim") (mkSiteCtx caches)
    with2018deps rules = do
      let lDeps = \l -> (fromGlob (localizePath l "2018/shared/_*.slim"))
      deps <- makePatternDependency $ ("ru/**/_*.slim" .||. "en/**/_*.slim")
      rulesExtraDependencies [deps] rules
