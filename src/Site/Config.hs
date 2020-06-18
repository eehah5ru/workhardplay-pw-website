{-# LANGUAGE OverloadedStrings #-}
module Site.Config where

import           Data.Default (def)
import qualified Text.Sass.Options as SO
import Hakyll

import W7W.Config

import qualified W7W.Cache as Cache
import W7W.Labels.Types

type Config = (Cache.Caches, Labels)

mkSiteConfig :: Cache.Caches -> Labels -> Config
mkSiteConfig = (,)
