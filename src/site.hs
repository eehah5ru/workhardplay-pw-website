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


import Site.Types
import Site.Config
import Site.Context

import Site.MultiLang
import Site.Template

import Site.Compilers.Slim

import Site.Rules.Templates
import Site.Rules.Assets
import Site.Rules.StaticPages
import Site.Archive.Rules

import Site.CollectiveGlossary
import Site.CollectiveGlossary.Rules

--------------------------------------------------------------------------------

main :: IO ()
main =
  hakyllWith config $
  do
     terms <- buildTerms

     collectiveGlossaryRules terms
     templatesRules

     imagesRules
     fontsRules
     dataRules

     cssAndSassRules

     jsRules

     -- slim partials for deps
     match ("ru/**/_*.slim" .||. "en/**/_*.slim") $ compile getResourceBody

     -- collective glossary defenitions for deps
     match ("collective-glossary/*.md") $ compile getResourceBody

     staticPagesRules

     archiveIndexPagesRules terms
     archiveProjectPagesRules terms

--------------------------------------------------------------------------------
