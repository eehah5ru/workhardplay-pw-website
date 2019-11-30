{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ParticipantFile where

import qualified Data.Text as T

import qualified W7W.MultiLang as ML

import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.Utils


data ParticipantFile =
  ParticipantFile { title :: T.Text
                  , city :: Maybe T.Text
                  , bio :: T.Text } deriving (Show, Eq)


fromProjectFile :: ML.Locale -> PF.ProjectFile -> Maybe ParticipantFile
fromProjectFile l pf = do
  t <- return $ PF.textOrMissing (PF.author $ pf) (translate l)
  c <- return $ Nothing
  b <- return $ PF.textOrMissing  (PF.bio $ pf) (translate l)
  return $ ParticipantFile t c b

   where
    translate :: (PF.Multilang a) => ML.Locale -> a -> PF.TextField
    translate l x = ML.chooseByLocale (PF.ru x) (PF.en x) l

toText :: ParticipantFile -> T.Text
toText p = T.intercalate "\n"
                         [ "---"
                         , titleField p
                         , cityField p
                         , "---"
                         , ""
                         , bio p]
  where
    quote t = "\"" `T.append` t `T.append` "\""
    titleField p = "title: " `T.append` (quote . escapeForYaml $ (title p))

    cityField (ParticipantFile _ Nothing _) = "city: " `T.append` quote "!!!!"
    cityField (ParticipantFile _ (Just c) _) = "city: " `T.append` (quote . escapeForYaml $ c)
