{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.IndexContext where

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)

import Hakyll
import Site.Context
import Site.Archive.Compilers

import Site.Utils
import Site.Archive.Utils




mkProjectsField projectsPattern =
  loadAll projectsPattern
  >>= renderProjectsItems
  >>= return . constField "projects"

mkProjectsListField projectsPattern = do
  loadAll projectsPattern
  >>= return . take 100 . cycle
  >>= renderProjectsListItems
  >>= return . constField "projects_list"

--
-- index page ctx
--
mkArchiveIndexPageCtx pxPattern = do
  projects <- mkProjectsField pxPattern
  projectsList <- mkProjectsListField pxPattern
  return $
    projects
    <> projectsList
    <> siteCtx
