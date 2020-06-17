{-# LANGUAGE OverloadedStrings #-}

module Site.ParticipantsNg where

import           Data.Monoid (mappend, (<>))
import System.FilePath.Posix ((</>))

import qualified W7W.Cache as Cache

import Hakyll

import W7W.Compilers.Markdown
import W7W.MultiLang
import W7W.Typography

import qualified W7W.Cache as Cache

import Site.Util

--
-- participants pattern for the year
--
participantsPattern :: Year -> FilePath
participantsPattern year = (unYear year) </> "participants/*.md"

participantsDeps year = multilangDepsPattern (participantsPattern year)
