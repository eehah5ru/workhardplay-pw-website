{-# LANGUAGE OverloadedStrings #-}
module Site.Template where

import Hakyll

--
-- templates
--
ruPageTpl :: Identifier
ruPageTpl = "templates/page-ru.slim"

enPageTpl :: Identifier
enPageTpl = "templates/page-en.slim"

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
