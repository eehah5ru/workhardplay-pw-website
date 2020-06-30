{-# LANGUAGE OverloadedStrings #-}

module Site.Underwater2020.Rules where

import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))

import Control.Monad.Trans.Class
import Control.Monad.Reader

import qualified W7W.Cache as Cache


import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography
import W7W.MonadCompiler
import W7W.HasVersion

import W7W.ManyPages
import qualified W7W.ManyPages.Config as MPC
import qualified W7W.ManyPages.Rules as MPR

import qualified W7W.Cache as Cache

import Site.Template
import Site.Context

import W7W.Labels.Types

import Site.ParticipantsNg.Context
import W7W.Context.Media
import Site.Pictures.Utils
import W7W.Pictures.Context
import Site.Archive.ProjectContext (fieldProjectColor)
-- import Site.Invitation2020.Compiler
-- import Site.Invitation2020.Context


--
-- renderers
--

--
-- render index page
--
renderUnderwaterIndexPage ctx x = do
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/underwater-index-2020.slim" ctx
  >>= loadAndApplyTemplate rootPageTpl ctx
  >>= loadAndApplyTemplate rootTpl ctx

--
-- render page's item for index page
--
renderUnderwaterItems ctx pages = do
  tpl <- loadBody "templates/underwater-2020-item.slim"
  applyTemplateList tpl ctx pages

--
-- render whole page
--
renderUnderwaterPage ctx x = do
  applyAsTemplate ctx x
    >>= saveSnapshot "content"
    >>= loadAndApplyTemplate "templates/underwater-2020-page.slim" ctx
    >>= loadAndApplyTemplate rootPageTpl ctx
    >>= loadAndApplyTemplate rootTpl ctx

--
-- screening page context
--
-- mkPageCtxFields :: MPC.CtxFields
-- mkPageCtxFields = do
--   cs <- asks Cache.getCache
--   ls <- asks getLabels
--   pF <- runReaderT mkFieldParticipant (cs, ls, DefaultVersion)

--   return $
--     fieldParticipantName
--     <> fieldScreeningCover
--     <> fieldHasMedia picturesPattern
--     <> fieldHasVideo
--     <> fieldHasAudio
--     <> (fieldHasPictures picturesPattern)
--     <> (fieldPictures cs picturesPattern)
--     <> fieldProjectColor cs
  -- where
  --   fieldScreeningCover = fieldCover "projectCover" coverPattern


--
-- config
--
-- screeningsConfig :: Cache.Caches -> MPC.Config
underwaterConfig c =
  MPC.Config { MPC.indexPagePath = MPC.IndexPagePath "2020/underwater.md"
             , MPC.pagesPattern = MPC.PagesPattern "2020/underwater/*.md"
             , MPC.ctxPagesFieldName = MPC.CtxPagesFieldName "underwaterItems"
             , MPC.rendererIndexPage = renderUnderwaterIndexPage
             , MPC.rendererPagesList = renderUnderwaterItems
             , MPC.rendererOnePage = renderUnderwaterPage
             , MPC.pageCtxFields = return mempty
             , MPC.cache = fst c
             , MPC.labels = snd c
             }


-- screenings2020Rules :: Cache.Caches -> Rules ()
underwater2020Rules c =
  MPR.indexPageRules (underwaterConfig c)

-- screening2020PageRules :: Cache.Caches -> Rules ()
underwater2020PageRules c =
  MPR.pageRules (underwaterConfig c)
  -- caches <- asks MPC.cache

  -- lift $ matchMultiLang (rules' caches) (rules' caches) "2020/invitation/*.md"

  -- where
  --   rules' caches locale =
  --     markdownPageRules $ \x -> do
  --       ctx <- mkInvitationLetterCtx caches
  --       renderLetterPage ctx x
