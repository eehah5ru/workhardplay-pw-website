{-# LANGUAGE OverloadedStrings #-}

module Site.ParticipantsNg.Rules where

import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))

import qualified W7W.Cache as Cache

import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography

import qualified W7W.Cache as Cache

import Site.ParticipantsNg

participantsRules :: Cache.Caches -> String -> Rules ()
participantsRules caches year = do
  matchMultiLang participantRules'' participantRules'' (participantsPattern year)

  matchMultiLang participantTxtRules'' participantTxtRules'' (participantsPattern year)

participantRules'' locale = do
  compile $ do
    pandocCompiler
      >>= beautifyTypography
      >>= saveSnapshot "content"


participantTxtRules'' locale = version "txt" $ participantRules'' locale
