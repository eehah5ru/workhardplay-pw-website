{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.IndexContext where

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)

import Hakyll

import W7W.Utils
import W7W.Context

import Site.Context
import Site.Archive.Compilers
import Site.Archive.ProjectContext

import Site.Archive.Utils


mkProjectsField ctx projectsPattern =
  loadAll projectsPattern
  >>= renderProjectsItems ctx
  >>= return . constField "projects"

mkProjectsListField ctx projectsPattern = do
  loadAll projectsPattern
  >>= return . take 100 . cycleProjects
  >>= renderProjectsListItems ctx
  >>= return . constField "projectsList"
  where cycleProjects [] = []
        cycleProjects px = cycle px
--
-- index page ctx
--
mkArchiveIndexPageCtx :: Tags -> Pattern -> Compiler (Context String)
mkArchiveIndexPageCtx terms pxPattern = do
  let pCtx = (archiveProjectCtx terms)
  projects <- mkProjectsField pCtx pxPattern
  projectsList <- mkProjectsListField pCtx pxPattern
  return $
    projects
    <> projectsList
    <> siteCtx
