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
import Site.Compilers.Markdown
import Site.Archive.Compilers

import Site.Archive.Utils
--
--
-- rules
--
--

--
-- index page
--
archiveIndexPagesRules = do
  matchMultiLang (rules' "ru/2016/archive/")
                 (rules' "en/2016/archive/")
                 "2016/archive.slim"
  matchMultiLang (rules' "ru/2017/projects/")
                 (rules' "en/2017/projects/")
                 "2017/archive.slim"
  where
    rules' projectsPattern =
          slimPageRules $ \x -> do
            ctx <- mkArchiveIndexPageCtx (archiveProjectsPattern projectsPattern)
            renderArchiveIndexPage pageTpl ctx x
--
-- project page
--
archiveProjectPagesRules = do
  matchMultiLang slimRules slimRules "2016/archive/*.slim"
  matchMultiLang mdRules mdRules "2016/archive/*.md"

  matchMultiLang slimRules slimRules "2017/projects/*.slim"
  matchMultiLang mdRules mdRules "2017/projects/*.md"

  where
    slimRules =
      slimPageRules $ render'
    mdRules  =
      markdownPageRules $ render'
    render' = renderArchiveProjectPage "templates/archive-2017-project.slim" pageTpl archiveProjectCtx
