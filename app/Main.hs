{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Monad (forever)
import Control.Concurrent.Async (mapConcurrently)
import Data.Aeson (encodeFile)
import Data.Bifunctor (first)
import Data.Either (partitionEithers)
import Data.List (intersperse, sortBy)
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Time.Calendar (Day, fromGregorian, toGregorian, showGregorian)
import Data.Text (pack)
import Nix.Revision (load)
import System.TimeIt (timeItNamed)
import Nix.Versions.Types (CachePath(..), Config(..), Channel(..), Name(..), Hash(..), Commit(..))
import Text.Parsec (parse)

import qualified Data.HashMap.Strict as H
import qualified Nix.Revision as Revision
import qualified Nix.Versions.Database as Persistent

import qualified Nix.Versions.Parsers as Parsers
import qualified Nix.Versions as V

config :: Config
config = Config
    { config_databaseFile   = "./saved-versions/database"
    , config_cacheDirectory = CachePath "./saved-versions"
    , config_gitHubUser     = "lazamar"
    }

from :: Day
from = read "2014-01-01"

to :: Day
to = read "2019-02-01"

main :: IO ()
main = do
    conn <- Persistent.connect Persistent.defaultDBFileName
    res <- Persistent.versions conn (Name "haskellPackages.hlint")
    showVersions res

getName :: IO Name
getName = Name . pack <$> getLine

showVersions :: Show a => [a] -> IO ()
showVersions = putStrLn . unlines . fmap show
