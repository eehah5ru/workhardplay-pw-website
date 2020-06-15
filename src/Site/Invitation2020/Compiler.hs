{-# LANGUAGE OverloadedStrings #-}
module Site.Invitation2020.Compiler where

import Hakyll

import Site.Template
import Site.Context

import W7W.ManyPages
import qualified W7W.ManyPages.Config as MPC

renderInvitationPage ctx x = do
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/invitation-2020.slim" ctx
  >>= loadAndApplyTemplate rootPageTpl ctx
  >>= loadAndApplyTemplate rootTpl ctx

renderLetters ctx letters = do
  tpl <- loadBody "templates/invitation-2020-letter.slim"
  applyTemplateList tpl ctx letters


renderLetterPage ctx x = do
  applyAsTemplate ctx x
    >>= loadAndApplyTemplate "templates/invitation-2020-letter.slim" ctx
    >>= saveSnapshot "content"
    >>= loadAndApplyTemplate rootTpl ctx
