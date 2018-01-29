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

--
--
-- rules
--
collectiveGlossaryRules :: Terms -> Rules ()
collectiveGlossaryRules ts = do
  --
  -- terms deps rules
  --
  -- matchMultiLang depsRules depsRules ("collective-glossary/*.md")

  --
  -- index page
  --
  withCollectiveGlossaryDeps RU $ withCollectiveGlossaryDeps EN $ do
    matchMultiLang indexRules indexRules "collective-glossary.md"

  --
  -- terms pages
  --
  rules' (terms RU ts)
  rules' (terms EN ts)

  where
    depsRules _ = compile getResourceBody
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
        route $ setExtension "html"
        compile $ do
          ctx <- mkCollectiveGlossaryTermPageCtx terms term p
          pandocCompiler
            >>= loadAndApplyTemplate "templates/collective-glossary-term.slim" ctx
            >>= loadAndApplyTemplate pageTpl ctx
            >>= loadAndApplyTemplate rootTpl ctx

withCollectiveGlossaryDeps locale rules = do
  collectiveGlossaryDefs <- makePatternDependency (fromGlob (localizePath locale "collective-glossary/*.md"))
  rulesExtraDependencies [collectiveGlossaryDefs] rules

--
--
-- context
--
--

mkCollectiveGlossaryTermPageCtx :: Tags -> String -> Pattern -> Compiler (Context String)
mkCollectiveGlossaryTermPageCtx terms term p = do
  ctx <- mkArchiveIndexPageCtx terms p
  return $ (fieldTermName term) <> fieldTermTitle <> ctx
