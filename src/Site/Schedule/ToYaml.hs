{-# LANGUAGE MonoLocalBinds #-}
{-# LANGUAGE MonoLocalBinds #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ToYaml where

import qualified Data.Text as T

import Site.Schedule.Types

class ToYamlField a where
  yamlField :: T.Text -> a -> T.Text
  yamlFieldMaybe :: T.Text -> (a -> Bool) -> a -> Maybe T.Text

escapeForYaml :: T.Text -> T.Text
escapeForYaml = T.replace "\"" "\\\""
                  . T.replace "\n" " "
                  . T.replace "\r\n" " "

quote t = "\"" `T.append` t `T.append` "\""


-- yamlField :: T.Text -> (a -> TextField) -> T.Text
-- yamlField title

instance (ToText a) => ToYamlField a where
  yamlField t x = t <> ": " <> (quote . escapeForYaml . toText $ x)
  yamlFieldMaybe t f x | f x = Just . yamlField t $ x
                       | otherwise = Nothing

yamlJustField :: (ToYamlField a) => T.Text -> a -> Maybe T.Text
yamlJustField t = Just . yamlField t
