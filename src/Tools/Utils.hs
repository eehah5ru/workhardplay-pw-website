{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

module Tools.Utils where

import System.Environment
import System.Exit
import System.IO

import Control.Monad.Except

import Data.Attoparsec.Text
import Data.Text hiding (takeWhile, count)
import qualified Data.Text.IO as TIO
import qualified Data.Text as Text
import qualified Rainbow.Types as T
import qualified Data.ByteString as BS

import W7W.MultiLang

import Rainbow

import Site.Schedule.ProjectFile.Parser


import Site.Schedule.ProjectFile
import qualified Site.Schedule.ProjectFile as PF

import Site.Schedule.Types

stripBom :: String -> String
stripBom ('\65279' : s) = s
stripBom s = s


withParsedFileInput :: Parser a -> (a -> IO ()) -> IO ()
withParsedFileInput p f = do
  input <- return . Text.pack . stripBom =<< getContents
  either e' f (parseOnly p input)
  where
    e' s = error $ "error parsing input: " ++ s


logError :: Text.Text -> IO ()
logError e = do
  hPutChunk stderr $ chunk e & fore red
  hPutStr stderr "\n"

hPutChunk :: Renderable a => Handle -> T.Chunk a -> IO ()
hPutChunk h ck = do
  mkr <- byteStringMakerFromHandle h
  mapM_ BS.putStr . chunksToByteStrings mkr $ [ck]




--
-- arg parsers
--

data ParticipantSource = FromProject | FromInstruction

class FromArg a where
  parseArg :: String -> Either String a


instance FromArg Locale where
  parseArg x =
    case fromLang x of
      UNKNOWN -> Left $ "unknown locale: " ++ x
      l -> Right l

instance FromArg ParticipantSource where
  parseArg "fromProject" = return FromProject
  parseArg "fromInstruction" = return FromInstruction
  parseArg x = Left $ "unknown participant source: " ++ x


throwParseArgError :: (ToText a) => a -> IO b
throwParseArgError e = do
  logError  $ ("error parsing arg: " <> (toText e))
  exitWith $ ExitFailure 1


--
-- parse strictly one command line arg
--
parseOneArg :: (FromArg a) => IO a
parseOneArg = do
  getArgs >>= return . parse'  >>= either error return

  where
    parse' :: (FromArg a) => [String] -> Either String a
    -- parse' = undefined
    parse' [] = Left "args are empty"

    parse' (x:[]) = parseArg x

    parse' _ = Left "too many args"

--
-- parse strictly two args
--
parseTwoArgs :: (FromArg a, FromArg b) => IO (a, b)
parseTwoArgs = do
  getArgs >>= return . parse' >>= either error return

  where
    parse' [] = Left "args are empty"

    parse' (x:y:[]) = do
      rX <- parseArg x
      rY <- parseArg y
      return (rX, rY)

    parse' _ = Left "too many args"
