{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.Rules where

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)

import Hakyll

import Site.Context
import Site.Archive.IndexContext
import Site.Archive.ProjectContext
import Site.MultiLang
import Site.Template

import Site.Compilers.Slim
import Site.Archive.Compilers

--
--
-- rules
--
--
archiveIndexPagesRules = do
  matchMultiLang (ruRules "ru/2016/archive/*.slim")
                 (enRules "en/2016/archive/*.slim")
                 "2016/archive.slim"
  matchMultiLang (ruRules "ru/2017/projects/*.slim")
                 (enRules "en/2017/projects/*.slim")
                 "2017/archive.slim"
  where
    localizedRules pageTpl projectsPattern =
          slimPageRules $ \x -> do
            ctx <- mkArchiveIndexPageCtx projectsPattern
            renderArchiveIndexPage pageTpl ctx x
    ruRules = localizedRules ruPageTpl
    enRules = localizedRules enPageTpl


archiveProjectPagesRules = do
  matchMultiLang ruRules enRules "2016/archive/*.slim"
  matchMultiLang ruRules enRules "2017/projects/*.slim"
  where
    localizedRules projectTpl pageTpl =
        slimPageRules $ renderArchiveProjectPage projectTpl pageTpl archiveProjectCtx
    ruRules = localizedRules "templates/archive-2017-project.slim"
                                 ruPageTpl

    enRules = localizedRules "templates/archive-2017-project.slim"
                                 enPageTpl
