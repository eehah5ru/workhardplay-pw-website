{-# LANGUAGE OverloadedStrings #-}


-- import           Data.ByteString.Lazy as BSL
import           Data.Default (def)
import Data.Maybe (fromMaybe)

import qualified W7W.Cache as Cache

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

import qualified Site.Participants.Rules as OldParticipants

import qualified Site.ParticipantsNg.Rules as Participants

-- import Site.Schedule.Rules
import Site.Schedule2019.Rules hiding (config)

import Site.Invitation2020.Rules
import Site.Instructions2020.Rules
import Site.Screenings2020.Rules

--------------------------------------------------------------------------------

main :: IO ()
main = do
  caches <- Cache.newCaches

  hakyllWith config $
    do


       templatesRules

       imagesRules -- static assets
       -- picturesRules (1280, 1280) "pictures/**/*"
       copyPicturesRules "pictures/**/*"
       fontsRules
       dataRules

       cssAndSassRules ("css/_*.scss" .||. "css/**/_*.scss") [ "css/app.scss"]       
  
       jsRules


       -- slim partials for deps
       match ("ru/**/_*.slim" .||. "en/**/_*.slim") $ compile getResourceBody

       -- collective glossary defenitions for deps
       OldParticipants.participantsRules

       --
       -- 2019's schedule and participants
       --
       schedule2019Rules caches
       
       Participants.participantsRules caches "2019"

       invitation2020LetterRules caches
       invitation2020Rules caches

       instructions2020Rules caches
       instruction2020PageRules caches

       -- screenings2020Rules caches
       -- screening2020PageRules caches
       
       staticPagesRules caches

       terms <- buildTerms

       collectiveGlossaryRules caches terms
       archiveIndexPagesRules caches terms
       archiveProjectPagesRules caches terms

--------------------------------------------------------------------------------
