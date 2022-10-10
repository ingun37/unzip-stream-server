module Lib
  ( extractFirstEntryFromZipURL,
  )
where

import Codec.Archive.Zip
  ( EntryDescription (edUncompressedSize),
    EntrySelector,
    ZipArchive,
    getEntries,
    getEntry,
    withArchive,
  )
import Control.Monad (forM, join)
import Data.ByteString (ByteString)
import Data.Map (Map, toList)
import Data.Sort (sortOn)
import Data.Text (pack)
import Data.Text.Encoding (encodeUtf8)
import Network.Http.Client (get)
import Network.URI (parseURI, uriPath)
import System.FilePath.Posix (joinPath, takeFileName)
import System.IO.Streams (connect)
import System.IO.Streams.File (withFileAsOutput)
import System.IO.Temp (withSystemTempDirectory)

takeFileNameFromURI :: String -> Maybe FilePath
takeFileNameFromURI = fmap (takeFileName . uriPath) . parseURI

fff :: Map EntrySelector EntryDescription -> ZipArchive (Maybe ByteString)
fff = mapM getEntry . safeHead . reverse . sortedKeys edUncompressedSize

getFirstEntry ::
  ZipArchive
    (Maybe ByteString)
getFirstEntry = fff =<< getEntries

bbb :: String -> String -> IO (Maybe ByteString)
bbb url zipName = do
  withSystemTempDirectory
    zipName
    ( \tmpDir -> do
        get
          (encodeUtf8 (pack url))
          ( \_ zipIn -> do
              let zipPath = joinPath [tmpDir, "the.zip"]
              print zipPath
              withFileAsOutput zipPath (connect zipIn)
              withArchive zipPath getFirstEntry
          )
    )

extractFirstEntryFromZipURL :: String -> IO (Maybe ByteString)
extractFirstEntryFromZipURL url =
  let zipName = takeFileNameFromURI url
   in join <$> forM zipName (bbb url)

safeHead :: [a] -> Maybe a
safeHead fa = case fa of
  (x : _) -> Just x
  [] -> Nothing

sortedKeys :: (Ord o) => (v -> o) -> Map k v -> [k]
sortedKeys f = map fst . sortOn (f . snd) . toList
