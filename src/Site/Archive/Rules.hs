{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.Rules where

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)
import Control.Monad ((>=>))
import System.FilePath.Posix ((</>))

import Hakyll

import W7W.MultiLang
import W7W.Compilers.Slim
import W7W.Compilers.Markdown
import W7W.Typography

import Site.Archive.Compilers

import Site.Context
import Site.Archive.IndexContext
import Site.Archive.ProjectContext
import Site.Template


import Site.CollectiveGlossary
import Site.CollectiveGlossary.Context

import Site.Archive.Utils
--
--
-- rules
--
--

--
-- index page
--
archiveIndexPagesRules :: Terms -> Rules ()
archiveIndexPagesRules ts = do
  let rules2016 = rules' "2016/archive/"
      rules2017 = rules' "2017/projects/"
      rules2018 = rules' "2018/projects/"
  matchMultiLang rules2016
                 rules2016
                 "2016/archive.slim"
  matchMultiLang rules2017
                 rules2017
                 "2017/archive.slim"
  matchMultiLang rules2018
                 rules2018
                 "2018/archive.slim"
  where
    rules' projectsPattern locale =
          slimPageRules $ \x -> do
            ctx <- mkArchiveIndexPageCtx (terms locale ts) (archiveProjectsPattern (localizePath locale projectsPattern))
            renderArchiveIndexPage rootPageTpl ctx x


--
-- project page
--
archiveProjectPagesRules :: Terms -> Rules ()
archiveProjectPagesRules ts = do
  matchSlim "2016/archive/"
  matchMd "2016/archive/"

  matchSlim "2017/projects/"
  matchMd "2017/projects/"

  matchSlim "2018/projects/"
  matchMd "2018/projects/"

  where
    matchSlim base = matchMultiLang slimRules
                                    slimRules
                                    (base </> "*.slim")
    matchMd base = matchMultiLang mdRules
                                  mdRules
                                  (base </> "*.md")
    slimRules locale =
      slimPageRules $ render' locale
    mdRules locale  =
      markdownPageRules $ beautifyTypography >=> render' locale
    render' locale item = do
      renderArchiveProjectPage
       "templates/archive-2017-project.slim"
       rootPageTpl
       (archiveProjectCtx (terms locale ts))
       item
