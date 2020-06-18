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
import Site.Schedule.Config
import qualified Site.Schedule2020.Rules as S2020R
import qualified Site.Schedule2019.Rules as S2019R

import Site.ParticipantsNg

import W7W.HasVersion
import W7W.Labels.Types

import qualified W7W.Cache as Cache
import W7W.MultiLang
import W7W.Utils

import Site.Util
import qualified Site.Config as SiteCfg


staticPagesRules :: SiteCfg.Config -> Rules ()
staticPagesRules cfg = do  
  rulesIndex "index.md"
  rulesAbout "about.md"
  
  
  --
  -- 2020
  --
  -- rulesMd "2020/invitation.md"
  rulesMd "2020/working-group.md"

  placesDeps2020 <- execScheduleEnv (S2020R.config cfg) SR.placesDeps

  withVersionedDeps DefaultVersion [(participantsDeps "2020"), (SR.eventsDeps "2020"), (placesDeps2020), (SR.daysDeps "2020")] $ rulesMd' (S2020R.config cfg) "2020/index.md"

  --
  -- 2019
  --
  rulesMd "2019/invitation.md"
  rulesMd "2019/working-group.md"

  placesDeps2019 <- execScheduleEnv (S2019R.config cfg) SR.placesDeps

  withVersionedDeps DefaultVersion [(participantsDeps "2019"), (SR.eventsDeps "2019"), (placesDeps2019), (SR.daysDeps "2019")] $ rulesMd' (S2019R.config cfg) "2019/index.md"

  with2018deps (rulesSlim "2018/index.slim")

  rulesSlim "2017/index.slim"
  rulesSlim "2017/404.slim"
  rulesSlim "2016/index.slim"

  where
    rulesMd = staticPandocPageRulesM rootTpl (Just rootPageTpl) Nothing (mkSiteCtx (fst cfg) (snd cfg))
    -- 2019-now markdown rules
    rulesMd' cfg' p = do
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

        mkFieldWorkingGroup cfg = do
          ctx <- mkSiteCtx (fst cfg) (snd cfg)
          return $ listFieldWith "workingGroup" ctx (loadWorkingGroup)

        mkCtx = do
          ctx <- mkSiteCtx (fst cfg) (snd cfg)
          fS <- execScheduleEnv cfg' $ SC.mkFieldSchedule
          fWG <- mkFieldWorkingGroup cfg
          return $ fS <> fWG <> ctx

    rulesSlim = staticSlimPageRulesM rootTpl (Just rootPageTpl) Nothing (mkSiteCtx (fst cfg) (snd cfg))
    rulesAbout = staticPandocPageRulesM rootTpl (Just rootPageTpl) (Just "templates/about.slim") (mkSiteCtx (fst cfg) (snd cfg))
    rulesIndex = staticPandocPageRulesM rootTpl (Just rootPageTpl) (Just "templates/index.slim") (mkSiteCtx (fst cfg) (snd cfg))
    with2018deps rules = do
      let lDeps = \l -> (fromGlob (localizePath l "2018/shared/_*.slim"))
      deps <- makePatternDependency $ ("ru/**/_*.slim" .||. "en/**/_*.slim")
      rulesExtraDependencies [deps] rules
