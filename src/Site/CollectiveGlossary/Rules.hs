{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary.Rules where

import           Data.Monoid (mappend, (<>))
import qualified W7W.Cache as Cache

import Hakyll

import W7W.Compilers.Slim
import W7W.MultiLang
import W7W.Typography

import qualified W7W.Cache as Cache

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
collectiveGlossaryRules :: Cache.Caches -> Terms -> Rules ()
collectiveGlossaryRules caches ts = do
  --
  -- terms deps rules
  --
  -- matchMultiLang depsRules depsRules ("collective-glossary/*.md")

  --
  -- terms pages
  --
  rules' (terms RU ts)
  rules' (terms EN ts)

  --
  -- index page
  --
  withCollectiveGlossaryDeps ts $ do
    matchMultiLang indexRules indexRules "collective-glossary.md"


  where
    depsRules _ = compile getResourceBody
    indexRules locale =
      slimPageRules $ \x -> do
        termsField <- mkFieldTerms (terms locale ts)
        manyTermsField <- mkFieldManyTerms 200 (terms locale ts)
        siteCtx <- mkSiteCtx
        let ctx = termsField <> manyTermsField <> siteCtx
        applyAsTemplate ctx x
          >>= loadAndApplyTemplate "templates/collective-glossary-index.slim" ctx
          >>= loadAndApplyTemplate rootPageTpl ctx
          >>= loadAndApplyTemplate rootTpl ctx


    rules' terms =
      tagsRules terms $ \term p -> do
        route $ setExtension "html"
        compile $ do
          ctx <- mkCollectiveGlossaryTermPageCtx caches terms term p
          getResourceBody >>= saveSnapshot "raw_content"

          pandocCompiler
            >>= beautifyTypography
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/collective-glossary-term.slim" ctx
            >>= loadAndApplyTemplate rootPageTpl ctx
            >>= loadAndApplyTemplate rootTpl ctx



withCollectiveGlossaryDeps ts rules = do
  -- deps <- (makePatternDependency (ruDeps .||. enDeps))
  tagsRuDeps <- (return . tagsDependency . terms RU) ts
  tagsEnDeps <- return . tagsDependency . terms EN $ ts

  rulesExtraDependencies [tagsRuDeps, tagsEnDeps] rules
  where
    ruDeps = (fromGlob (localizePath RU "collective-glossary/*.md"))
    enDeps = (fromGlob (localizePath EN "collective-glossary/*.md"))

--
--
-- context
--
--

mkCollectiveGlossaryTermPageCtx :: Cache.Caches -> Tags -> String -> Pattern -> Compiler (Context String)
mkCollectiveGlossaryTermPageCtx caches terms term p = do
  ctx <- mkArchiveIndexPageCtx caches terms p
  return $
    (fieldTermName term)
    <> fieldAuthorLabel
    <> fieldTermTitle
    <> ctx
