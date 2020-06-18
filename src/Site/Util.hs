{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleInstances #-}

module Site.Util where

import Data.String

import Hakyll

import W7W.Context
import W7W.MultiLang
import W7W.HasVersion

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
