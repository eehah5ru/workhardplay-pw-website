{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary.Rules where

import           Data.Monoid (mappend, (<>))

import Hakyll

import W7W.Compilers.Slim
import W7W.MultiLang

import Site.Template
import Site.Context
import Site.Archive.IndexContext (mkArchiveIndexPageCtx)
-- import Site.Archive.IndexContext (mkProjectsField)
import Site.CollectiveGlossary
import Site.CollectiveGlossary.Context

collectiveGlossaryRules :: Terms -> Rules ()
collectiveGlossaryRules ts = withCollectiveGlossaryDeps $ do

  matchMultiLang indexRules indexRules "collective-glossary.md"

  rules' (terms RU ts)
  rules' (terms EN ts)

  where
    indexRules locale =
      slimPageRules $ \x -> do
        termsField <- mkFieldTerms (terms locale ts)
        let ctx = termsField <> siteCtx
        applyAsTemplate ctx x
          >>= loadAndApplyTemplate "templates/collective-glossary-index.slim" ctx
          >>= loadAndApplyTemplate pageTpl ctx
          >>= loadAndApplyTemplate rootTpl ctx


    rules' terms =
      tagsRules terms $ \term p -> do
        route idRoute
        compile $ do
          ctx <- mkCollectiveGlossaryTermPageCtx terms term p
          makeItem ""
            >>= loadAndApplyTemplate "templates/collective-glossary-term.slim" ctx
            >>= loadAndApplyTemplate pageTpl ctx
            >>= loadAndApplyTemplate rootTpl ctx

withCollectiveGlossaryDeps rules = do
  collectiveGlossaryDefs <- makePatternDependency "collective-glossary/*.md"
  rulesExtraDependencies [collectiveGlossaryDefs] rules

--
--
-- context
--
--

mkCollectiveGlossaryTermPageCtx :: Tags -> String -> Pattern -> Compiler (Context String)
mkCollectiveGlossaryTermPageCtx terms term p = do
  ctx <- mkArchiveIndexPageCtx terms p
  return $ ctx <> (fieldTermName term)
