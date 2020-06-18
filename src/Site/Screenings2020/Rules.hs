{-# LANGUAGE OverloadedStrings #-}

module Site.Screenings2020.Rules where

import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))

import Control.Monad.Trans.Class
import Control.Monad.Reader

import qualified W7W.Cache as Cache


import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography

import W7W.ManyPages
import qualified W7W.ManyPages.Config as MPC
import qualified W7W.ManyPages.Rules as MPR

import qualified W7W.Cache as Cache

import Site.Template
import Site.Context

import W7W.Labels.Types

-- import Site.Invitation2020.Compiler
-- import Site.Invitation2020.Context


--
-- renderers
--
renderScreeningsPage ctx x = do
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/screenings-2020.slim" ctx
  >>= loadAndApplyTemplate rootPageTpl ctx
  >>= loadAndApplyTemplate rootTpl ctx

renderScreeningsItems ctx letters = do
  tpl <- loadBody "templates/screening-2020-item.slim"
  applyTemplateList tpl ctx letters


renderScreeningPage ctx x = do
  applyAsTemplate ctx x
    >>= loadAndApplyTemplate "templates/screening-2020-page.slim" ctx
    >>= saveSnapshot "content"
    >>= loadAndApplyTemplate rootTpl ctx


--
-- config
--
-- screeningsConfig :: Cache.Caches -> MPC.Config
screeningsConfig c =
  MPC.Config { MPC.indexPagePath = MPC.IndexPagePath "2020/screenings.md"
             , MPC.pagesPattern = MPC.PagesPattern "2020/screenings/*.md"
             , MPC.ctxPagesFieldName = MPC.CtxPagesFieldName "screenings"
             , MPC.rendererIndexPage = renderScreeningsPage
             , MPC.rendererPagesList = renderScreeningsItems
             , MPC.rendererOnePage = renderScreeningPage
             , MPC.pageCtxFields = return mempty
             , MPC.cache = fst c
             , MPC.labels = snd c
             }


-- screenings2020Rules :: Cache.Caches -> Rules ()
screenings2020Rules c =
  MPR.indexPageRules (screeningsConfig c)

-- screening2020PageRules :: Cache.Caches -> Rules ()
screening2020PageRules c =
  MPR.pageRules (screeningsConfig c)
  -- caches <- asks MPC.cache

  -- lift $ matchMultiLang (rules' caches) (rules' caches) "2020/invitation/*.md"

  -- where
  --   rules' caches locale =
  --     markdownPageRules $ \x -> do
  --       ctx <- mkInvitationLetterCtx caches
  --       renderLetterPage ctx x
