{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Site.Rules.ArchivePages where

import Data.Maybe (fromMaybe)
import Data.Monoid ((<>), mempty)

import Hakyll

import Site.Context
import Site.MultiLang
import Site.Template

import Site.Compilers.Slim

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
  >>= applyTemplateSnapshot projectTemplate ctx
  >>= applyTemplateSnapshot pageTemplate ctx
  >>= applyTemplateSnapshot rootTpl ctx
  -- >>= relativizeUrls

renderArchiveIndexPage pageTemplate ctx x=
  applyAsTemplate ctx x
  >>= applyTemplateSnapshot "templates/archive-2017-page.slim" ctx
  >>= applyTemplateSnapshot pageTemplate ctx
  >>= applyTemplateSnapshot rootTpl ctx
  -- >>= relativizeUrls

--
--
-- rules
--
--
archiveIndexPagesRules = do
  matchMultiLang (ruRules (mCtx2016 "ru/2016/archive/*.slim"))
                 (enRules (mCtx2016 "en/2016/archive/*.slim"))
                 "2016/archive.slim"
  matchMultiLang (ruRules (mCtx2017 "ru/2017/projects/*.slim"))
                 (enRules (mCtx2017 "en/2017/projects/*.slim"))
                 "2017/archive.slim"
  where
    localizedRules pageTpl mCtx =
          slimPageRules $ \x -> do
            ctx <- mCtx
            renderArchiveIndexPage pageTpl ctx x
    mCtx2016 = mkArchiveIndexPageCtx "2016"
    mCtx2017 = mkArchiveIndexPageCtx "2017"
    ruRules = localizedRules ruPageTpl
    enRules = localizedRules enPageTpl


archiveProjectPagesRules = do
  matchMultiLang (ruRules ctx2016) (enRules ctx2016) "2016/archive/*.slim"
  matchMultiLang (ruRules ctx2017) (enRules ctx2017) "2017/projects/*.slim"
  where
    ctx2016 = archiveProjectCtx "2016"
    ctx2017 = archiveProjectCtx "2017"
    localizedRules projectTpl pageTpl ctx =
        slimPageRules $ renderArchiveProjectPage projectTpl pageTpl ctx
    ruRules ctx = localizedRules "templates/archive-2017-project-ru.slim" ruPageTpl ctx
    enRules ctx = localizedRules "templates/archive-2017-project-en.slim" enPageTpl ctx



--
--
-- contexts
--
--

yearField year = constField "year" year

mkProjectsField projectsPattern =
  loadAll projectsPattern
  >>= renderProjectsItems
  >>= return . constField "projects"

mkProjectsListField projectsPattern = do
  loadAll projectsPattern
  >>= return . take 100 . cycle
  >>= renderProjectsListItems
  >>= return . constField "projects_list"

projectTitleField :: Context String
projectTitleField =
  field "title" getTitleFromItem
  where
    projectName m = fromMaybe "noname" (lookupString "project_title" m)
    authorName m = fromMaybe "noname" (lookupString "author" m)
    getTitleFromItem item = do
      m <- getMetadata (itemIdentifier item)
      return $ (authorName m) ++ " -> " ++ (projectName m)

--
-- project page ctx
--
archiveProjectCtx year =
  projectTitleField
  <> (yearField year)
  <>  siteCtx




--
-- index page ctx
--
mkArchiveIndexPageCtx year pxPattern = do
  projects <- mkProjectsField pxPattern
  projectsList <- mkProjectsListField pxPattern
  return $
    projects
    <> projectsList
    <> yearField year
    <> siteCtx
