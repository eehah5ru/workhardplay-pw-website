{-# LANGUAGE OverloadedStrings #-}
module Site.Participants.Rules where

import           Data.Monoid (mappend, (<>))

import Hakyll

import W7W.Compilers.Slim
import W7W.MultiLang
import W7W.Typography

import Site.Template
import Site.Context
import Site.Archive.IndexContext (mkArchiveIndexPageCtx)

participantsRules :: Rules ()
participantsRules = do
  matchMultiLang mdRules
                 mdRules
                 "participants/*.md"
  where
    mdRules l  = do
     route $ setExtension "html"
     compile $ do
       getResourceBody >>= saveSnapshot "raw_content"

       pandocCompiler
         >>= beautifyTypography
         >>= saveSnapshot "content"
         -- applyTemplates here!!!

mkParticipantPageCtx = mkSiteCtx
