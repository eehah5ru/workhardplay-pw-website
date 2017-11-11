{-# LANGUAGE OverloadedStrings #-}
module Site.Rules.StaticPages where

import Hakyll

import Site.Template
import Site.MultiLang
import Site.Context
import Site.Compilers.Slim

staticPagesRules =
  do
    -- 2017
    indexPage "2017/index.slim"
    notFoundPage "2017/404.slim"

    -- 2016
    indexPage "2016/index.slim"
  where
    indexPage = matchMultiLang rules' rules'
    notFoundPage = matchMultiLang rules' rules'

    rules' locale =
      slimPageRules $ compilers
      where compilers x =
              applyAsTemplate siteCtx x
              >>= applyTemplateSnapshot pageTpl siteCtx
              >>= applyTemplateSnapshot rootTpl siteCtx
              -- >>= relativizeUrls
