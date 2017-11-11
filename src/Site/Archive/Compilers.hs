{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.Compilers where

import Hakyll
import Site.Template
import Site.Context

import Site.Archive.ProjectContext
--
--
-- renderers
--
--
renderProjectsItems ctx projects = do
  tpl <- loadBody "templates/archive-2017-item.slim"
  applyTemplateList tpl ctx projects

renderProjectsListItems ctx projects = do
  tpl <- loadBody "templates/archive-2017-projects-list-item.slim"
  applyTemplateList tpl ctx projects

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
