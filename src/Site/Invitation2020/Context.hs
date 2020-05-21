{-# LANGUAGE OverloadedStrings #-}

module Site.Invitation2020.Context where

import Data.Binary
import Data.Typeable


import Hakyll

import W7W.MultiLang
import qualified W7W.Cache as Cache

import Site.Context

import W7W.Context (sortByOrder)

import Site.Invitation2020.Compiler

lettersPattern :: Locale -> Pattern
lettersPattern l = (fromGlob . localizePath l $ "2020/invitation/*.md")

loadLetters :: (Binary a, Typeable a) => Locale -> Compiler [Item a]
loadLetters l = do
  loadAllSnapshots (lettersPattern l) "content"

mkInvitationLettersField :: Cache.Caches -> Compiler (Context String)
mkInvitationLettersField c = do
  ctx <- mkInvitationLetterCtx c
  return $ listFieldWith "invitationLetters" ctx f
  where
    f :: Item String -> Compiler [Item String]
    f i =
      loadLetters (itemLocale i) >>= sortByOrder
      -- ctx <- mkInvitationLetterCtx c
      -- ((loadLetters (itemLocale i)) :: Compiler [Item String])
      --   >>= getSna

mkInvitationLetterCtx = mkSiteCtx

mkInvitationPageCtx :: Cache.Caches -> Compiler (Context String)
mkInvitationPageCtx caches = do
  ctx <- mkSiteCtx caches
  letters <- mkInvitationLettersField caches
  return $ letters <> ctx
