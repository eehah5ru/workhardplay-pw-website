{-# LANGUAGE OverloadedStrings #-}

module Site.Pictures.Utils where

import           Hakyll

import W7W.Utils


picturesPattern :: Item a -> Pattern
picturesPattern i =
  (basicPicturePattern i "*") .||. (basicPicturePattern i ((itemLang i) ++ "/*"))

coverPattern :: Item a -> Pattern
coverPattern i =
  (basicPicturePattern i ((itemCanonicalName i) ++ "-cover.*")) .||. (picturesPattern i)

basicPicturePattern :: Item a -> String -> Pattern
basicPicturePattern i p =
  fromGlob $ "pictures/" ++ (yearPart i) ++ (itemCanonicalName i) ++ "/" ++ p
  where
    yearPart = maybe "" (\x -> x ++ "/") . itemYear

basicPictureUrl :: Item a -> String
basicPictureUrl i = "/pictures/" ++ (yearPart i) ++ (itemCanonicalName i) ++ "/"
  where
    yearPart = maybe "" (\x -> x ++ "/") . itemYear
