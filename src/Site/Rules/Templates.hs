{-# LANGUAGE OverloadedStrings #-}
module Site.Rules.Templates where

import Hakyll

import Site.Compilers.Slim

templatesRules =
  do
    match "templates/*.html" $ compile templateCompiler

    match "templates/_*.slim" $
      compile getResourceBody

    slimDeps <- makePatternDependency "templates/_*.slim"
    rulesExtraDependencies [slimDeps] $
      match ("templates/*.slim" .&&. (complement "templates/_*.slim")) $ do
        compile $
          getResourceString
            >>= withItemBody compileSlimWithEmptyLocals
            >>= withItemBody (return . readTemplate)
            >>= saveSnapshot "template"
