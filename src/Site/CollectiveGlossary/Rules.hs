{-# LANGUAGE OverloadedStrings #-}
module Site.CollectiveGlossary.Rules where

import           Data.Monoid (mappend, (<>))

import Hakyll

import W7W.Compilers.Slim
import W7W.MultiLang
import W7W.Typography

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
  -- terms pages
  --
  rules' (terms RU ts)
  rules' (terms EN ts)

  --
  -- index page
  --
  withCollectiveGlossaryDeps $ do
    matchMultiLang indexRules indexRules "collective-glossary.md"


  where
    depsRules _ = compile getResourceBody
    indexRules locale =
      slimPageRules $ \x -> do
        termsField <- mkFieldTerms (terms locale ts)
        manyTermsField <- mkFieldManyTerms 200 (terms locale ts)
        let ctx = termsField <> manyTermsField <> siteCtx
        applyAsTemplate ctx x
          >>= loadAndApplyTemplate "templates/collective-glossary-index.slim" ctx
          >>= loadAndApplyTemplate rootPageTpl ctx
          >>= loadAndApplyTemplate rootTpl ctx


    rules' terms =
      tagsRules terms $ \term p -> do
        route $ setExtension "html"
        compile $ do
          ctx <- mkCollectiveGlossaryTermPageCtx terms term p
          getResourceBody >>= saveSnapshot "raw_content"

          pandocCompiler
            >>= beautifyTypography
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/collective-glossary-term.slim" ctx
            >>= loadAndApplyTemplate rootPageTpl ctx
            >>= loadAndApplyTemplate rootTpl ctx



withCollectiveGlossaryDeps rules = do
  deps <- (makePatternDependency (ruDeps .||. enDeps))
  rulesExtraDependencies [deps] rules
  where
    ruDeps = (fromGlob (localizePath RU "collective-glossary/*.md"))
    enDeps = (fromGlob (localizePath EN "collective-glossary/*.md"))

--
--
-- context
--
--

mkCollectiveGlossaryTermPageCtx :: Tags -> String -> Pattern -> Compiler (Context String)
mkCollectiveGlossaryTermPageCtx terms term p = do
  ctx <- mkArchiveIndexPageCtx terms p
  return $
    (fieldTermName term)
    <> fieldAuthorLabel
    <> fieldTermTitle
    <> ctx
