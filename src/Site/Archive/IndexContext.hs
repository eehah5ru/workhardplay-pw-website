{-# LANGUAGE OverloadedStrings #-}
module Site.Archive.IndexContext where

import Control.Monad.Reader

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)

import Hakyll

import W7W.Utils
import W7W.Context

import qualified W7W.Cache as Cache

import Site.Context
import Site.Archive.Compilers
import Site.Archive.ProjectContext

import Site.Archive.Utils
import W7W.Labels.Types


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
mkArchiveIndexPageCtx :: (Cache.HasCache c, HasLabels c) => c -> Tags -> Pattern -> Compiler (Context String)
mkArchiveIndexPageCtx c terms pxPattern = do
  pCtx <- mkArchiveProjectCtx c terms
  projects <- mkProjectsField pCtx pxPattern
  projectsList <- mkProjectsListField pCtx pxPattern
  siteCtx <- runReaderT siteCtx c
  return $
    projects
    <> projectsList
    <> siteCtx
