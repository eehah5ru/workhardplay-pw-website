{-# LANGUAGE OverloadedStrings #-}
module Site.Template where

import Hakyll

import W7W.Utils

--
-- templates
--

-- FIXME: unused?
ruPageTpl :: Identifier
ruPageTpl = "templates/page.slim"

-- FIXME: unused?
enPageTpl :: Identifier
enPageTpl = "templates/page.slim"

pageTpl :: Identifier
pageTpl = "templates/page.slim"

rootTpl :: Identifier
rootTpl = "templates/default.slim"
