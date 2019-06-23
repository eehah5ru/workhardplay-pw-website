{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ParticipantFile where

import qualified Data.Text as T

import qualified Site.Schedule.ProjectFile as PF
import Site.Schedule.Utils


data ParticipantFile =
  ParticipantFile { title :: T.Text
                  , city :: Maybe T.Text
                  , bio :: T.Text } deriving (Show, Eq)


fromProjectFile :: PF.ProjectFile -> Maybe ParticipantFile
fromProjectFile pf = do
  t <- PF.en (PF.author $ pf)
  c <- return $ Nothing
  b <- PF.en . PF.bio $ pf
  return $ ParticipantFile t c b

toText :: ParticipantFile -> T.Text
toText p = T.intercalate "\n"
                         [ "---"
                         , titleField p
                         , cityField p
                         , "---"
                         , ""
                         , bio p]
  where
    titleField p = "title: " `T.append` (title p)

    cityField (ParticipantFile _ Nothing _) = "city: " `T.append` "!!!!"
    cityField (ParticipantFile _ (Just c) _) = "city: " `T.append` c
