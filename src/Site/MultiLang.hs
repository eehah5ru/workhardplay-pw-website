{-# LANGUAGE OverloadedStrings #-}

module Site.MultiLang where

import System.FilePath.Posix ((</>))
import Data.Maybe (fromMaybe)

import Hakyll
import Hakyll.Core.Util.String (replaceAll)
import Site.Types

import Site.Utils

matchMultiLang
  :: Rules () -> Rules () -> FilePath -> Rules ()
matchMultiLang ruRules enRules path =
  do match ruPages $ ruRules
     match enPages $ enRules
  where ruPages = fromGlob $ "ru" </> path
        enPages = fromGlob $ "en" </> path


localizeUrl :: String -> String -> String
localizeUrl prefix [] = "/" ++ prefix ++ "/"
localizeUrl prefix url = "/" ++ prefix ++ "/" ++ url'
  where
    url' = case (head url) of
             '/' -> tail url
             _ -> url

otherLang :: String -> String
otherLang l = case l of
                "ru" -> "en"
                "en" -> "ru"
                _ -> "unknown"


fieldOtherLang :: Context String
fieldOtherLang =
  field "other_lang" (return . otherLang . itemLang)


fieldOtherLangUrl :: Context String
fieldOtherLangUrl =
  field "other_lang_url" getOtherLangUrl
  where
    getOtherLangUrl i = do
      u <- return . fromMaybe "/not-found.html" =<< getRoute =<< (return . itemIdentifier) i
      return . toUrl $ (replaceAll (pattern' i) (replacementF i) u)
    pattern' i = (itemLang i) ++ "/"
    replacementF i = const $ (otherLang . itemLang $ i) ++ "/"


fieldRuUrl :: Context String
fieldRuUrl = multiLangUrlField "ru" "en"

fieldEnUrl :: Context String
fieldEnUrl = multiLangUrlField "en" "ru"

multiLangUrlField :: String -> String -> Context String
multiLangUrlField lang fromLang = field fieldName (\x -> getUrl fromLang x >>= return . translateUrl fromLang lang >>= return . (++) "/")
  where notFoundPage :: String -> String
        notFoundPage lang = (lang ++ "/2017/404.html")

        fieldName = lang ++ "_url"

        getUrl :: String -> Item a -> Compiler String
        getUrl langPrefix i = return (itemIdentifier i)
          -- >>= (load :: Identifier -> Compiler (Item String))
          -- >>= return . itemIdentifier
          >>= getRoute
          >>= return . maybe (notFoundPage langPrefix) id

        translateUrl :: String -> String -> String -> String
        translateUrl fromLang toLang = replaceAll (fromLang ++ "/") (const (toLang ++ "/"))
        fallbackToNotFound :: String -> String -> Compiler String
        fallbackToNotFound lang u =
          do debugCompiler ("MultiLang-before: " ++ u)
             fallbackUrl <- return u >>= return . fromFilePath >>= getRoute >>= return . maybe (notFoundPage lang) id
             debugCompiler ("MultiLang-after: " ++ fallbackUrl)
             return fallbackUrl
