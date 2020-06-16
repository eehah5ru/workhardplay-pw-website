{-# LANGUAGE OverloadedStrings #-}

module Site.Invitation2020.Rules where

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

import Site.Invitation2020.Compiler
import Site.Invitation2020.Context

invitationsConfig :: Cache.Caches -> MPC.Config
invitationsConfig c =
  MPC.Config { MPC.indexPagePath = MPC.IndexPagePath "2020/invitation.md"
             , MPC.pagesPattern = MPC.PagesPattern "2020/invitation/*.md"
             , MPC.ctxPagesFieldName = MPC.CtxPagesFieldName "invitationLetters"
             , MPC.rendererIndexPage = renderInvitationPage
             , MPC.rendererPagesList = renderLetters
             , MPC.rendererOnePage = renderLetterPage
             , MPC.cache = c
             }


invitation2020Rules :: Cache.Caches -> Rules ()
invitation2020Rules c =
  MPR.indexPageRules (invitationsConfig c)

invitation2020LetterRules :: Cache.Caches -> Rules ()
invitation2020LetterRules c =
  MPR.pageRules (invitationsConfig c)
  -- caches <- asks MPC.cache

  -- lift $ matchMultiLang (rules' caches) (rules' caches) "2020/invitation/*.md"

  -- where
  --   rules' caches locale =
  --     markdownPageRules $ \x -> do
  --       ctx <- mkInvitationLetterCtx caches
  --       renderLetterPage ctx x
