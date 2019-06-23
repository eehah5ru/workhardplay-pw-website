{-# LANGUAGE OverloadedStrings #-}

module Tools.Utils where

import System.IO

import Data.Attoparsec.Text
import Data.Text hiding (takeWhile, count)
import qualified Data.Text.IO as TIO
import qualified Data.Text as Text
import qualified Rainbow.Types as T
import qualified Data.ByteString as BS

import Rainbow

import Site.Schedule.ProjectFile.Parser


import Site.Schedule.ProjectFile
import qualified Site.Schedule.ProjectFile as PF


stripBom :: String -> String
stripBom ('\65279' : s) = s
stripBom s = s


withProjectFileInput :: (ProjectFile -> IO ()) -> IO ()
withProjectFileInput f = do
  input <- return . Text.pack . stripBom =<< getContents
  either e' f (parseOnly parseProjectFile input)
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
