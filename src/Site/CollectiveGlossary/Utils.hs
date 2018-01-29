{-# LANGUAGE OverloadedStrings #-}

module Site.CollectiveGlossary.Utils where

import Hakyll
import W7W.MultiLang

glossaryName :: Item a -> String
glossaryName =
  chooseByItemLang "Глоссарий" "Glossary"
