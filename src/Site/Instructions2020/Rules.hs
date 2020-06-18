{-# LANGUAGE OverloadedStrings #-}

module Site.Instructions2020.Rules where

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
import Site.ParticipantsNg.Context

import Site.Context
import W7W.Context.Media
import Site.Pictures.Utils
import W7W.Pictures.Context

import W7W.Labels.Types

import W7W.Utils
import Site.Util

-- import Site.Invitation2020.Compiler
-- import Site.Invitation2020.Context


--
-- renderers
--
renderInstructionsPage ctx x = do
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/instructions-2020.slim" ctx
  >>= loadAndApplyTemplate rootPageTpl ctx
  >>= loadAndApplyTemplate rootTpl ctx

renderInstructionsItems ctx letters = do
  tpl <- loadBody "templates/instruction-2020-item.slim"
  applyTemplateList tpl ctx letters


renderInstructionPage ctx x = do
  applyAsTemplate ctx x
    >>= loadAndApplyTemplate "templates/instruction-2020-page.slim" ctx
    >>= saveSnapshot "content"
    >>= loadAndApplyTemplate rootTpl ctx


mkPageCtxFields :: MPC.CtxFields
mkPageCtxFields = do
  cs <- asks Cache.getCache
  ls <- asks getLabels
  pF <- runReaderT mkFieldParticipant (cs, ls, DefaultVersion)

  return $
    fieldParticipantName
    <> fieldHasParticipant
    <> pF
    <> fieldInstructionCover
    <> fieldHasMedia picturesPattern
    <> fieldHasVideo
    <> fieldHasAudio
    <> (fieldHasPictures picturesPattern)
    <> (fieldPictures cs picturesPattern)



  where
    fieldInstructionCover = fieldCover "instructionCover" coverPattern

--
-- config
--
-- instructionsConfig :: Cache.Caches -> MPC.Config
instructionsConfig c =
  MPC.Config { MPC.indexPagePath = MPC.IndexPagePath "2020/instructions.md"
             , MPC.pagesPattern = MPC.PagesPattern "2020/instructions/*.md"
             , MPC.ctxPagesFieldName = MPC.CtxPagesFieldName "instructionsList"
             , MPC.rendererIndexPage = renderInstructionsPage
             , MPC.rendererPagesList = renderInstructionsItems
             , MPC.rendererOnePage = renderInstructionPage
             , MPC.pageCtxFields = mkPageCtxFields
             , MPC.cache = fst c
             , MPC.labels = snd c
             }


-- instructions2020Rules :: Cache.Caches -> Rules ()
instructions2020Rules c =
  MPR.indexPageRules (instructionsConfig c)

-- instruction2020PageRules :: Cache.Caches -> Rules ()
instruction2020PageRules c =
  MPR.pageRules (instructionsConfig c)
  -- caches <- asks MPC.cache

  -- lift $ matchMultiLang (rules' caches) (rules' caches) "2020/invitation/*.md"

  -- where
  --   rules' caches locale =
  --     markdownPageRules $ \x -> do
  --       ctx <- mkInvitationLetterCtx caches
  --       renderLetterPage ctx x
