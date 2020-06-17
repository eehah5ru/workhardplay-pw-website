{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Site.Util where

import Data.String

import Hakyll

import W7W.Context
import W7W.MultiLang

data Version = TxtVersion
             | DefaultVersion deriving (Eq)

toVersionPattern :: Version -> Pattern
toVersionPattern TxtVersion = hasVersion "txt"
toVersionPattern DefaultVersion = hasNoVersion

class HasVersion a where
  getVersion :: a -> Version

--
-- year type
--
newtype Year = Year {unYear :: String} deriving (IsString)


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

rulesWithVersion :: Version -> Rules () -> Rules ()
rulesWithVersion DefaultVersion rs = rs
rulesWithVersion TxtVersion rs = version "txt" rs
