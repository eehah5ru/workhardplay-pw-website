{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.Compilers where

import Hakyll
import Site.Template
import Site.Context
--
--
-- renderers
--
--
renderProjectsItems projects =
  applyTemplateSnapshotList "templates/archive-2017-item.slim" siteCtx projects

renderProjectsListItems projects =
  applyTemplateSnapshotList "templates/archive-2017-projects-list-item.slim" siteCtx projects

renderArchiveProjectPage projectTemplate pageTemplate ctx x =
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate projectTemplate ctx
  >>= loadAndApplyTemplate pageTemplate ctx
  >>= loadAndApplyTemplate rootTpl ctx
  -- >>= relativizeUrls

renderArchiveIndexPage pageTemplate ctx x=
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/archive-2017-page.slim" ctx
  >>= loadAndApplyTemplate pageTemplate ctx
  >>= loadAndApplyTemplate rootTpl ctx
  -- >>= relativizeUrls
