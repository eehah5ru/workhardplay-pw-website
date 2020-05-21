{-# LANGUAGE OverloadedStrings #-}

module Site.Invitation2020.Rules where

import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))

import qualified W7W.Cache as Cache

import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography

import qualified W7W.Cache as Cache

import Site.Template
import Site.Context

import Site.Invitation2020.Compiler
import Site.Invitation2020.Context

invitation2020Rules :: Cache.Caches -> Rules ()
invitation2020Rules caches = do
  matchMultiLang rules' rules' "2020/invitation.md" -- Nothing

  where
    rules' locale =
      markdownPageRules $ \x -> do
        ctx <- mkInvitationPageCtx caches
        renderInvitationPage ctx x

invitation2020LetterRules :: Cache.Caches -> Rules ()
invitation2020LetterRules caches = do
  matchMultiLang rules' rules' "2020/invitation/*.md"

  where
    rules' locale =
      markdownPageRules $ \x -> do
        ctx <- mkInvitationLetterCtx caches
        renderLetterPage ctx x
