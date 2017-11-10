{-# LANGUAGE OverloadedStrings #-}
module Site.Template where

import Hakyll

--
-- templates
--
ruPageTpl :: Identifier
ruPageTpl = "templates/page.slim"

enPageTpl :: Identifier
enPageTpl = "templates/page.slim"

pageTpl :: Identifier
pageTpl = "templates/page.slim"

rootTpl :: Identifier
rootTpl = "templates/default.slim"

--
--
-- utils
--
--

applyTemplateSnapshot tplPattern cx i = do
  t <- loadSnapshotBody tplPattern "template"
  applyTemplate t cx i

applyTemplateSnapshotList tplPattern cx is = do
  t <- loadSnapshotBody tplPattern "template"
  applyTemplateList t cx is
