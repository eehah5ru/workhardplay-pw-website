{-# LANGUAGE OverloadedStrings #-}
module Site.Config where

import           Data.Default (def)
import qualified Text.Sass.Options as SO
import Hakyll

config :: Configuration
config =
  defaultConfiguration {destinationDirectory = "_site"
                       ,storeDirectory = "_cache"
                       ,tmpDirectory = "_tmp"
                       ,previewPort = 8001
                       ,previewHost = "0.0.0.0"
                       ,inMemoryCache = True }


sassOptions :: SO.SassOptions
sassOptions = def { SO.sassIncludePaths = Just [ "css/"
                                               , "bower_components/foundation-sites/scss/"] }
