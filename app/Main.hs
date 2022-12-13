module Main (main) where

import Lib (extractFirstEntryFromZipURL)
import System.Directory(createDirectoryIfMissing)
import Happstack.Server
import qualified Data.ByteString.Lazy as L
import Control.Monad.Trans (MonadIO (liftIO))
import Data.ByteString.Lazy (fromStrict)
import Data.ByteString.Lazy.UTF8 (fromString)

main :: IO ()
main = someFunc

theConf :: Conf
theConf =
  Conf
    { port = 7890,
      validator = Nothing,
      logAccess = Just logMAccess,
      timeout = 30,
      threadGroup = Nothing
    }

userContentsDirName :: String
userContentsDirName = "user-contents"

myPolicy :: BodyPolicy
myPolicy = defaultBodyPolicy "/tmp/" (1024 * 1024 * 128) (1024 * 1024) 1024

handlers :: ServerPart Response
handlers =
  do
    addHeaderM "Access-Control-Allow-Origin" "*"
    decodeBody myPolicy
    toResponse <$> streamUnzip

streamUnzip :: ServerPart L.ByteString 
streamUnzip = 
  do
    url <- look "url"
    liftIO $ print url
    firstEntry <- liftIO $ extractFirstEntryFromZipURL url
    case firstEntry of
      Just bytes -> ok $ fromStrict bytes
      Nothing -> badRequest (fromString "Failed to get first entry from remote primitive file")

someFunc :: IO ()
someFunc = do
  print "port is "
  print $ port theConf
  createDirectoryIfMissing True userContentsDirName
  simpleHTTP theConf $ handlers