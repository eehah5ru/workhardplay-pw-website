{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}

module Site.Schedule.Types where

import qualified Data.Text as T
import qualified W7W.MultiLang as ML
import W7W.MultiLang (en, ru, Multilang)


type TextField = Maybe T.Text

class ToTextField a where
  toTextField :: a -> TextField

instance ToTextField TextField where
  toTextField = id

--
--
-- multilang
--
--

textOrMissing :: (Labeled a) => a -> (a -> TextField) -> T.Text
textOrMissing x f = maybe (missing x) id (f x)
  where
    missing x = T.pack $ "No" ++ (label x)

hasRu3 :: (Multilang a, ToTextField (ML.MultilangValue a)) => a -> Bool
hasRu3 x = case toTextField (ru x) of
            Nothing -> False
            Just _ -> True

hasRu :: (Multilang a, ToTextField (ML.MultilangValue a)) => a -> Bool
hasRu x = case (toTextField $ ru x) of
            Nothing -> False
            Just _ -> True

hasEn :: (Multilang a, ToTextField (ML.MultilangValue a)) => a -> Bool
hasEn x = case (toTextField $ en x) of
            Nothing-> False
            Just _ -> True

hasBoth :: (Multilang a, ToTextField (ML.MultilangValue a)) => a -> Bool
hasBoth x = (hasRu x) && (hasEn x)

translate :: (Multilang a, ToTextField (ML.MultilangValue a)) => ML.Locale -> a -> TextField
translate l x = ML.chooseByLocale (toTextField $ ru x) (toTextField $ en x) l

translateOrMissing :: (Multilang a, Labeled a, ToTextField (ML.MultilangValue a)) => ML.Locale -> a -> T.Text
translateOrMissing l x = textOrMissing x (translate l)

--
--
-- labeled
--
--
class Labeled a where
  label :: a -> String

-- data IdLabeled a = IdLabeled {getIdLabel :: String
--                              ,unIdLabel :: a}

-- instance Labeled (IdLabeled a) where
--   label (IdLabeled l _) = l
--
--
-- toText
--
--
class ToText a where
  toText :: a -> T.Text


instance ToText TextField where
  toText Nothing = "NO_TEXT"
  toText (Just t) = t

instance ToText T.Text where
  toText = id

instance ToText String where
  toText = T.pack

--
--
-- HasAuthor class
--
--
class HasAuthor a where
  getAuthor :: a -> Author

--
--
-- HasTitle class
--
--
class HasTitle a where
  getTitle :: a -> Title

--
--
-- HasBio class
--
--
class HasBio a where
  getBio :: a -> Bio

--
--
-- fields
--
--

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

data ImageCaption = ImageCaption TextField TextField
                  | NoImageCaption deriving (Show, Eq)

data Techrider = Techrider TextField TextField
               | NoTechrider deriving (Show, Eq)

data Instruction = Instruction TextField TextField
                 | NoInstruction deriving (Show, Eq)

data ParticipantNeeds = ParticipantNeeds TextField TextField
                      | NoParticipantNeeds deriving (Show, Eq)


--
--
-- multilang instances of fields
--
--


instance Multilang Author where
  type MultilangValue Author = TextField

  ru (NoAuthor) = Nothing
  ru (Author x _) = x

  en (NoAuthor) = Nothing
  en (Author _ x) = x


instance Multilang Title where
  type MultilangValue Title = TextField

  ru (NoTitle) = Nothing
  ru (Title x _) = x

  en (NoTitle) = Nothing
  en (Title _ x) = x


instance Multilang Format where
  type MultilangValue Format = TextField

  ru (NoFormat) = Nothing
  ru (Format x _) = x

  en NoFormat = Nothing
  en (Format _ x) = x

instance Multilang Description where
  type MultilangValue Description = TextField

  ru NoDescription = Nothing
  ru (Description x _) = x

  en NoDescription = Nothing
  en (Description _ x) = x

instance Multilang PlaceTime where
  type MultilangValue PlaceTime = TextField

  ru NoPlaceTime = Nothing
  ru (PlaceTime x _) = x

  en NoPlaceTime = Nothing
  en (PlaceTime _ x) = x

instance Multilang Duration where
  type MultilangValue Duration = TextField

  ru (NoDuration) = Nothing
  ru (Duration x _) = x

  en NoDuration = Nothing
  en (Duration _ x) = x

instance Multilang Bio where
  type MultilangValue Bio = TextField

  ru NoBio = Nothing
  ru (Bio x _) = x

  en NoBio = Nothing
  en (Bio _ x) = x

instance Multilang ImageCaption where
  type MultilangValue ImageCaption = TextField

  ru NoImageCaption = Nothing
  ru (ImageCaption x _) = x

  en NoImageCaption = Nothing
  en (ImageCaption _ x) = x

instance Multilang Techrider where
  type MultilangValue Techrider = TextField


  ru NoTechrider = Nothing
  ru (Techrider x _) = x

  en NoTechrider = Nothing
  en (Techrider _ x) =x

instance Multilang Instruction where
  type MultilangValue Instruction = TextField


  ru NoInstruction = Nothing
  ru (Instruction x _) = x

  en NoInstruction = Nothing
  en (Instruction _ x) =x

instance Multilang ParticipantNeeds where
  type MultilangValue ParticipantNeeds = TextField

  ru NoParticipantNeeds = Nothing
  ru (ParticipantNeeds x _) = x

  en NoParticipantNeeds = Nothing
  en (ParticipantNeeds _ x) =x


--
--
-- labeled instances of fields
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

instance Labeled ImageCaption where
  label _ = "ImageCaption"

instance Labeled Techrider where
  label _ = "Techrider"

instance Labeled Instruction where
  label _ = "Instruction"

instance Labeled ParticipantNeeds where
  label _ = "ParticipantNeeds"
