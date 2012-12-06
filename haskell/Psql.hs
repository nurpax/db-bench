{-# LANGUAGE OverloadedStrings #-}

module Psql (
    benchPostgresqlSimple
  ) where

import           Control.Monad
import           Control.Exception (bracket)
import           Criterion.Config (defaultConfig)
import           Criterion.Main
import           Data.Int
import           Data.List
import qualified Database.PostgreSQL.Simple as PS

import           Util

selectInts :: PS.Connection -> IO ()
selectInts conn = do
  rows <- PS.query_ conn "SELECT id FROM testdata" :: IO [(PS.Only Int)]
  checksum $ foldl' (\acc (PS.Only v) -> v + acc) 0 rows

benchPostgresqlSimple :: IO ()
benchPostgresqlSimple =
  bracket (PS.connect PS.defaultConnectInfo {
                PS.connectDatabase = "dbbench"
              , PS.connectUser = "dbbench"
              , PS.connectPassword = "dbbench" }) PS.close go
  where
    go conn =
      defaultMainWith defaultConfig (return ()) [bench "postgresql-simple: SELECT Ints" $ selectInts conn]
