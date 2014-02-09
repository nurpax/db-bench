{-# LANGUAGE OverloadedStrings, BangPatterns, ScopedTypeVariables #-}

module Sqlite (
    benchSqliteSimple
  , benchDirectSqlite3
  ) where

import           Control.Applicative
import           Control.Monad
import           Control.Exception (bracket)
import           Criterion.Config (defaultConfig)
import           Criterion.Main
import           Data.Int
import           Data.List
import qualified Database.SQLite.Simple as S
import qualified Database.SQLite3 as DS
import           Data.Time (UTCTime)
import qualified Data.Text as T

import           Util

data UtcRow = UtcRow Int UTCTime Int Int

instance S.FromRow UtcRow where
  fromRow = UtcRow <$> S.field <*> S.field <*> S.field <*> S.field

selectInts :: S.Connection -> IO ()
selectInts conn = do
  rows <- S.query_ conn "SELECT id FROM testdata" :: IO [(S.Only Int)]
  checksum $ foldl' (\acc (S.Only v) -> v + acc) 0 rows

selectIntsFold :: S.Connection -> IO ()
selectIntsFold conn = do
  val <- S.fold_ conn "SELECT id FROM testdata" 0 sumValues
  checksum val
  where
    sumValues !acc (S.Only (v :: Int)) = return $ acc + v

selectUTCTimeInts :: S.Connection -> IO ()
selectUTCTimeInts conn = do
  rows <- S.query_ conn "SELECT id,time,ex1_id,ex2_id FROM testdata_utc" :: IO [UtcRow]
  checksum $ foldl' (\acc (UtcRow v _d _ex1 _ex2) -> v + acc) 0 rows


benchSqliteSimple :: IO ()
benchSqliteSimple =
  bracket (S.open "test.db") S.close go
  where
    go conn =
      defaultMainWith defaultConfig (return ())
        [ bench "sqlite-simple: SELECT Ints" $ selectInts conn
        , bench "sqlite-simple: SELECT Ints (fold)" $ selectIntsFold conn
        , bench "sqlite-simple: SELECT UTCTime, ints" $ selectUTCTimeInts conn]

-----------------------------------------------------------

sumRowsColumnInt64 :: DS.Statement -> Int64 -> IO Int64
sumRowsColumnInt64 stmt !acc = do
  r <- DS.step stmt
  case r of
    DS.Row ->
      do
        i <- DS.columnInt64 stmt 0
        sumRowsColumnInt64 stmt (acc + i)
    DS.Done ->
      return acc

sumRowsColumns :: DS.Statement -> Int64 -> IO Int64
sumRowsColumns stmt !acc = do
  r <- DS.step stmt
  case r of
    DS.Row ->
      do
        [DS.SQLInteger i] <- DS.columns stmt
        sumRowsColumns stmt (acc+i)
    DS.Done ->
      return acc

selectIntsDS :: DS.Database -> IO ()
selectIntsDS conn = do
  stmt <- DS.prepare conn "SELECT id FROM testdata"
  sum <- sumRowsColumns stmt 0
  DS.finalize stmt
  checksum (fromIntegral sum)

selectIntsInt64DS :: DS.Database -> IO ()
selectIntsInt64DS conn = do
  stmt <- DS.prepare conn "SELECT id FROM testdata"
  sum <- sumRowsColumnInt64 stmt 0
  DS.finalize stmt
  checksum (fromIntegral sum)

benchDirectSqlite3 :: IO ()
benchDirectSqlite3 =
  bracket (DS.open "test.db") DS.close go
  where
    go conn =
      defaultMainWith defaultConfig (return ())
        [ bench "direct-sqlite: SELECT Ints (columns)" $ selectIntsDS conn
        , bench "direct-sqlite: SELECT Ints (columnInt64)" $ selectIntsInt64DS conn]
