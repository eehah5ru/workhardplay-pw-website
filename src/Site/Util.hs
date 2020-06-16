{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}

module Site.Util where


import Hakyll

import W7W.Context
import W7W.MultiLang

data Version = TxtVersion
             | DefaultVersion

toVersionPattern :: Version -> Pattern
toVersionPattern TxtVersion = hasVersion "txt"
toVersionPattern DefaultVersion = hasNoVersion
--
-- multilang deps pattern
--
multilangDepsPattern :: String -> Pattern
multilangDepsPattern p = f' RU .||. f' EN
  where
    f' l = fromGlob . localizePath l $ p

--
-- add docs from schedule rules context
--
withVersionedDeps :: Version -> [Pattern] -> Rules b -> Rules b
withVersionedDeps version dPatterns rules  = do
  deps <- mapM makePatternDependency $ map ((.&&.) (toVersionPattern version)) dPatterns
  rulesExtraDependencies deps rules
