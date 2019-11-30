{-# LANGUAGE OverloadedStrings #-}
module Site.Schedule.ProjectFile where

import qualified Data.Text as T

import Site.Schedule.Utils

type TextField = Maybe T.Text

data Author = Author TextField TextField
            | NoAuthor deriving (Show, Eq)

data Title = Title TextField TextField
           | NoTitle deriving (Show, Eq)

data Format = Format TextField TextField
            | NoFormat deriving (Show, Eq)

data Description = Description TextField TextField
                 | NoDescription deriving (Show, Eq)

data PlaceTime = PlaceTime TextField TextField
               | NoPlaceTime deriving (Show, Eq)

data Duration = Duration TextField TextField
              | NoDuration deriving (Show, Eq)


data Bio = Bio TextField TextField
         | NoBio deriving (Show, Eq)


data Techrider = Techrider TextField TextField
               | NoTechrider deriving (Show, Eq)

data ProjectFile = ProjectFile { author :: Author
                               , title :: Title
                               , format :: Format
                               , description :: Description
                               , placeTime :: PlaceTime
                               , duration :: Duration
                               , bio :: Bio
                               , techrider :: Techrider }

                 | EmptyFile
                 | BrokenFile deriving (Show, Eq)


class Multilang a where
  ru :: a -> TextField
  en :: a -> TextField

class Labeled a where
  label :: a -> String


textOrMissing :: (Labeled a) => a -> (a -> TextField) -> T.Text
textOrMissing x f = maybe (missing x) id (f x)
  where
    missing x = T.pack $ "No" ++ (label x)

hasRu :: (Multilang a) => a -> Bool
hasRu x = case ru x of
            Nothing -> False
            Just _ -> True

hasEn :: (Multilang a) => a -> Bool
hasEn x = case en x of
            Nothing-> False
            Just _ -> True

hasBoth :: (Multilang a) => a -> Bool
hasBoth x = (hasRu x) && (hasEn x)

instance Multilang Author where
  ru (NoAuthor) = Nothing
  ru (Author x _) = x

  en (NoAuthor) = Nothing
  en (Author _ x) = x


instance Multilang Title where
  ru (NoTitle) = Nothing
  ru (Title x _) = x

  en (NoTitle) = Nothing
  en (Title _ x) = x


instance Multilang Format where
  ru (NoFormat) = Nothing
  ru (Format x _) = x

  en NoFormat = Nothing
  en (Format _ x) = x


instance Multilang Description where
  ru NoDescription = Nothing
  ru (Description x _) = x

  en NoDescription = Nothing
  en (Description _ x) = x

instance Multilang PlaceTime where
  ru NoPlaceTime = Nothing
  ru (PlaceTime x _) = x

  en NoPlaceTime = Nothing
  en (PlaceTime _ x) = x

instance Multilang Duration where
  ru (NoDuration) = Nothing
  ru (Duration x _) = x

  en NoDuration = Nothing
  en (Duration _ x) = x

instance Multilang Bio where
  ru NoBio = Nothing
  ru (Bio x _) = x

  en NoBio = Nothing
  en (Bio _ x) = x

instance Multilang Techrider where
  ru NoTechrider = Nothing
  ru (Techrider x _) = x

  en NoTechrider = Nothing
  en (Techrider _ x) =x

--
--
-- labeled instances
--
--

instance Labeled Author where
  label _ = "Author"

instance Labeled Title where
  label _ = "Title"

instance Labeled Format where
  label _ = "Format"

instance Labeled Description where
  label _ = "Description"

instance Labeled PlaceTime where
  label _ = "PlaceTime"

instance Labeled Duration where
  label _ = "Duration"

instance Labeled Bio where
  label _ = "Bio"

instance Labeled Techrider where
  label _ = "techrider"


-- type Locale a = ProjectFile -> (ProjectFile -> a) -> TextField

-- withEn :: (Multilang a) => ProjectFile -> (ProjectFile -> a) -> TextField
-- withEn pf f = en . f $ pf



participantId :: ProjectFile -> Maybe T.Text
participantId pf =
  (en . author $ pf) >>= return . kebabCase . stripForId . T.toLower

projectId :: ProjectFile -> Maybe T.Text
projectId pf = do
  partId <- (en . author $ pf) >>= return . kebabCase . stripForId . T.toLower
  projId <- (en . title $ pf) >>= return . kebabCase . stripForId . T.toLower
  return $ T.intercalate "-" [partId, projId]
