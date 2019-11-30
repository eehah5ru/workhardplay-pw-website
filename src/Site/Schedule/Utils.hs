{-# LANGUAGE OverloadedStrings #-}

module Site.Schedule.Utils where

import Data.Text hiding (takeWhile, count, map, foldl)

import qualified Data.Text as Text



kebabCase :: Text -> Text
kebabCase = intercalate "-" . Text.words

ruEnReplacements :: [(Text,  Text)]
ruEnReplacements =
  [ ("а" , "a"),
    ("б" , "b"),
    ("в" , "v"),
    ("г" , "g"),
    ("д" , "d"),
    ("е" , "e"),
    ("ж" , "zh"),
    ("з" , "z"),
    ("и" , "i"),
    ("й" , "y"),
    ("к" , "k"),
    ("л" , "l"),
    ("м" , "m"),
    ("н" , "n"),
    ("о" , "o"),
    ("п" , "p"),
    ("р" , "r"),
    ("с" , "s"),
    ("т" , "t"),
    ("у" , "u"),
    ("ф" , "f"),
    ("х" , "kh"),
    ("ц" , "ts"),
    ("ч" , "ch"),
    ("ш" , "sh"),
    ("щ" , "sch"),
    ("ъ" , ""),
    ("ы" , "y"),
    ("ь" , "y"),
    ("э" , "e"),
    ("ю" , "yu"),
    ("я" , "ya"),
    ("А" , "A"),
    ("Б" , "B"),
    ("В" , "V"),
    ("Г" , "G"),
    ("Д" , "D"),
    ("Е" , "E"),
    ("Ж" , "ZH"),
    ("З" , "Z"),
    ("И" , "I"),
    ("Й" , "Y"),
    ("К" , "K"),
    ("Л" , "L"),
    ("М" , "M"),
    ("Н" , "N"),
    ("О" , "O"),
    ("П" , "P"),
    ("Р" , "R"),
    ("С" , "S"),
    ("Т" , "T"),
    ("У" , "U"),
    ("Ф" , "F"),
    ("Х" , "KH"),
    ("Ц" , "TS"),
    ("Ч" , "CH"),
    ("Ш" , "SH"),
    ("Щ" , "SCH"),
    ("Ъ" , ""),
    ("Ы" , "Y"),
    ("Ь" , "Y"),
    ("Э" , "E"),
    ("Ю" , "YU"),
    ("Я" , "YA")]

stripRuEn :: Text -> Text
stripRuEn = foldl (.) id $ map (\(r, e) -> replace r e) ruEnReplacements

stripCustom :: Text -> Text
stripCustom = replace "_" "-"
                . replace ")" ""
                . replace "(" ""
                . replace "," ""
                . replace "." ""
                . replace "\"" ""
                . replace "'" ""
                . replace "/" ""
                . replace ":" ""
                . replace "!" ""
                . replace "”" ""
                . replace "“" ""
                . replace "&" "and"
                . replace "?" ""
                . replace "–" "-"
                . replace "—" "-"
                . replace "«" ""
                . replace "»" ""
                . replace "|" ""
                . replace "\"" ""
                . replace "'" ""
                . replace "’" ""
                . replace "á" "a"
                . replace "é" "e"
                . replace "ü" "u"
                . replace "Ü" "U"
                . replace "ä" "a"
                . replace "Ä" "A"
                . replace "Ö" "O"
                . replace "ö" "o"
                . replace "ё" "e"

stripForId :: Text -> Text
stripForId = stripRuEn . stripCustom

escapeForYaml :: Text -> Text
escapeForYaml = replace "\"" "\\\""
                  . replace "\n" " "
                  . replace "\r\n" " "
