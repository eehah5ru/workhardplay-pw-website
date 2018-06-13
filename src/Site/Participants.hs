{-# LANGUAGE OverloadedStrings #-}
module Site.Participants where


import Data.Monoid (mappend, (<>))

import Data.Maybe (fromMaybe)
import Data.List (find)
import Hakyll

import W7W.MultiLang
import W7W.Utils

import Site.Archive.Utils


participantIdentifier i pId = fromFilePath . localizePath (itemLocale i) $ ("participants/" ++ pId ++ ".md")

getParticipantMetadataField i pId fName = getMetadataField (participantIdentifier i pId) fName

fieldParticipantBio =
  functionField "participantBio" f
  where
    f [] _ = error "participantBio: empty args"
    f [participantId] i = loadSnapshotBody (participantIdentifier i participantId) "content"
    f _ _ = error "participantBio: too many args"


fieldParticipantRawBio =
  functionField "participantRawBio" f
  where
    f [] _ = error "participantRawBio: empty args"
    f [participantId] i = loadSnapshotBody (participantIdentifier i participantId) "raw_content"
    f _ _ = error "participantRawBio: too many args"


fieldParticipantName =
  functionField "participantName" f
  where
    f [] _ = error "participantName: empty args"
    f [participantId] i = do
      pM <- getParticipantMetadataField i participantId "title"
      case pM of
        Just name -> return name
        _ -> error $ "participantName: no title field for " ++ participantId
    f _ _ = error "participantName: too many args"


fieldParticipantCity =
  functionField "participantCity" f
  where
    f [] _ = error "participantCity: empty args"
    f [participantId] i = do
      pM <- getParticipantMetadataField i participantId "city"
      case pM of
        Just city -> return city
        Nothing -> error $ "participantCity: no city for " ++ participantId
    f _ _ = error "participantCity: too many args"
