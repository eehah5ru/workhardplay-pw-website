{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule.Utils where

import Data.Text hiding (takeWhile, count)

import qualified Data.Text as Text


kebabCase :: Text -> Text
kebabCase = intercalate "-" . Text.words


stripForId :: Text -> Text
stripForId = replace "_" "-"
               . replace ")" ""
               . replace "(" ""
               . replace "," ""
               . replace "." ""
               . replace "\"" ""
               . replace "'" ""
