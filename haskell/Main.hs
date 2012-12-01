{-# LANGUAGE OverloadedStrings #-}

import           Control.Exception (bracket)
import           Criterion.Config (defaultConfig)
import           Criterion.Main
import           Data.Int
import           Data.List
import qualified Database.SQLite.Simple as S
import qualified Database.SQLite3 as DS
import           Options.Applicative

nRows :: Int
nRows = 10000

checksum :: Int -> IO ()
checksum s =
  if s /= nRows*(nRows+1) `div` 2 then
    error "Expecting sum of ids to be (1+2+3+..+n)"
   else
    return ()

selectInts :: S.Connection -> IO ()
selectInts conn = do
  rows <- S.query_ conn "SELECT id FROM testdata" :: IO [(S.Only Int)]
  checksum $ foldl' (\acc (S.Only v) -> v + acc) 0 rows

-----------------------------------------------------------

sumRowsColumnInt64 :: DS.Statement -> Int64 -> IO Int64
sumRowsColumnInt64 stmt acc = do
  r <- DS.step stmt
  case r of
    DS.Row ->
      do
        i <- DS.columnInt64 stmt 0
        sumRowsColumnInt64 stmt (acc + i)
    DS.Done ->
      return acc

sumRowsColumns :: DS.Statement -> Int64 -> IO Int64
sumRowsColumns stmt acc = do
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
  let n = 10000
  stmt <- DS.prepare conn "SELECT id FROM testdata"
--  sum <- sumRowsColumnInt64 stmt 0
  sum <- sumRowsColumns stmt 0
  DS.finalize stmt
  checksum (fromIntegral sum)

benchSqliteSimple :: IO ()
benchSqliteSimple =
  bracket (S.open "test.db") S.close go
  where
    go conn =
      defaultMainWith defaultConfig (return ()) [bench "SELECT Ints" $ selectInts conn]

benchDirectSqlite3 :: IO ()
benchDirectSqlite3 =
  bracket (DS.open "test.db") DS.close go
  where
    go conn =
      defaultMainWith defaultConfig (return ()) [bench "SELECT Ints" $ selectIntsDS conn]

main :: IO()
main = do
  putStrLn "*** Benchmark sqlie-simple Database.SQLite.Simple"
  benchSqliteSimple
  putStrLn "*** Benchmark direct-sqlite Database.SQLite3"
  benchDirectSqlite3
