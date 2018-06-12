{-# LANGUAGE OverloadedStrings #-}


-- import           Data.ByteString.Lazy as BSL
import           Data.Default (def)
import Data.Maybe (fromMaybe)
-- import           Data.Monoid (mappend, (<>))
import           Hakyll
-- import           Hakyll.Core.Configuration (Configuration, previewPort)
-- import           Hakyll.Core.Metadata
import Hakyll.Core.Compiler (getUnderlying)
import Hakyll.Web.Template.Internal (readTemplate)


import W7W.Types
import W7W.MultiLang
import W7W.Compilers.Slim
import W7W.Config

import W7W.Rules.Templates
import W7W.Rules.Assets
import W7W.Pictures.Rules
-- import W7W.Rules.StaticPages

import Site.Context
import Site.Template

import Site.StaticPages.Rules
import Site.Archive.Rules

import Site.CollectiveGlossary
import Site.CollectiveGlossary.Rules

--------------------------------------------------------------------------------

main :: IO ()
main =
  hakyllWith config $
  do
     templatesRules

     imagesRules -- static assets
     picturesRules (1280, 1280) "pictures/**/*"
     fontsRules
     dataRules

     cssAndSassRules

     jsRules


     -- slim partials for deps
     match ("ru/**/_*.slim" .||. "en/**/_*.slim") $ compile getResourceBody

     -- collective glossary defenitions for deps


     staticPagesRules

     terms <- buildTerms

     collectiveGlossaryRules terms
     archiveIndexPagesRules terms
     archiveProjectPagesRules terms

--------------------------------------------------------------------------------
