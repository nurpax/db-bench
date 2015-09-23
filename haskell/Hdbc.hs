
module Hdbc (
    benchHdbcSqlite3
  ) where

import           Control.Monad
import           Control.Exception (bracket)
import           Criterion.Main.Options
import           Criterion.Main
import           Data.Int
import           Data.List
import           Database.HDBC
import           Database.HDBC.Sqlite3

import           Util

selectInts :: Connection -> IO ()
selectInts conn = do
  rows <- quickQuery' conn "SELECT id from testdata" []
  checksum $ foldl' (\acc [e] -> acc + fromSql e :: Int) 0 rows

benchHdbcSqlite3 :: IO ()
benchHdbcSqlite3 =
  bracket (connectSqlite3 "test.db") disconnect go
  where
    go conn =
      defaultMainWith defaultConfig [bench "hdbc-sqlite3: SELECT Ints" (nfIO (selectInts conn))]
