{-# LANGUAGE OverloadedStrings #-}

module Mysql (
    benchMysqlSimple
  ) where

import           Control.Monad
import           Control.Exception (bracket)
import           Criterion.Config (defaultConfig)
import           Criterion.Main
import           Data.Int
import           Data.List
import qualified Database.MySQL.Simple as MS

import           Util

selectInts :: MS.Connection -> IO ()
selectInts conn = do
  rows <- MS.query_ conn "SELECT id FROM testdata" :: IO [(MS.Only Int)]
  checksum $ foldl' (\acc (MS.Only v) -> v + acc) 0 rows

benchMysqlSimple :: IO ()
benchMysqlSimple =
  bracket (MS.connect MS.defaultConnectInfo { MS.connectDatabase = "dbbench" }) MS.close go
  where
    go conn =
      defaultMainWith defaultConfig (return ()) [bench "mysql-simple: SELECT Ints" $ selectInts conn]
